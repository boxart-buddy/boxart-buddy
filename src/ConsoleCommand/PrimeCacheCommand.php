<?php

namespace App\ConsoleCommand;

use App\Command\Factory\CommandFactory;
use App\Command\Handler\CentralHandler;
use App\Util\Console\BlockSectionHelper;
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
    public function __construct(
        readonly private CommandFactory $commandFactory,
        readonly private CentralHandler $centralHandler
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
        $outputHelper = new BlockSectionHelper($input, $output);

        if ($commands) {
            $outputHelper->section('prime-cache');

            $outputHelper->wait('Priming Cache');

            $progressBar = $outputHelper->getProgressBar();

            foreach ($progressBar->iterate($commands) as $command) {
                $progressBar->setMessage($command->platform);

                $this->centralHandler->handle($command);
            }

            $outputHelper->done('Priming Cache', true);
        }

        return Command::SUCCESS;
    }
}
