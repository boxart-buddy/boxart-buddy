<?php

namespace App\Command\Factory;

use App\Command\BuildCommandCollection;
use App\Command\CommandNamespace;
use App\Command\CompressPackageCommand;
use App\Command\CopyBackPreviewCommand;
use App\Command\CopyResourcesCommand;
use App\Command\OptimizeCommand;
use App\Command\PackageCommand;
use App\Command\TransferCommand;
use App\Config\Reader\ConfigReader;
use App\Util\TokenUtility;
use Symfony\Component\Console\Input\InputInterface;

readonly class BuildCommandCollectionFromInputFactory
{
    public function __construct(
        private ConfigReader $configReader,
        private CommandFactory $commandFactory,
    ) {
    }

    public function create(InputInterface $input): BuildCommandCollection
    {
        $config = $this->configReader->getConfig();

        $buildCommandCollection = new BuildCommandCollection();

        $template = $input->getArgument('template');
        $packageName = $this->getPackageName($input);

        $buildCommandCollection->setCopyResourcesCommand(new CopyResourcesCommand([$template]));
        $buildCommandCollection->setPackageCommand(new PackageCommand($packageName));

        if ($config->shouldOptimize) {
            $buildCommandCollection->setOptimizeCommand(new OptimizeCommand($packageName, $config->convertToJpg, $config->jpgQuality));
        }
        if ($input->getOption('zip')) {
            $buildCommandCollection->setCompressPackageCommand(new CompressPackageCommand($packageName));
        }
        if ($input->getOption('transfer')) {
            $buildCommandCollection->setTransferCommand(new TransferCommand($packageName));
        }
        if ($config->copyPreviewBackToTemplate) {
            $buildCommandCollection->setCopyBackPreviewCommand(new CopyBackPreviewCommand($packageName, $template));
        }

        $artwork = $input->getOption('artwork');
        // artwork
        if ($artwork) {
            $buildCommandCollection->setGenerateArtworkCommands(
                $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
                    CommandNamespace::ARTWORK,
                    $template,
                    $artwork,
                    $this->parseToken($input->getOption('token')),
                    true,
                    true
                )
            );
        }

        $folder = $input->getOption('folder');
        $portmaster = $input->getOption('portmaster');

        // folder
        if ($folder) {
            $buildCommandCollection->setGenerateFolderCommands(
                $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
                    CommandNamespace::FOLDER,
                    $template,
                    $folder,
                    $this->parseToken($input->getOption('token')),
                    false,
                    true,
                    (bool) $portmaster
                )
            );
        }

        // portmaster
        if ($portmaster) {
            $buildCommandCollection->setGeneratePortmasterCommands(
                $this->commandFactory->createGenerateArtworkCommandForPortmaster(
                    $template,
                    $portmaster,
                    $this->parseToken($input->getOption('token')),
                )
            );
        }

        // post process
        $buildCommandCollection->setPostProcessCommands($this->getPostProcessCommands($packageName, $input));

        // preview
        $buildCommandCollection->setPreviewCommands(
            $this->commandFactory->createGeneratePreviewCommands($packageName, $packageName)
        );

        return $buildCommandCollection;
    }

    private function getPostProcessCommands(string $packageName, InputInterface $input): array
    {
        $commands = [];

        // artwork
        $postProcessArtwork = $input->getOption('post-process-artwork');

        foreach ($postProcessArtwork as $ppa) {
            $argAndOptions = TokenUtility::splitArgumentAndOptions($ppa);
            $commands = array_merge($commands, $this->commandFactory->createPostProcessCommands(
                $packageName,
                $argAndOptions['argument'],
                CommandNamespace::ARTWORK->value,
                $argAndOptions['options'],
            ));
        }

        // folder
        $postProcessFolder = $input->getOption('post-process-folder');

        foreach ($postProcessFolder as $ppf) {
            $argAndOptions = TokenUtility::splitArgumentAndOptions($ppf);
            $commands = array_merge($commands, $this->commandFactory->createPostProcessCommands(
                $packageName,
                $argAndOptions['argument'],
                CommandNamespace::FOLDER->value,
                $argAndOptions['options'],
            ));
        }

        $postProcessPortmaster = $input->getOption('post-process-portmaster');

        foreach ($postProcessPortmaster as $ppp) {
            $argAndOptions = TokenUtility::splitArgumentAndOptions($ppp);
            $commands = array_merge($commands, $this->commandFactory->createPostProcessCommands(
                $packageName,
                $argAndOptions['argument'],
                CommandNamespace::PORTMASTER->value,
                $argAndOptions['options'],
            ));
        }

        return $commands;
    }

    public static function getPackageName(InputInterface $input): string
    {
        if ($input->getOption('package-name')) {
            return $input->getOption('package-name');
        }

        $vals = [];
        $artwork = $input->getOption('artwork');
        $folder = $input->getOption('folder');
        $portmaster = $input->getOption('portmaster');

        if ($artwork) {
            $vals[] = $artwork;
        }
        if ($folder) {
            $vals[] = $folder;
        }
        if ($portmaster) {
            $vals[] = $portmaster;
        }

        if (empty($vals)) {
            throw new \LogicException('Cannot get package name - no artwork generation params provided');
        }

        $packageAndFilename = TokenUtility::splitStringIntoArtworkPackageAndFileName(reset($vals));

        return sprintf(
            '%s-%s',
            $packageAndFilename['artworkPackage'],
            basename(basename($packageAndFilename['filename'], '.xml'), '.yml')
        );
    }

    private function parseToken(?string $token): array
    {
        if (!$token) {
            return [];
        }

        return TokenUtility::parseRuntimeTokens($token);
    }
}
