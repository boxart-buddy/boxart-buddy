<?php

namespace App\ConsoleCommand;

use App\Builder\SkyscraperCommandDirector;
use Monolog\Attribute\WithMonologChannel;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Process\Process;

#[AsCommand(
    name: 'scrape-single',
    description: 'Scrapes for a single rom, used for debugging',
)]
#[WithMonologChannel('skyscraper')]
class ScrapeSingleCommand extends Command
{
    public function __construct(
        readonly private SkyscraperCommandDirector $commandDirector,
        readonly private LoggerInterface $logger
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addArgument('romname', InputArgument::REQUIRED)
            ->addArgument('platform', InputArgument::REQUIRED)
            ->addOption('query', null, InputOption::VALUE_REQUIRED)
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $romname = $input->getArgument('romname');
        $platform = $input->getArgument('platform');
        $query = $input->getOption('query');
        $command = $this->commandDirector->getScrapeCommandForSingleRom(
            $platform,
            $romname,
            false,
            $query
        );

        $process = new Process($command);
        $process->setTimeout(120);
        $process->run(function ($type, $buffer): void {
            $this->logger->info($buffer);
        });

        return Command::SUCCESS;
    }
}
