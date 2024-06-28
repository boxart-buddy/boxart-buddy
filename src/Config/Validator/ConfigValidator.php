<?php

namespace App\Config\Validator;

use App\Config\InvalidConfigException;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Skyscraper\RomExtensionProvider;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

class ConfigValidator
{
    public function __construct(
        private ConfigReader $configReader,
        private RomExtensionProvider $romExtensionProvider
    ) {
    }

    /**
     * @throws InvalidConfigException
     */
    public function validateFoldersExist(): void
    {
        $filesystem = new Filesystem();
        $config = $this->configReader->getConfig();
        $platforms = $config->platforms;
        $romFolder = $config->romFolder;
        if (0 === count($platforms)) {
            throw new InvalidConfigException(sprintf('No platforms have been defined, you must set at least platform in `%s`', Path::join(FolderNames::USER_CONFIG->value, 'config_platform.yml')));
        }

        if (!$filesystem->exists(Path::join($romFolder))) {
            throw new InvalidConfigException(sprintf('Configured `rom_folder`: `%s` does not exist', $romFolder));
        }

        foreach ($platforms as $platform => $folder) {
            if (!$filesystem->exists(Path::join($romFolder, $folder))) {
                throw new InvalidConfigException(sprintf('Configured folder for `%s`: `%s` does not exist', $platform, $folder));
            }
        }
    }

    /**
     * @throws InvalidConfigException
     */
    public function getPlatformReport()
    {
        $this->validateFoldersExist();
        $config = $this->configReader->getConfig();
        $platforms = $config->platforms;
        $romFolder = $config->romFolder;

        $report = [];
        foreach ($platforms as $platform => $folder) {
            $finder = new Finder();
            $finder->in(Path::join($romFolder, $folder))->files();
            $this->romExtensionProvider->addRomExtensionsToFinder($finder, $platform);
            $count = count($finder);
            $report[$platform] = [
                'folder' => $folder,
                'count' => $count,
            ];
        }

        return $report;
    }
}
