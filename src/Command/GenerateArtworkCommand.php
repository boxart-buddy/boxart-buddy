<?php

namespace App\Command;

readonly class GenerateArtworkCommand implements TargetableCommandInterface
{
    public function __construct(
        public string $namespace,
        public string $artworkPackage,
        public ?string $artwork,
        public ?string $mapping,
        public string $platform,
        public array $tokens,
        public bool $single,
        public bool $folderMode,
        public ?string $romName = null
    ) {
    }

    public function getTarget(): string
    {
        if ($this->romName) {
            return sprintf('%s: %s', $this->platform, $this->romName);
        }

        return $this->platform;
    }
}
