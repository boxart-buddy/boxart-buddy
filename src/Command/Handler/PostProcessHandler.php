<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\PostProcessCommand;
use App\PostProcess\BackgroundImagePostProcess;
use App\PostProcess\OffsetWithSiblingsPostProcess;
use App\PostProcess\PostProcessMissingOptionException;
use App\PostProcess\PostProcessOptionException;
use App\PostProcess\VerticalDotScrollbarPostProcess;
use App\PostProcess\VerticalScrollbarPostProcess;

readonly class PostProcessHandler implements CommandHandlerInterface
{
    public function __construct(
        private VerticalScrollbarPostProcess $verticalScrollbarPostProcess,
        private VerticalDotScrollbarPostProcess $verticalDotScrollbarPostProcess,
        private BackgroundImagePostProcess $backgroundImagePostProcess,
        private OffsetWithSiblingsPostProcess $offsetWithSiblingsPostProcess
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
            default => throw new \RuntimeException(sprintf('Cannot handle unknown strategy "%s"', $command->strategy))
        };
    }
}
