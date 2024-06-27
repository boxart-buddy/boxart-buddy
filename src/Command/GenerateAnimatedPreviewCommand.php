<?php

namespace App\Command;

readonly class GenerateAnimatedPreviewCommand implements TargetableCommandInterface
{
    public const NAME = 'generate-animated-preview';

    public function __construct(
        public string $target,
        public string $previewName,
        public ?string $theme,
    ) {
    }

    public function getTarget(): string
    {
        return sprintf('%s / animated', $this->theme);
    }

    public function getName(): string
    {
        return self::NAME;
    }
}
