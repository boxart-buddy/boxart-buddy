<?php

namespace App\Model;

use Symfony\Component\PropertyAccess\PropertyAccess;

readonly class Config
{
    public static function fromArray(array $c): Config
    {
        $propertyAccessor = PropertyAccess::createPropertyAccessor();

        return new self(
            $c['rom_folder'],
            $c['romset_name'],
            $c['screenscraper_user'],
            $c['screenscraper_pass'],
            $c['skyscraper_config_folder_path'],
            $c['platforms'],
            $c['package'],
            $c['folder_roms'],
            $c['portmaster'],
            $propertyAccessor->getValue($c, '[optimize][enabled]'),
            $propertyAccessor->getValue($c, '[optimize][convert_to_jpg]'),
            $propertyAccessor->getValue($c, '[optimize][jpg_quality]'),
            $propertyAccessor->getValue($c, '[preview][type]'),
            $propertyAccessor->getValue($c, '[preview][grid_size]'),
            $propertyAccessor->getValue($c, '[preview][animation_frames]'),
            $propertyAccessor->getValue($c, '[sftp?][ip]'),
            $propertyAccessor->getValue($c, '[sftp?][user]'),
            $propertyAccessor->getValue($c, '[sftp?][pass]'),
            $propertyAccessor->getValue($c, '[sftp?][port]'),
        );
    }

    public function __construct(
        public string $romFolder,
        public string $romsetName,
        private string $screenScraperUser,
        private string $screenScraperPassword,
        public string $skyscraperConfigFolderPath,
        public array $platforms,
        public array $package,
        public array $folderRoms,
        public array $portmaster,
        public bool $shouldOptimize,
        public bool $convertToJpg,
        public int $jpgQuality,
        public string $previewType,
        public int $previewGridSize,
        public int $animationFrames,
        public ?string $sftpIp,
        public ?string $sftpUser,
        public ?string $sftpPass,
        public ?string $sftpPort,
    ) {
    }

    public function getScreenScraperCredentials(): string
    {
        return sprintf(
            '%s:%s',
            $this->screenScraperUser,
            $this->screenScraperPassword
        );
    }

    public function getRomFolderForPlatform(string $platform): string
    {
        if (!array_key_exists($platform, $this->platforms)) {
            throw new \InvalidArgumentException(sprintf('Platform "%s" does not exist in the platform mapping.', $platform));
        }

        return $this->platforms[$platform];
    }

    public function getSingleRomForFolder(string $platform): ?string
    {
        if (isset($this->folderRoms[$platform])) {
            return $this->folderRoms[$platform];
        }

        return null;
    }
}
