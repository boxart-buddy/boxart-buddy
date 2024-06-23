<?php

namespace App\Command;

readonly class GenerateStaticPreviewCommand implements TargetableCommandInterface
{
    public function __construct(
        public string $target,
        public string $previewName,
        public string $theme
    ) {
    }

    public function getTarget(): string
    {
        return sprintf('%s / static', $this->theme);
    }
}
