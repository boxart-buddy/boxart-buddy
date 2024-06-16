<?php

namespace App\ConsoleCommand;

use App\Command\CommandNamespace;
use App\Command\CompressPackageCommand;
use App\Command\CopyResourcesCommand;
use App\Command\Factory\CommandFactory;
use App\Command\GenerateArtworkCommand;
use App\Command\Handler\CentralHandler;
use App\Command\PackageCommand;
use App\Command\TransferCommand;
use App\Config\Reader\ConfigReader;
use App\Config\Validator\ConfigValidator;
use App\FolderNames;
use App\Generator\SkippedRomImportDataGenerator;
use App\Portmaster\PortmasterDataImporter;
use App\Translator\CachedTranslationEraser;
use App\Util\CommandUtility;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use App\Util\TokenUtility;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Stopwatch\Stopwatch;

#[AsCommand(
    name: 'generate-all',
    description: 'Build artwork, folders, preview, package and transfer in a single command',
    aliases: ['build']
)]
class GenerateAllCommand extends Command
{
    use PlatformOverviewTrait;

    public function __construct(
        readonly private CommandFactory $commandFactory,
        readonly private CentralHandler $centralHandler,
        readonly private PortmasterDataImporter $portmasterDataImporter,
        readonly private Path $path,
        readonly private SkippedRomImportDataGenerator $skippedRomImportDataGenerator,
        readonly private ConfigValidator $configValidator,
        readonly private ConfigReader $configReader,
        readonly private CachedTranslationEraser $cachedTranslationEraser,
        readonly private LoggerInterface $logger
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addOption('artwork', null, InputOption::VALUE_REQUIRED, 'Colon delimited pair of {template-folder}:{artwork.xml} or {template-folder}:{artwork.yml} used to generate ROM artwork')
            ->addOption('folder', null, InputOption::VALUE_REQUIRED, 'Colon delimited pair of {template-folder}:{artwork.xml} or {template-folder}:{artwork.yml} used to generate FOLDER artwork')
            ->addOption('portmaster', null, InputOption::VALUE_REQUIRED, 'Colon delimited pair of {template-folder}:{artwork.xml} or {template-folder}:{artwork.yml} used to generate PORTMASTER artwork')
            ->addOption('zip', 'z', InputOption::VALUE_NONE, 'Creates a zip archive of the generated package')
            ->addOption('transfer', 't', InputOption::VALUE_NONE, 'Attempts to transfer the generated artwork to your device using sftp')
            ->addOption('package-name', 'p', InputOption::VALUE_REQUIRED, 'A name for the output package. Will be appended with the configured `romset_name`. If not set will default to the same name as the artwork used.')
            ->addOption('preview-theme', null, InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'Name of theme used during preview generation')
            ->addOption('token', null, InputOption::VALUE_REQUIRED, 'Pass translations to artwork templates at runtime. Accepts a JSON string or key/value pairs in the format: key:value|key2:value2|key3:value3')
            ->addOption('post-process-artwork', null, InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'A post processing strategy to use on generated rom artwork')
            ->addOption('post-process-folder', null, InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'A post processing strategy to use on generated folder artwork')
            ->addOption('post-process-portmaster', null, InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'A post processing strategy to use on generated portmaster artwork')
            ->addOption('per-rom', null, InputOption::VALUE_NONE, 'If set then skyscraper will run one command per rom, rather than per platform. This allows artwork to be translated differently for every rom, required for some templates')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        // delete translation cache folder
        $this->cachedTranslationEraser->erase();

        if (!$output instanceof ConsoleOutput) {
            throw new \RuntimeException();
        }

        // dump out the current command string so that it can be used later during asset packaging
        $this->writeCommandStringToFile($input);
        $io = new BlockSectionHelper($input, $output, $this->logger);
        $io->heading();

        $this->getPlatformOverview($io, $this->configValidator);

        $stopwatch = (new Stopwatch())->start('all');
        $this->deleteOutputFolder();

        // copy resources
        $command = new CopyResourcesCommand($this->getArtworkPackageNamesFromInput($input));
        $io->waitOrFail('copy-resources', 'Copying Custom Resources to Skyscraper Folder', function () use ($command) {
            $this->centralHandler->handle($command);
        });

        // artwork
        $commands = $this->getArtworkCommands($input);

        if ($commands) {
            $io->waitOrFailTargetableCommandsWithProgressBar(
                'generate-rom-artwork',
                'Generating Rom Artwork',
                $commands,
                function ($command) {
                    $this->centralHandler->handle($command);
                }
            );
        }

        // folder
        $commands = $this->getFolderCommands($input);

        if ($commands) {
            $io->waitOrFailTargetableCommandsWithProgressBar(
                'generate-folder-artwork',
                'Generating Folder Artwork',
                $commands,
                function ($command) {
                    $this->centralHandler->handle($command);
                }
            );
        }

        // portmaster
        $command = $this->getPortmasterCommand($input);
        if ($command) {
            // ensure portmaster data is up to date
            $portmasterDataImporter = $this->portmasterDataImporter;
            $io->waitOrFail('import-portmaster-data', 'Importing Portmaster Data', function () use ($portmasterDataImporter) {
                $portmasterDataImporter->importPortmasterDataIfNotImportedSince(new \DateInterval('P1D'));
            });

            $io->waitOrFail('generate-portmaster-artwork', 'Generating Portmaster Artwork', function () use ($command) {
                $this->centralHandler->handle($command);
            });
        }

        $packageName = $this->getPackageName($input);

        // package
        $command = new PackageCommand($packageName);
        $io->waitOrFail('package', 'Packaging', function () use ($command) {
            $this->centralHandler->handle($command);
        });

        // post process
        $commands = $this->getPostProcessCommands($packageName, $input);
        if ($commands) {
            $io->waitOrFailTargetableCommandsWithProgressBar(
                'post-process',
                'Post Processing (SLOW) be patient',
                $commands,
                function ($command) {
                    $this->centralHandler->handle($command);
                }
            );
        }

        // Preview generation
        $commands = $this->getPreviewCommands($packageName, $input);
        if ($commands) {
            $io->waitOrFailTargetableCommandsWithProgressBar(
                'generate-previews',
                'Generating Previews',
                $commands,
                function ($command) {
                    $this->centralHandler->handle($command);
                }
            );
        }

        // optimize
        if ($this->configReader->getConfig()->shouldOptimize) {
            $command = $this->commandFactory->createOptimizeCommand($packageName);
            $io->waitOrFail('optimize', 'Optimizing Images (SLOW)', function () use ($command) {
                $this->centralHandler->handle($command);
            });
        }

        // zip
        if ($input->getOption('zip')) {
            $command = new CompressPackageCommand($packageName);
            $io->waitOrFail('compress-package', 'Compressing Package', function () use ($command) {
                $this->centralHandler->handle($command);
            });
        }

        // transfer
        if ($input->getOption('transfer')) {
            $command = new TransferCommand($packageName);
            $io->waitOrFail('transfer-package', 'Transferring Package', function () use ($command) {
                $this->centralHandler->handle($command);
            });
        }

        $event = $stopwatch->stop();

        $packageRoot = $this->path->joinWithBase(FolderNames::PACKAGE->value, sprintf('%s_%s', $packageName, $this->configReader->getConfig()->romsetName));
        $size = Path::getDirectorySize($packageRoot);

        $io->complete(sprintf("Build complete in %s\n\n(Package Size %s): %s", CommandUtility::formatStopwatchEvent($event), $size, $packageRoot));

        // skipped roms
        $this->generateSkippedRoms($io);

        return Command::SUCCESS;
    }

