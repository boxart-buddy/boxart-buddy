<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\GenerateStaticPreviewCommand;
use App\Preview\PreviewGenerator;

readonly class GenerateStaticPreviewHandler implements CommandHandlerInterface
{
    public function __construct(
        private PreviewGenerator $previewGenerator,
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof GenerateStaticPreviewCommand) {
            throw new \InvalidArgumentException();
        }

        $this->previewGenerator->generateStaticPreview($command->target, $command->previewName, $command->theme);
    }
}
