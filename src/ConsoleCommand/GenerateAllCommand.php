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
use App\FolderNames;
use App\Portmaster\PortmasterDataImporter;
use App\Util\CommandUtility;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use App\Util\TokenUtility;
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
    public function __construct(
        readonly private CommandFactory $commandFactory,
        readonly private CentralHandler $centralHandler,
        readonly private PortmasterDataImporter $portmasterDataImporter,
        readonly private Path $path
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addOption('artwork', 'a', InputOption::VALUE_REQUIRED, 'Filename for artwork.xml or mapping.yml you want to use to generate ROM artwork')
            ->addOption('folder', 'f', InputOption::VALUE_REQUIRED, 'Filename for artwork.xml or mapping.yml you want to use to generate FOLDER artwork')
            ->addOption('portmaster', 'pm', InputOption::VALUE_REQUIRED, 'Filename for artwork.xml you want to use to generate PORTMASTER artwork')
            ->addOption('zip', 'z', InputOption::VALUE_NONE, 'Creates a zip archive of the generated package')
            ->addOption('transfer', 'trns', InputOption::VALUE_NONE, 'Attempts to transfer the generated artwork to your device using sftp')
            ->addOption('package-name', 'pkg', InputOption::VALUE_REQUIRED, 'A name for the output package. Will be appended with the configured `romset_name`. If not set will default to the same name as the artwork used.')
            ->addOption('preview-theme', 'pt', InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'Name of theme used during preview generation')
            ->addOption('preview-grid-size', 'pgs', InputOption::VALUE_REQUIRED, 'Size of the preview grid', 3)
            ->addOption('token', 'tkn', InputOption::VALUE_REQUIRED, 'Pass translations to artwork templates at runtime. Accepts a JSON string or key/value pairs in the format: key:value|key2:value2|key3:value3')
            ->addOption('post-process-artwork', 'ppa', InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'A post processing strategy to use on generated rom artwork')
            ->addOption('post-process-folder', 'ppf', InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'A post processing strategy to use on generated folder artwork')
            ->addOption('post-process-portmaster', 'ppp', InputOption::VALUE_REQUIRED | InputOption::VALUE_IS_ARRAY, 'A post processing strategy to use on generated portmaster artwork')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        if (!$output instanceof ConsoleOutput) {
            throw new \RuntimeException();
        }

        // dump out the current command string so that it can be used later during asset packaging
        $this->writeCommandStringToFile($input);
        $outputHelper = new BlockSectionHelper($input, $output);
        $stopwatch = (new Stopwatch())->start('all');
        $this->deleteOutputFolder();

        // copy resources
        $command = new CopyResourcesCommand($this->getArtworkPackageNamesFromInput($input));
        $outputHelper->waitOrFail('copy-resources', 'Copying Custom Resources to Skyscraper Folder', function () use ($command) {
            $this->centralHandler->handle($command);
        });

        // artwork
        $commands = $this->getArtworkCommands($input);

        if ($commands) {
            $outputHelper->waitOrFailTargetableCommandsWithProgressBar(
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
            $outputHelper->waitOrFailTargetableCommandsWithProgressBar(
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
            $outputHelper->waitOrFail('import-portmaster-data', 'Importing Portmaster Data', function () use ($portmasterDataImporter) {
                $portmasterDataImporter->importPortmasterDataIfNotImportedSince(new \DateInterval('P1D'));
            });

            $outputHelper->waitOrFail('generate-portmaster-artwork', 'Generating Portmaster Artwork', function () use ($command) {
                $this->centralHandler->handle($command);
            });
        }

        $packageName = $this->getPackageName($input);

        // package
        $command = new PackageCommand($packageName);
        $outputHelper->waitOrFail('package', 'Packaging', function () use ($command) {
            $this->centralHandler->handle($command);
        });

        // post process
        $commands = $this->getPostProcessCommands($packageName, $input);
        if ($commands) {
            $outputHelper->waitOrFailTargetableCommandsWithProgressBar(
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
            $outputHelper->waitOrFailTargetableCommandsWithProgressBar(
                'generate-previews',
                'Generating Previews',
                $commands,
                function ($command) {
                    $this->centralHandler->handle($command);
                }
            );
        }

        // optimize
        $command = $this->commandFactory->createOptimizeCommand($packageName);
        $outputHelper->waitOrFail('optimize', 'Optimizing Images', function () use ($command) {
            $this->centralHandler->handle($command);
        });

        // zip
        if ($input->getOption('zip')) {
            $command = new CompressPackageCommand($packageName);
            $outputHelper->waitOrFail('compress-package', 'Compressing Package', function () use ($command) {
                $this->centralHandler->handle($command);
            });
        }

        // transfer
        if ($input->getOption('transfer')) {
            $command = new TransferCommand($packageName);
            $outputHelper->waitOrFail('transfer-package', 'Transferring Package', function () use ($command) {
                $this->centralHandler->handle($command);
            });
        }

        $event = $stopwatch->stop();

        $outputHelper->complete(sprintf('Build complete in %s', CommandUtility::formatStopwatchEvent($event)));

        return Command::SUCCESS;
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
        $gridSize = $input->getOption('preview-grid-size');
        $themes = $input->getOption('preview-theme');

        // get package name
        $previewName = $input->getOption('package-name') ?: basename($input->getOption('artwork'), '.xml');

        return $this->commandFactory->createGeneratePreviewCommands($packageName, $previewName, $themes, $gridSize);
    }

    private function getArtworkCommands(InputInterface $input): array
    {
        $artwork = $input->getOption('artwork');

        if (!$artwork) {
            return [];
        }

        $split = $this->splitStringIntoArtworkPackageAndFileName($artwork);

        return $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
            CommandNamespace::ARTWORK,
            $split['artworkPackage'],
            $split['filename'],
            $this->parseToken($input->getOption('token'))
        );
    }

    private function getFolderCommands(InputInterface $input): array
    {
        $artwork = $input->getOption('folder');

        if (!$artwork) {
            return [];
        }

        $split = $this->splitStringIntoArtworkPackageAndFileName($artwork);

        return $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
            CommandNamespace::FOLDER,
            $split['artworkPackage'],
            $split['filename'],
            $this->parseToken($input->getOption('token'))
        );
    }

    private function getPortmasterCommand(InputInterface $input): ?GenerateArtworkCommand
    {
        $artwork = $input->getOption('portmaster');

        if (!$artwork) {
            return null;
        }

        $split = $this->splitStringIntoArtworkPackageAndFileName($artwork);

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
            $t = $this->splitStringIntoArtworkPackageAndFileName($v);
            $folders[] = $t['artworkPackage'];
        }

        return array_unique($folders);
    }

    private function splitStringIntoArtworkPackageAndFileName(string $input): array
    {
        $token = TokenUtility::parseRuntimeTokens($input);
        if (1 !== count($token)) {
            throw new \InvalidArgumentException(sprintf('Argument must be of form `your-template:artwork-name.xml` or `your-template:mapping-name.yml`. Given value was `%s`', $input));
        }

        $packageName = key($token);
        $filename = reset($token);

        if (!in_array(pathinfo($filename, PATHINFO_EXTENSION), ['yml', 'xml'])) {
            throw new \InvalidArgumentException(sprintf('Argument must end with `.xml` or `.yml`. `%s` given', $filename));
        }

        return [
            'artworkPackage' => $packageName,
            'filename' => $filename,
        ];
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

        $filename = $this->splitStringIntoArtworkPackageAndFileName(reset($vals))['filename'];

        return basename(basename($filename, '.xml'), '.yml');
    }
}