    private function generateSkippedRoms(BlockSectionHelper $io): void
    {
        $report = $this->skippedRomImportDataGenerator->generate();

        if (!empty($report)) {
            $importCommandName = 'import-skipped';
            $io->help(
                sprintf("Some roms were missing information.\nBlank templates have been generated for you in folder `./%s`. \nFill in missing information and images then import the data with command \n`php bin/console %s` and re-run this generation process", FolderNames::SKIPPED->value, $importCommandName)
            );

            $tableHeader = ['Platform', 'Roms Skipped (Missing)'];
            $tableBody = [];
            foreach ($report as $platform => $count) {
                $tableBody[] = [$platform, $count];
            }

            $io->style()->table(
                $tableHeader,
                $tableBody
            );
        }
    }

    private function getPostProcessCommands(string $packageName, InputInterface $input): array
    {
        $commands = [];

        // artwork
        $postProcessArtwork = $input->getOption('post-process-artwork');

        foreach ($postProcessArtwork as $ppa) {
            $argAndOptions = TokenUtility::splitArgumentAndOptions($ppa);
            $commands = array_merge($commands, $this->commandFactory->createPostProcessCommands(
                $packageName,
                $argAndOptions['argument'],
                CommandNamespace::ARTWORK->value,
                $argAndOptions['options'],
            ));
        }

        // folder
        $postProcessFolder = $input->getOption('post-process-folder');

        foreach ($postProcessFolder as $ppf) {
            $argAndOptions = TokenUtility::splitArgumentAndOptions($ppf);
            $commands = array_merge($commands, $this->commandFactory->createPostProcessCommands(
                $packageName,
                $argAndOptions['argument'],
                CommandNamespace::FOLDER->value,
                $argAndOptions['options'],
            ));
        }

        // @todo portmaster
        $postProcessPortmaster = $input->getOption('post-process-portmaster');

        foreach ($postProcessPortmaster as $ppp) {
            $argAndOptions = TokenUtility::splitArgumentAndOptions($ppp);
            $commands = array_merge($commands, $this->commandFactory->createPostProcessCommands(
                $packageName,
                $argAndOptions['argument'],
                CommandNamespace::PORTMASTER->value,
                $argAndOptions['options'],
            ));
        }

        return $commands;
    }

