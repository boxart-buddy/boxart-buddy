<?php

namespace App\ConsoleCommand\Interactive;

readonly class PromptChoices
{
    public function __construct(
        public string $package,
        public string $variant,
        public bool $artwork,
        public bool $folder,
        public bool $portmaster,
        public bool $zip,
        public bool $transfer
    ) {
    }
}
