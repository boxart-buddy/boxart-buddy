<?php

namespace App\Command;

readonly class GenerateArtworkCommand implements TargetableCommandInterface
{
    public const NAME = 'generate-artwork';

    public function __construct(
        public string $namespace,
        public string $artworkPackage,
        public ?string $artwork,
        public ?string $mapping,
        public string $platform,
        public array $tokens,
        public bool $generateDescriptions,
        public bool $single,
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

    public function getName(): string
    {
        return self::NAME;
    }
}