    private function deleteOutputFolder(): void
    {
        $filesystem = new Filesystem();
        $outputFolder = $this->path->joinWithBase(FolderNames::TEMP->value, 'output');

        if ($filesystem->exists($outputFolder)) {
            $filesystem->remove($outputFolder);
        }

        $tempArtworkPath = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'artwork_tmp'
        );

        if ($filesystem->exists($tempArtworkPath)) {
            $filesystem->remove($tempArtworkPath);
        }
    }

    private function getPreviewCommands(string $packageName, InputInterface $input): array
    {
        $themes = $input->getOption('preview-theme');

        // get package name

        return $this->commandFactory->createGeneratePreviewCommands($packageName, $packageName, $themes);
    }

    private function getArtworkCommands(InputInterface $input): array
    {
        $artwork = $input->getOption('artwork');
        $perRom = $input->getOption('per-rom');

        if (!$artwork) {
            return [];
        }

        $split = TokenUtility::splitStringIntoArtworkPackageAndFileName($artwork);

        return $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
            CommandNamespace::ARTWORK,
            $split['artworkPackage'],
            $split['filename'],
            $this->parseToken($input->getOption('token')),
            $perRom
        );
    }

    private function getFolderCommands(InputInterface $input): array
    {
        $artwork = $input->getOption('folder');
        $perRom = $input->getOption('per-rom');

        if (!$artwork) {
            return [];
        }

        $split = TokenUtility::splitStringIntoArtworkPackageAndFileName($artwork);

        return $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
            CommandNamespace::FOLDER,
            $split['artworkPackage'],
            $split['filename'],
            $this->parseToken($input->getOption('token')),
            $perRom
        );
    }

    private function getPortmasterCommand(InputInterface $input): ?GenerateArtworkCommand
    {
        $artwork = $input->getOption('portmaster');

        if (!$artwork) {
            return null;
        }

        $split = TokenUtility::splitStringIntoArtworkPackageAndFileName($artwork);

        return $this->commandFactory->createGenerateArtworkCommandForPortmaster(
            $split['artworkPackage'],
            $split['filename'],
            $this->parseToken($input->getOption('token'))
        );
    }

    private function parseToken(?string $token): array
    {
        if (!$token) {
            return [];
        }

        return TokenUtility::parseRuntimeTokens($token);
    }

    private function writeCommandStringToFile(InputInterface $input): void
    {
        $filesystem = new Filesystem();
        $commandString = (string) $input;
        $lastRunCommandFile = $this->path->joinWithBase(FolderNames::TEMP->value, 'output', 'LASTRUNCOMMAND');
        if ($filesystem->exists($lastRunCommandFile)) {
            $filesystem->remove($lastRunCommandFile);
        }
        $filesystem->appendToFile($lastRunCommandFile, $commandString);
    }

    private function getArtworkPackageNamesFromInput(InputInterface $input): array
    {
        // to some extent this will validate these arguments as well;

        $vals = [];
        $artwork = $input->getOption('artwork');
        $folder = $input->getOption('folder');
        $portmaster = $input->getOption('portmaster');

        if ($artwork) {
            $vals[] = $artwork;
        }
        if ($folder) {
            $vals[] = $folder;
        }
        if ($portmaster) {
            $vals[] = $portmaster;
        }

        $folders = [];
        foreach ($vals as $v) {
            $t = TokenUtility::splitStringIntoArtworkPackageAndFileName($v);
            $folders[] = $t['artworkPackage'];
        }

        return array_unique($folders);
    }

    /**
     * @return string Package name if set, falling back to artwork/folder/portmaster artwork filename if not set
     */
    private function getPackageName(InputInterface $input): string
    {
        if ($input->getOption('package-name')) {
            return $input->getOption('package-name');
        }

        $vals = [];
        $artwork = $input->getOption('artwork');
        $folder = $input->getOption('folder');
        $portmaster = $input->getOption('portmaster');

        if ($artwork) {
            $vals[] = $artwork;
        }
        if ($folder) {
            $vals[] = $folder;
        }
        if ($portmaster) {
            $vals[] = $portmaster;
        }

        if (empty($vals)) {
            throw new \LogicException('Cannot get package name - no artwork generation params provided');
        }

        $packageAndFilename = TokenUtility::splitStringIntoArtworkPackageAndFileName(reset($vals));

        return sprintf(
            '%s-%s',
            $packageAndFilename['artworkPackage'],
            basename(basename($packageAndFilename['filename'], '.xml'), '.yml')
        );
    }
}
