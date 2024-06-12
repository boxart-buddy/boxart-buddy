<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\GeneratePreviewCommand;
use App\Preview\PreviewGenerator;

readonly class GeneratePreviewHandler implements CommandHandlerInterface
{
    public function __construct(
        private PreviewGenerator $previewGenerator,
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof GeneratePreviewCommand) {
            throw new \InvalidArgumentException();
        }

        $this->previewGenerator->generatePreview($command->target, $command->gridSize, $command->previewName, $command->theme);
    }
}
