<?php

namespace App\Command;

readonly class GenerateAnimatedPreviewCommand implements TargetableCommandInterface
{
    public function __construct(
        public string $target,
        public string $previewName,
        public string $theme,
    ) {
    }

    public function getTarget(): string
    {
        return $this->theme;
    }
}
