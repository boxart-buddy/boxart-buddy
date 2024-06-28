<?php

namespace App\ConsoleCommand;

use App\Command\Factory\CommandFactory;
use App\Command\Handler\CentralHandler;
use App\Config\Validator\ConfigValidator;
use App\Portmaster\PortmasterDataImporter;
use App\Util\Console\BlockSectionHelper;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'prime-cache',
    description: 'Scrapes artwork using Skyscraper (from Screenscraper.fr)',
    aliases: ['scrape']
)]
class PrimeCacheCommand extends Command
{
    use PlatformOverviewTrait;

    public function __construct(
        readonly private CommandFactory $commandFactory,
        readonly private CentralHandler $centralHandler,
        readonly private ConfigValidator $configValidator,
        readonly private LoggerInterface $logger,
        readonly private PortmasterDataImporter $portmasterDataImporter
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        if (!$output instanceof ConsoleOutput) {
            throw new \RuntimeException();
        }

        $commands = $this->commandFactory->createPrimeCacheCommandsForAllPlatforms();
        $io = new BlockSectionHelper($input, $output, $this->logger);
        $io->heading();
        $this->printPlatformOverview($io, $this->configValidator);

        if ($commands) {
            $io->section('prime-cache');

            $io->wait('Priming Cache (using screenscraper) (SLOW ON FIRST RUN)');

            $progressBar = $io->getProgressBar();

            foreach ($progressBar->iterate($commands) as $command) {
                $progressBar->setMessage($command->platform);

                $this->centralHandler->handle($command);
            }

            $io->complete('Scraping for platforms complete', true);
        }

        $io->section('prime-cache-screenscraper-alternates');
        $io->wait('Scraping for portmaster alternates');
        try {
            $this->portmasterDataImporter->scrapeUsingAlternatesList();
            $io->complete('Scraping for portmaster alternates complete', true);
        } catch (\Throwable $exception) {
            $io->failure('Scraping for portmaster alternates failed', true);
        }

        return Command::SUCCESS;
    }
}
