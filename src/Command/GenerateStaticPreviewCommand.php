<?php

namespace App\Command;

readonly class GenerateStaticPreviewCommand implements TargetableCommandInterface
{
    public const NAME = 'generate-static-preview';

    public function __construct(
        public string $target,
        public string $previewName,
        public ?string $theme
    ) {
    }

    public function getTarget(): string
    {
        return sprintf('%s / static', $this->theme);
    }

    public function getName(): string
    {
        return self::NAME;
    }
}
