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
        public bool $single
    ) {
    }

    public function getTarget(): string
    {
        return $this->platform;
    }
}
