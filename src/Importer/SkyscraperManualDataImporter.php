<?php

namespace App\Importer;

use App\ApplicationConstant;
use App\Builder\SkyscraperCommandDirector;
use App\Config\Reader\ConfigReader;
use App\Provider\PathProvider;
use App\Util\Path;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Process\Process;

readonly class SkyscraperManualDataImporter
{
    public function __construct(
        private SkyscraperCommandDirector $skyscraperCommandDirector,
        private LoggerInterface $logger,
        private ConfigReader $configReader,
        private Path $path,
        private PathProvider $pathProvider
    ) {
    }

    public function importResources(string $importIn, string $platform): void
    {
        $config = $this->configReader->getConfig();
        $skyscraperConfigFolderPath = $config->skyscraperConfigFolderPath;

        $filesystem = new Filesystem();

        // definitions copy
        $definitionsIn = $this->path->joinWithBase('resources', 'definitions.dat');
        $definitionsOut = Path::join($skyscraperConfigFolderPath, 'import', 'definitions.dat');
        if ($filesystem->exists($definitionsOut)) {
            $filesystem->remove($definitionsOut);
        }
        $filesystem->copy($definitionsIn, $definitionsOut);

        // copy all files from temp to skyscraper first
        $importOut = Path::join($skyscraperConfigFolderPath, 'import', $platform);
        $filesystem->mirror(
            $importIn,
            $importOut
        );

        // get input rom path for platform
        // hack for portmaster
        $inFolder = $this->pathProvider->getPortmasterRomPath();

        if (ApplicationConstant::FAKE_PORTMASTER_PLATFORM !== $platform) {
            $inFolder = Path::join($config->romFolder, $config->getRomFolderForPlatform($platform));
        }

        // run import command to import into cache
        $command = $this->skyscraperCommandDirector->getImportLocalDataCommand(
            $platform,
            $inFolder,
        );

        $process = new Process($command);
        $process->setTimeout(3600);

        $process->run(function ($type, $buffer): void {
            $this->logger->info($buffer);
        });

        // remove from ss import
        $filesystem->remove($importOut);
    }
}
