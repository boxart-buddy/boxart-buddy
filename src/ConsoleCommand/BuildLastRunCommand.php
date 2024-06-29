<?php

namespace App\ConsoleCommand;

use App\Command\Factory\BuildCommandCollectionFactory;
use App\Command\Handler\CentralHandler;
use App\Config\Validator\ConfigValidator;
use App\ConsoleCommand\Interactive\PromptChoices;
use App\FolderNames;
use App\Provider\PathProvider;
use App\Util\CommandUtility;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Serializer\SerializerInterface;
use Symfony\Component\Stopwatch\Stopwatch;

#[AsCommand(
    name: 'build-last-run',
    description: 'Build artwork by answering questions on the command prompt',
)]
class BuildLastRunCommand extends Command
{
    use PlatformOverviewTrait;

    public function __construct(
        readonly private BuildCommandCollectionFactory $buildCommandCollectionFactory,
        readonly private CentralHandler $centralHandler,
        readonly private LoggerInterface $logger,
        readonly private ConfigValidator $configValidator,
        readonly private Path $path,
        readonly private PathProvider $pathProvider,
        readonly private SerializerInterface $serializer,
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new BlockSectionHelper($input, $output, $this->logger);
        $io->heading();
        $this->printPlatformOverview($io, $this->configValidator);
        $stopwatch = (new Stopwatch())->start('all');

        $filesystem = new Filesystem();
        $lastRunChoicesFile = $this->path->joinWithBase(FolderNames::TEMP->value, 'LASTRUNCHOICES.json');

        if (!$filesystem->exists($lastRunChoicesFile)) {
            $io->failure('LASTRUNCHOICES.json does not exist, you need to run `make build` at least once');
        }

        $choices = $this->serializer->deserialize($filesystem->readFile($lastRunChoicesFile), PromptChoices::class, 'json');

        $io->section('build-choices');
        $io->help("Building with last run choices:\n\n".$choices->prettyPrint());

        $buildCommandCollection = $this->buildCommandCollectionFactory->create($choices);
        $this->centralHandler->handleBuildCommandCollection($buildCommandCollection);

        $packageName = $this->buildCommandCollectionFactory->getPackageName($choices);
        $packageRoot = $this->pathProvider->getPackageRootPath($packageName);

        $event = $stopwatch->stop();
        $size = Path::getDirectorySize($packageRoot);
        $io->complete(sprintf("Build complete in %s\n\n(Package Size %s): %s", CommandUtility::formatStopwatchEvent($event), $size, $packageRoot));

        return Command::SUCCESS;
    }
}
