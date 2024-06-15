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
use App\Util\Path;

readonly class CommandFactory
{
    public function __construct(
        private ConfigReader $configReader,
        private Path $path,
        private OrderedListProvider $orderedListProvider
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
            $target = Path::join($targetBase, 'Ports', 'box');

            return [new PostProcessCommand($target, $strategy, $options)];
        }

        foreach ($config->platforms as $platform => $folder) {
            $target = Path::join($targetBase, $config->package[$platform], 'box');
            $options['sort_order'] = $this->orderedListProvider->getOrderedList(CommandNamespace::ARTWORK, $target);
            $commands[] = new PostProcessCommand($target, $strategy, $options);
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
    ): GenerateArtworkCommand {
        return new GenerateArtworkCommand(
            CommandNamespace::PORTMASTER->value,
            $artworkPackage,
            $artworkFilename,
            null,
            ApplicationConstant::FAKE_PORTMASTER_PLATFORM,
            $tokens,
            false
        );
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
        array $tokens
    ): array {
        $single = false;
        if (CommandNamespace::FOLDER === $namespace) {
            $single = true;
        }

        $commands = [];

        $artwork = 'xml' === pathinfo($filename, PATHINFO_EXTENSION) ? $filename : null;
        $mapping = 'yml' === pathinfo($filename, PATHINFO_EXTENSION) ? $filename : null;

        foreach ($this->configReader->getConfig()->platforms as $platform => $romFolder) {
            $commands[] = new GenerateArtworkCommand(
                $namespace->value,
                $artworkPackage,
                $artwork,
                $mapping,
                $platform,
                $tokens,
                $single
            );
        }

        return $commands;
    }
}
