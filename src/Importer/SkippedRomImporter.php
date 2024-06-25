<?php

namespace App\Importer;

use App\Builder\SkyscraperCommandDirector;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Generator\SkippedRomImportDataGenerator;
use App\Util\Path;
use Monolog\Attribute\WithMonologChannel;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Process\Process;

#[WithMonologChannel('skyscraper')]
readonly class SkippedRomImporter
{
    public function __construct(
        private LoggerInterface $logger,
        private Path $path,
        private ConfigReader $configReader,
        private SkyscraperCommandDirector $skyscraperCommandDirector
    ) {
    }

    public function import(): void
    {
        $missing = $this->getSkippedRoms();
        $commands = [];

        if (0 === count($missing)) {
            return;
        }

        foreach ($missing as $romName => $data) {
            if (!isset($data['query']) || !isset($data['platform'])) {
                $this->logger->debug(
                    sprintf('Rom `%s` needs to have both query and platform defined. Skipped import', $romName),
                );
                continue;
            }
            // get all commands
            $commands[] = $this->skyscraperCommandDirector->getScrapeCommandForSingleRomWithQuery(
                $data['platform'],
                $romName,
                $data['query'],
                false
            );
        }

        $this->logger->info(sprintf('Importing %s roms from import file', count($commands)));

        // run all commands in process
        foreach ($commands as $command) {
            $this->logger->debug('Manually importing skipped rom with command: `%s`', $command);
            $process = new Process($command);
            $process->setTimeout(120);

            $process->run();

            $this->logger->info($process->getOutput());
        }

        $this->moveMissingToProcessed();
    }

    private function moveMissingToProcessed(): void
    {
        $romsetName = $this->configReader->getConfig()->romsetName;
        $missingJsonPath = $this->path->joinWithBase(FolderNames::SKIPPED->value, $romsetName, SkippedRomImportDataGenerator::ROM_MISSING_JSON);
        $processedFolder = $this->path->joinWithBase(FolderNames::SKIPPED->value, $romsetName, 'processed');
        $processedJsonPath = Path::join($processedFolder, date('d-m-y-His').'-'.SkippedRomImportDataGenerator::ROM_MISSING_JSON);
        $filesystem = new Filesystem();
        if (!$filesystem->exists($processedFolder)) {
            $filesystem->mkdir($processedFolder);
        }
        // $filesystem->rename($missingJsonPath, $processedJsonPath);
    }

    public function getSkippedRoms(): array
    {
        $romsetName = $this->configReader->getConfig()->romsetName;

        $missingJsonPath = $this->path->joinWithBase(FolderNames::SKIPPED->value, $romsetName, SkippedRomImportDataGenerator::ROM_MISSING_JSON);

        if (!file_exists($missingJsonPath)) {
            $this->logger->info('missing.json not found, nothing to import');

            return [];
        }

        $filesystem = new Filesystem();

        try {
            $missing = json_decode($filesystem->readFile($missingJsonPath), true, 512, JSON_THROW_ON_ERROR);
        } catch (\JsonException $e) {
            $this->logger->critical('The missing.json file is malformed. If you have edited it manually please ensure the file contains valid json');
            $this->logger->error($e->getMessage());
            $this->logger->error($e->getFile());
            throw new \RuntimeException('The missing.json file is malformed. If you have edited it manually please ensure the file contains valid json');
        }

        if (0 === count($missing)) {
            $this->logger->debug('missing.json has no entries, nothing to import!');
        }

        return $missing;
    }
}
