<?php

namespace App\ConsoleCommand;

use App\Command\Factory\BuildCommandCollectionFactory;
use App\Command\Handler\CentralHandler;
use App\Config\Validator\ConfigValidator;
use App\ConsoleCommand\Interactive\PromptChoices;
use App\ConsoleCommand\Interactive\PromptOptionsGenerator;
use App\Provider\PathProvider;
use App\Util\CommandUtility;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Stopwatch\Stopwatch;

use function Laravel\Prompts\multiselect;
use function Laravel\Prompts\select;

#[AsCommand(
    name: 'build-interactive',
    description: 'Build artwork by answering questions on the command prompt',
)]
class BuildInteractiveCommand extends Command
{
    use PlatformOverviewTrait;

    public function __construct(
        readonly private PromptOptionsGenerator $promptOptionsGenerator,
        readonly private BuildCommandCollectionFactory $buildCommandCollectionFactory,
        readonly private CentralHandler $centralHandler,
        readonly private LoggerInterface $logger,
        readonly private ConfigValidator $configValidator,
        readonly private PathProvider $pathProvider,
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

        $options = $this->promptOptionsGenerator->generate();

        // yml to option parser
        $package = (string) select(
            'Select Template',
            $options->getPackages(),
        );

        $variant = (string) select(
            'Select Variant',
            $options->getVariants($package),
        );

        $optionChoices = multiselect(
            'Select Options (spacebar to select, enter to confirm)',
            $options->getOptions($package, $variant),
            $options->getOptionDefaults($package, $variant),
        );

        $artwork = $folder = $portmaster = $zip = $transfer = false;

        foreach ($optionChoices as $o) {
            if ('artwork' === $o) {
                $artwork = true;
            }
            if ('folder' === $o) {
                $folder = true;
            }
            if ('portmaster' === $o) {
                $portmaster = true;
            }
            if ('zip' === $o) {
                $zip = true;
            }
            if ('transfer' === $o) {
                $transfer = true;
            }
        }

        $choices = new PromptChoices($package, $variant, $artwork, $folder, $portmaster, $zip, $transfer);

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
