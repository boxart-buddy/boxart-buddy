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
use App\Config\Processor\TemplateMakeFileProcessor;
use App\Config\Reader\ConfigReader;
use App\ConsoleCommand\Interactive\PromptChoices;

readonly class BuildCommandCollectionFactory
{
    public function __construct(
        private ConfigReader $configReader,
        private CommandFactory $commandFactory,
        private TemplateMakeFileProcessor $templateMakeFileProcessor,
    ) {
    }

    public function create(PromptChoices $choices): BuildCommandCollection
    {
        $config = $this->configReader->getConfig();

        $make = $this->templateMakeFileProcessor->process($choices->package);
        $makeVariant = $make[$choices->variant];
        $packageName = $makeVariant['package_name'];

        $buildCommandCollection = new BuildCommandCollection();
        $buildCommandCollection->setCopyResourcesCommand(new CopyResourcesCommand([$choices->package]));
        $buildCommandCollection->setPackageCommand(new PackageCommand($packageName));

        if ($config->shouldOptimize) {
            $buildCommandCollection->setOptimizeCommand(new OptimizeCommand($packageName, $config->convertToJpg, $config->jpgQuality));
        }
        if ($choices->zip) {
            $buildCommandCollection->setCompressPackageCommand(new CompressPackageCommand($packageName));
        }
        if ($choices->transfer) {
            $buildCommandCollection->setTransferCommand(new TransferCommand($packageName));
        }
        if ($config->copyPreviewBackToTemplate) {
            $buildCommandCollection->setCopyBackPreviewCommand(new CopyBackPreviewCommand($packageName, $choices->package));
        }

        // artwork
        if ($choices->artwork) {
            $buildCommandCollection->setGenerateArtworkCommands(
                $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
                    CommandNamespace::ARTWORK,
                    $choices->package,
                    $makeVariant['artwork']['file'],
                    $makeVariant['artwork']['token'] ?? [],
                    true,
                    true
                )
            );
        }

        // folder
        if ($choices->folder) {
            $buildCommandCollection->setGenerateFolderCommands(
                $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
                    CommandNamespace::FOLDER,
                    $choices->package,
                    $makeVariant['folder']['file'],
                    $makeVariant['folder']['token'] ?? [],
                    false,
                    true,
                    $choices->portmaster
                )
            );
        }

        // portmaster
        if ($choices->portmaster) {
            $buildCommandCollection->setGeneratePortmasterCommands(
                $this->commandFactory->createGenerateArtworkCommandForPortmaster(
                    $choices->package,
                    $makeVariant['portmaster']['file'],
                    $makeVariant['portmaster']['token'] ?? [],
                )
            );
        }

        // post processing

        if (isset($makeVariant['artwork']['post_process']) && $choices->artwork) {
            foreach ($makeVariant['artwork']['post_process'] as $postProcessName => $postProcessOptions) {
                $buildCommandCollection->addPostProcessCommands(
                    $this->commandFactory->createPostProcessCommands(
                        $packageName,
                        $postProcessName,
                        CommandNamespace::ARTWORK->value,
                        $postProcessOptions,
                    )
                );
            }
        }

        if (isset($makeVariant['folder']['post_process']) && $choices->folder) {
            foreach ($makeVariant['folder']['post_process'] as $postProcessName => $postProcessOptions) {
                $buildCommandCollection->addPostProcessCommands(
                    $this->commandFactory->createPostProcessCommands(
                        $packageName,
                        $postProcessName,
                        CommandNamespace::FOLDER->value,
                        $postProcessOptions,
                    )
                );
            }
        }

        if (isset($makeVariant['portmaster']['post_process']) && $choices->portmaster) {
            foreach ($makeVariant['portmaster']['post_process'] as $postProcessName => $postProcessOptions) {
                $buildCommandCollection->addPostProcessCommands(
                    $this->commandFactory->createPostProcessCommands(
                        $packageName,
                        $postProcessName,
                        CommandNamespace::PORTMASTER->value,
                        $postProcessOptions,
                    )
                );
            }
        }

        // preview
        $buildCommandCollection->setPreviewCommands(
            $this->commandFactory->createGeneratePreviewCommands($packageName, $packageName)
        );

        return $buildCommandCollection;
    }

    public function getPackageName(PromptChoices $choices): string
    {
        return $this->templateMakeFileProcessor->process($choices->package)[$choices->variant]['package_name'];
    }
}
