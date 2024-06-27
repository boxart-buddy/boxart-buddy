<?php

namespace App\ConsoleCommand;

use App\Command\CommandNamespace;
use App\Command\Factory\BuildCommandCollectionFromInputFactory;
use App\Command\Factory\CommandFactory;
use App\Command\Handler\CentralHandler;
use App\Config\Reader\ConfigReader;
use App\Config\Validator\ConfigValidator;
use App\FolderNames;
use App\Portmaster\PortmasterDataImporter;
use App\Provider\PathProvider;
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
        readonly private PathProvider $pathProvider,
        readonly private ConfigValidator $configValidator,
        readonly private ConfigReader $configReader,
        readonly private LoggerInterface $logger,
        readonly private BuildCommandCollectionFromInputFactory $buildCommandCollectionFactory
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addArgument('template', null, 'The template package folder being used (e.g "artbook-next")')
            ->addOption('artwork', null, InputOption::VALUE_REQUIRED, '{artwork.xml} or {artwork.yml} used to generate ROM artwork')
            ->addOption('folder', null, InputOption::VALUE_REQUIRED, '{artwork.xml} or {artwork.yml} used to generate FOLDER artwork')
            ->addOption('portmaster', null, InputOption::VALUE_REQUIRED, '{artwork.xml} or {artwork.yml} used to generate PORTMASTER artwork')
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
        if (!$output instanceof ConsoleOutput) {
            throw new \RuntimeException();
        }

        $io = new BlockSectionHelper($input, $output, $this->logger);
        $io->heading();
        $this->printPlatformOverview($io, $this->configValidator);
        $stopwatch = (new Stopwatch())->start('all');

        // dump out the current command string so that it can be used later during asset packaging
        $this->writeCommandStringToFile($input);

        $buildCommandCollection = $this->buildCommandCollectionFactory->create($input);
        $this->centralHandler->handleBuildCommandCollection($buildCommandCollection);

        $packageName = BuildCommandCollectionFromInputFactory::getPackageName($input);
        $packageRoot = $this->pathProvider->getPackageRootPath($packageName);

        $event = $stopwatch->stop();
        $size = Path::getDirectorySize($packageRoot);
        $io->complete(sprintf("Build complete in %s\n\n(Package Size %s): %s", CommandUtility::formatStopwatchEvent($event), $size, $packageRoot));

        // skipped roms
        // $this->readSkippedRomReport($io);

        return Command::SUCCESS;
    }

    //    private function readSkippedRomReport(BlockSectionHelper $io): void
    //    {
    //        // read the skipped rom file and report back to use next steps to take
    //    }

    //    private function deleteOutputFolder(): void
    //    {
    //        $filesystem = new Filesystem();
    //        $outputFolder = $this->path->joinWithBase(FolderNames::TEMP->value, 'output');
    //
    //        if ($filesystem->exists($outputFolder)) {
    //            $filesystem->remove($outputFolder);
    //        }
    //
    //        $tempArtworkPath = $this->path->joinWithBase(
    //            FolderNames::TEMP->value,
    //            'artwork_tmp'
    //        );
    //
    //        if ($filesystem->exists($tempArtworkPath)) {
    //            $filesystem->remove($tempArtworkPath);
    //        }
    //    }
    //
    //    private function getPreviewCommands(string $packageName, InputInterface $input): array
    //    {
    //        $themes = $input->getOption('preview-theme') ?: [];
    //
    //        // get package name
    //
    //        return $this->commandFactory->createGeneratePreviewCommands($packageName, $packageName, $themes);
    //    }
    //
    //    private function getArtworkCommands(InputInterface $input): array
    //    {
    //        $artwork = $input->getOption('artwork');
    //        $perRom = $input->getOption('per-rom');
    //
    //        if (!$artwork) {
    //            return [];
    //        }
    //
    //        $split = TokenUtility::splitStringIntoArtworkPackageAndFileName($artwork);
    //
    //        return $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
    //            CommandNamespace::ARTWORK,
    //            $split['artworkPackage'],
    //            $split['filename'],
    //            $this->parseToken($input->getOption('token')),
    //            true,
    //            $perRom
    //        );
    //    }
    //
    //    private function getFolderCommands(InputInterface $input): array
    //    {
    //        $artwork = $input->getOption('folder');
    //        $perRom = $input->getOption('per-rom');
    //        $addPortmasterPlatform = false;
    //        if ($input->getOption('portmaster')) {
    //            $addPortmasterPlatform = true;
    //        }
    //
    //        if (!$artwork) {
    //            return [];
    //        }
    //
    //        $split = TokenUtility::splitStringIntoArtworkPackageAndFileName($artwork);
    //
    //        return $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
    //            CommandNamespace::FOLDER,
    //            $split['artworkPackage'],
    //            $split['filename'],
    //            $this->parseToken($input->getOption('token')),
    //            false,
    //            $perRom,
    //            $addPortmasterPlatform
    //        );
    //    }
    //
    //    private function getPortmasterCommands(InputInterface $input): array
    //    {
    //        $artwork = $input->getOption('portmaster');
    //
    //        if (!$artwork) {
    //            return [];
    //        }
    //
    //        $split = TokenUtility::splitStringIntoArtworkPackageAndFileName($artwork);
    //
    //        return $this->commandFactory->createGenerateArtworkCommandForPortmaster(
    //            $split['artworkPackage'],
    //            $split['filename'],
    //            $this->parseToken($input->getOption('token'))
    //        );
    //    }
    //
    //    private function parseToken(?string $token): array
    //    {
    //        if (!$token) {
    //            return [];
    //        }
    //
    //        return TokenUtility::parseRuntimeTokens($token);
    //    }

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

    // Gets the template folders being used in current generation, to load tokens and resources etc

    /*
     * @return string Package name if set, falling back to artwork/folder/portmaster artwork filename if not set
     */
}
