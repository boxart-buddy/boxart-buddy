<?php

namespace App\Command\Factory;

use App\ApplicationConstant;
use App\Command\CommandNamespace;
use App\Command\GenerateAnimatedPreviewCommand;
use App\Command\GenerateArtworkCommand;
use App\Command\GenerateStaticPreviewCommand;
use App\Command\OptimizeCommand;
use App\Command\PostProcessCommand;
use App\Command\PrimeCacheCommand;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Provider\OrderedListProvider;
use App\Provider\PathProvider;
use App\Util\Path;
use Symfony\Component\Finder\Finder;

readonly class CommandFactory
{
    public function __construct(
        private ConfigReader $configReader,
        private Path $path,
        private OrderedListProvider $orderedListProvider,
        private PathProvider $pathProvider
    ) {
    }

    public function createOptimizeCommand(string $package): OptimizeCommand
    {
        $config = $this->configReader->getConfig();
        $targetBase = $this->path->joinWithBase(
            FolderNames::PACKAGE->value,
            sprintf('%s_%s', $package, $config->romsetName),
        );

        return new OptimizeCommand($targetBase, $config->convertToJpg, $config->jpgQuality);
    }

    public function createPostProcessCommands(string $package, string $strategy, string $targetNamespace, array $options): array
    {
        $commands = [];
        $config = $this->configReader->getConfig();

        $targetBase = $this->path->joinWithBase(
            FolderNames::PACKAGE->value,
            sprintf('%s_%s', $package, $config->romsetName),
            'MUOS',
            'info',
            'catalogue',
        );

        if ($targetNamespace === CommandNamespace::FOLDER->value) {
            $target = Path::join($targetBase, 'Folder', 'box');
            $options['sort_order'] = $this->orderedListProvider->getOrderedList(CommandNamespace::FOLDER);

            return [new PostProcessCommand($target, $strategy, $options)];
        }

        if ($targetNamespace === CommandNamespace::PORTMASTER->value) {
            $target = Path::join($targetBase, 'External - Ports', 'box');

            return [new PostProcessCommand($target, $strategy, $options)];
        }

        // some platforms share an output/package folder, so we combine those to reduce the number of
        // post-processing passes where the 'target' is the same
        $targets = [];
        $targetPlatforms = [];
        foreach ($config->platforms as $platform => $folder) {
            $target = Path::join($targetBase, $config->package[$platform], 'box');
            $targets[] = $target;
            $targetPlatforms[$target][] = $platform;
        }

        foreach ($targets as $target) {
            $options['sort_order'] = $this->orderedListProvider->getOrderedList(CommandNamespace::ARTWORK, $target);
            $commands[] = new PostProcessCommand($target, $strategy, $options, $targetPlatforms[$target]);
        }

        return $commands;
    }

    public function createGeneratePreviewCommands(string $package, string $previewName, array $themes): array
    {
        // always generate a 'no-theme' version
        if (!array_search(false, $themes, true)) {
            $themes[] = false;
        }

        $config = $this->configReader->getConfig();

        $target = $this->path->joinWithBase(
            FolderNames::PACKAGE->value,
            sprintf('%s_%s', $package, $config->romsetName)
        );

        $commands = [];

        if (1 === count($themes)) {
            $themes = $this->configReader->getConfig()->previewThemes;
        }

        foreach ($themes as $theme) {
            if (in_array($this->configReader->getConfig()->previewType, ['static', 'both'])) {
                $commands[] = new GenerateStaticPreviewCommand($target, $previewName, $theme);
            }
            if (in_array($this->configReader->getConfig()->previewType, ['animated', 'both'])) {
                $commands[] = new GenerateAnimatedPreviewCommand($target, $previewName, $theme);
            }
        }

        return $commands;
    }

    public function createGenerateArtworkCommandForPortmaster(
        string $artworkPackage,
        string $artworkFilename,
        array $tokens
    ): array {
        $portmasterAlternates = $this->configReader->getConfig()->portmasterAlternates;

        // iterate roms folder
        $commands = [];

        $inFolder = $this->pathProvider->getPortmasterRomPath();
        $finder = new Finder();
        $finder->in($inFolder)->files();

        foreach ($finder as $file) {
            $gameName = $file->getFilenameWithoutExtension();

            // change platform if alternate exists
            $platform = $portmasterAlternates[$gameName]['platform'] ?? ApplicationConstant::FAKE_PORTMASTER_PLATFORM;

            $commands[] = new GenerateArtworkCommand(
                CommandNamespace::PORTMASTER->value,
                $artworkPackage,
                $artworkFilename,
                null,
                $platform,
                $tokens,
                true,
                true,
                $file->getFilename()
            );
        }

        return $commands;
    }

    public function createPrimeCacheCommandsForAllPlatforms(): array
    {
        $commands = [];
        foreach ($this->configReader->getConfig()->platforms as $platform => $romFolder) {
            $commands[] = new PrimeCacheCommand($platform);
        }

        return $commands;
    }

    public function createGenerateArtworkCommandsForAllPlatforms(
        CommandNamespace $namespace,
        string $artworkPackage,
        string $filename,
        array $tokens,
        bool $generateDescriptions,
        bool $perRom,
        bool $addPortmasterPlatform = false // this is a horrible hack
    ): array {
        $platforms = $this->configReader->getConfig()->platforms;
        if ($addPortmasterPlatform) {
            $platforms[ApplicationConstant::FAKE_PORTMASTER_PLATFORM] = ApplicationConstant::FAKE_PORTMASTER_PLATFORM;
        }

        return $this->createGenerateArtworkCommandsForPlatforms(
            $namespace,
            $artworkPackage,
            $filename,
            $tokens,
            $generateDescriptions,
            $perRom,
            array_keys($platforms)
        );
    }

    public function createGenerateArtworkCommandsForPlatforms(
        CommandNamespace $namespace,
        string $artworkPackage,
        string $filename,
        array $tokens,
        bool $generateDescriptions,
        bool $perRom,
        array $platforms
    ): array {
        $commands = [];

        foreach ($platforms as $platform) {
            $commands = array_merge(
                $commands,
                $this->createGenerateArtworkCommandsForOnePlatform(
                    $namespace,
                    $artworkPackage,
                    $filename,
                    $tokens,
                    $generateDescriptions,
                    $perRom,
                    $platform
                )
            );
        }

        return $commands;
    }

    public function createGenerateArtworkCommandsForOnePlatform(
        CommandNamespace $namespace,
        string $artworkPackage,
        string $filename,
        array $tokens,
        bool $generateDescriptions,
        bool $perRom,
        string $platform
    ): array {
        $single = false;
        if (CommandNamespace::FOLDER === $namespace || $perRom) {
            $single = true;
        }

        $commands = [];

        $artwork = 'xml' === pathinfo($filename, PATHINFO_EXTENSION) ? $filename : null;
        $mapping = 'yml' === pathinfo($filename, PATHINFO_EXTENSION) ? $filename : null;

        if ($perRom && CommandNamespace::ARTWORK === $namespace) {
            // if 'per rom' mode then need to return one command PER ROM rather than per platform
            $config = $this->configReader->getConfig();
            $inFolder = Path::join($config->romFolder, $config->getRomFolderForPlatform($platform));
            $finder = new Finder();
            // only look at roms one level down in the folder, this may or may not be acceptable to the way people organise roms
            // this is required as the subsequent 'skyscraper' command expects the filename to be at the folder root
            $finder->in($inFolder)->files()->depth('== 0')->notName(ApplicationConstant::EXCLUDE_FROM_ROM_SEARCH);

            foreach ($finder as $file) {
                $commands[] = new GenerateArtworkCommand(
                    $namespace->value,
                    $artworkPackage,
                    $artwork,
                    $mapping,
                    $platform,
                    $tokens,
                    $generateDescriptions,
                    $single,
                    $file->getFilename()
                );
            }

            return $commands;
        }

        return [new GenerateArtworkCommand(
            $namespace->value,
            $artworkPackage,
            $artwork,
            $mapping,
            $platform,
            $tokens,
            $generateDescriptions,
            $single,
        )];
    }
}
