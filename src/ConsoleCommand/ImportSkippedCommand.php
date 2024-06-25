<?php

namespace App\ConsoleCommand;

use App\Importer\SkippedRomImporter;
use App\Util\Console\BlockSectionHelper;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'import-skipped',
    description: 'Imports `skipped` roms from the skipped folder into the cache',
)]
class ImportSkippedCommand extends Command
{
    public function __construct(
        readonly private LoggerInterface $logger,
        readonly private SkippedRomImporter $skippedRomImporter,
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

        $io->section('import');

        $io->wait('Importing skipped data to skyscraper');

        try {
            $this->skippedRomImporter->import();
        } catch (\Throwable $e) {
            $io->failure($e->getMessage(), true);

            return Command::FAILURE;
        }

        $io->complete('Import Complete', true);

        return Command::SUCCESS;
    }
}
