<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\GenerateAnimatedPreviewCommand;
use App\Preview\PreviewGenerator;

readonly class GenerateAnimatedPreviewHandler implements CommandHandlerInterface
{
    public function __construct(
        private PreviewGenerator $previewGenerator,
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof GenerateAnimatedPreviewCommand) {
            throw new \InvalidArgumentException();
        }
        $this->previewGenerator->generateAnimatedPreview($command->target, $command->previewName, $command->theme);
    }
}
