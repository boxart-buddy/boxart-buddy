<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\PostProcessCommand;
use App\PostProcess\AddTextPostProcess;
use App\PostProcess\BackgroundImagePostProcess;
use App\PostProcess\CounterPostProcess;
use App\PostProcess\OffsetWithSiblingsPostProcess;
use App\PostProcess\OverlayArtworkGenerationPostProcess;
use App\PostProcess\PostProcessMissingOptionException;
use App\PostProcess\PostProcessOptionException;
use App\PostProcess\VerticalDotScrollbarPostProcess;
use App\PostProcess\VerticalScrollbarPostProcess;
use Monolog\Attribute\WithMonologChannel;

#[WithMonologChannel('postprocessing')]
readonly class PostProcessHandler implements CommandHandlerInterface
{
    public function __construct(
        private VerticalScrollbarPostProcess $verticalScrollbarPostProcess,
        private VerticalDotScrollbarPostProcess $verticalDotScrollbarPostProcess,
        private BackgroundImagePostProcess $backgroundImagePostProcess,
        private OffsetWithSiblingsPostProcess $offsetWithSiblingsPostProcess,
        private OverlayArtworkGenerationPostProcess $overlayArtworkGenerationPostProcess,
        private AddTextPostProcess $addTextPostProcess,
        private CounterPostProcess $counterPostProcess,
    ) {
    }

    /**
     * @throws PostProcessMissingOptionException
     * @throws PostProcessOptionException
     */
    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof PostProcessCommand) {
            throw new \InvalidArgumentException();
        }

        match ($command->strategy) {
            $this->verticalScrollbarPostProcess->getName() => $this->verticalScrollbarPostProcess->process($command),
            $this->verticalDotScrollbarPostProcess->getName() => $this->verticalDotScrollbarPostProcess->process($command),
            $this->backgroundImagePostProcess->getName() => $this->backgroundImagePostProcess->process($command),
            $this->offsetWithSiblingsPostProcess->getName() => $this->offsetWithSiblingsPostProcess->process($command),
            $this->overlayArtworkGenerationPostProcess->getName() => $this->overlayArtworkGenerationPostProcess->process($command),
            $this->addTextPostProcess->getName() => $this->addTextPostProcess->process($command),
            $this->counterPostProcess->getName() => $this->counterPostProcess->process($command),
            default => throw new \RuntimeException(sprintf('Cannot handle unknown strategy "%s"', $command->strategy))
        };
    }
}
