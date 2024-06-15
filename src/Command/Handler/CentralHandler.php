<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\CompressPackageCommand;
use App\Command\CopyResourcesCommand;
use App\Command\GenerateAnimatedPreviewCommand;
use App\Command\GenerateArtworkCommand;
use App\Command\GenerateStaticPreviewCommand;
use App\Command\OptimizeCommand;
use App\Command\PackageCommand;
use App\Command\PostProcessCommand;
use App\Command\PrimeCacheCommand;
use App\Command\TransferCommand;

readonly class CentralHandler
{
    public function __construct(
        private CopyResourcesHandler $copyResourcesHandler,
        private GenerateArtworkHandler $generateArtworkHandler,
        private PrimeCacheHandler $primeCacheHandler,
        private GenerateStaticPreviewHandler $generateStaticPreviewHandler,
        private GenerateAnimatedPreviewHandler $generateAnimatedPreviewHandler,
        private PackageHandler $packageHandler,
        private CompressPackageHandler $compressPackageHandler,
        private TransferHandler $transferHandler,
        private PostProcessHandler $postProcessHandler,
        private OptimizeHandler $optimizeHandler,
    ) {
    }

    /**
     * @throws \RuntimeException
     */
    public function handle(CommandInterface $command): void
    {
        switch (get_class($command)) {
            case GenerateArtworkCommand::class:
                $this->generateArtworkHandler->handle($command);
                break;
            case CopyResourcesCommand::class:
                $this->copyResourcesHandler->handle($command);
                break;
            case PrimeCacheCommand::class:
                $this->primeCacheHandler->handle($command);
                break;
            case GenerateStaticPreviewCommand::class:
                $this->generateStaticPreviewHandler->handle($command);
                break;
            case GenerateAnimatedPreviewCommand::class:
                $this->generateAnimatedPreviewHandler->handle($command);
                break;
            case PackageCommand::class:
                $this->packageHandler->handle($command);
                break;
            case CompressPackageCommand::class:
                $this->compressPackageHandler->handle($command);
                break;
            case TransferCommand::class:
                $this->transferHandler->handle($command);
                break;
            case PostProcessCommand::class:
                $this->postProcessHandler->handle($command);
                break;
            case OptimizeCommand::class:
                $this->optimizeHandler->handle($command);
                break;
            default:
                throw new \RuntimeException(sprintf('No handler registered for command of type `%s`', $command::class));
        }
    }
}
