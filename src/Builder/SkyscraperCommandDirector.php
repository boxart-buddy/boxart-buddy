<?php

namespace App\Builder;

use App\ApplicationConstant;
use App\Config\Reader\ConfigReader;
use App\Provider\PathProvider;
use App\Util\Finder;
use App\Util\Path;

readonly class SkyscraperCommandDirector
{
    public function __construct(
        private ConfigReader $configReader,
        private PathProvider $pathProvider
    ) {
    }

    public function getScrapeCommand(string $platform): array
    {
        $commandBuilder = new SkyscraperCommandBuilder();

        $config = $this->configReader->getConfig();

        $inFolder = Path::join($config->romFolder, $config->getRomFolderForPlatform($platform));

        $commandBuilder->setCredentials($config->getScreenScraperCredentials())
            ->addFlag('unattend')
            ->addFlag('unpack')
            ->addFlag('nohints')
            ->setPlatform($platform)
            ->setScraper('screenscraper')
            ->setInputPath($inFolder);

        return $commandBuilder->build();
    }

    public function getImportLocalDataCommand(
        string $platform,
        string $inputPath
    ): array {
        $commandBuilder = new SkyscraperCommandBuilder();
        $commandBuilder
            ->setScraper('import')
            ->setPlatform($platform)
            ->setInputPath($inputPath);

        return $commandBuilder->build();
    }

    public function getBoxartGenerateCommand(
        string $platform,
        string $namespace,
        string $artworkPath,
        bool $singleRomOnly = false,
        ?string $romName = null
    ): array {
        $outFolder = $this->pathProvider->getOutputPathForGeneratedArtwork($namespace, $platform);

        $config = $this->configReader->getConfig();

        // hack for portmaster
        $inFolder = $this->pathProvider->getPortmasterRomPath();
        if (ApplicationConstant::FAKE_PORTMASTER_PLATFORM !== $platform) {
            $inFolder = Path::join($config->romFolder, $config->getRomFolderForPlatform($platform));
        }

        $commandBuilder = new SkyscraperCommandBuilder();
        $commandBuilder->setArtworkPath($artworkPath)
            ->setInputPath($inFolder)
            ->setOutputPath($outFolder)
            ->setGamelistPath($this->pathProvider->getGamelistPath($namespace, $platform))
            ->setPlatform($platform)
            ->addFlag('unattend')
            ->addFlag('unpack')
            ->addFlag('nohints')
            ->setVerbosity(3);

        if ($singleRomOnly) {
            $rom = $romName ?? $this->getSingleRom($inFolder, $platform);
            $commandBuilder->setRomName($rom);
        }

        return $commandBuilder->build();
    }

    private function getSingleRom(string $folder, string $platform): string
    {
        // try to match with the configured rom name if provided
        $singleRom = $this->configReader->getConfig()->getSingleRomForFolder($platform);
        $finder = new Finder();
        $finder->in($folder);
        $finder->files()->name($singleRom.'.*');

        if ($finder->hasResults()) {
            return $finder->first()->getFilename();
        }

        // if nothing found or configured then just return the first found

        $finder = new Finder();
        $finder->in($folder);

        // some allowances for dirty rom folders
        $finder->files()->notName(ApplicationConstant::EXCLUDE_FROM_ROM_SEARCH);

        if (!$finder->hasResults()) {
            throw new \RuntimeException(sprintf('Cannot get single ROM from `%s`, no files in this location', $folder));
        }

        return $finder->first()->getFilename();
    }
}
