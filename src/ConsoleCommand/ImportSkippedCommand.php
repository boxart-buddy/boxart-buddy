<?php

namespace App\ConsoleCommand;

use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Importer\SkyscraperManualDataImporter;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;

#[AsCommand(
    name: 'import-skipped',
    description: 'Imports `skipped` roms from the skipped folder into the cache',
)]
class ImportSkippedCommand extends Command
{
    public function __construct(
        readonly private SkyscraperManualDataImporter $skyscraperManualDataImporter,
        readonly private Path $path,
        readonly private ConfigReader $configReader
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new BlockSectionHelper($input, $output);
        $io->heading();
        $filesystem = new Filesystem();

        $config = $this->configReader->getConfig();
        $romsetName = $config->romsetName;
        $platforms = $config->platforms;

        $io->section('import');
        $progressBar = $io->getProgressBar();

        $io->wait('Importing skipped data to skyscraper');

        $importPaths = [];
        foreach ($platforms as $platform => $romFolder) {
            $in = $this->path->joinWithBase(FolderNames::SKIPPED->value, $romsetName, $platform);
            if (!$filesystem->exists($in)) {
                continue;
            }

            $importPaths[$platform] = $in;
        }

        if (empty($importPaths)) {
            $io->complete('Nothing to import', true);

            return Command::SUCCESS;
        }

        foreach ($progressBar->iterate($importPaths) as $platform => $path) {
            $progressBar->setMessage($platform);
            $this->skyscraperManualDataImporter->importResources($path, $platform);
        }

        $io->complete('Import Complete', true);

        return Command::SUCCESS;
    }
}
