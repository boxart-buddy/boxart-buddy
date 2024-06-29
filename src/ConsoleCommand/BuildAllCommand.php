<?php

namespace App\ConsoleCommand;

use App\Command\Factory\BuildCommandCollectionFactory;
use App\Command\Handler\CentralHandler;
use App\Config\Validator\ConfigValidator;
use App\ConsoleCommand\Interactive\PromptChoices;
use App\ConsoleCommand\Interactive\PromptOptionsGenerator;
use App\Util\Console\BlockSectionHelper;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'build-all',
    description: 'Builds every template/variant with default options',
)]
class BuildAllCommand extends Command
{
    use PlatformOverviewTrait;

    public function __construct(
        readonly private PromptOptionsGenerator $promptOptionsGenerator,
        readonly private BuildCommandCollectionFactory $buildCommandCollectionFactory,
        readonly private CentralHandler $centralHandler,
        readonly private LoggerInterface $logger,
        readonly private ConfigValidator $configValidator
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addOption('template', 't', InputOption::VALUE_REQUIRED, 'a template, if provided then build will be restricted to that template only')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new BlockSectionHelper($input, $output, $this->logger);
        $io->heading();
        $this->printPlatformOverview($io, $this->configValidator);

        $options = $this->promptOptionsGenerator->generate();

        $template = $input->getOption('template');

        if ($template && !in_array($template, $options->getPackages(), true)) {
            throw new \InvalidArgumentException(sprintf('Invalid template: %s', $template));
        }

        foreach ($options->getPackages() as $package) {
            if ($template && $template !== $package) {
                continue;
            }
            foreach ($options->getVariants($package) as $variant => $variantDescription) {
                $defaultOptions = $options->getOptionDefaults($package, $variant);
                $artwork = $folder = $portmaster = $zip = $transfer = false;

                foreach ($defaultOptions as $o) {
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
            }
        }

        $io->complete('Complete');

        return Command::SUCCESS;
    }
}
