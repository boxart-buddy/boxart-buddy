<?php

namespace App\Command;

readonly class GeneratePreviewCommand implements TargetableCommandInterface
{
    public function __construct(
        public string $target,
        public string $previewName,
        public string $theme,
        public int $gridSize
    ) {
    }

    public function getTarget(): string
    {
        return $this->theme;
    }
}
