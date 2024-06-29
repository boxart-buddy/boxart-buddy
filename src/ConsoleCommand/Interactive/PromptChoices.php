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

    public function prettyPrint(): string
    {
        $vars = get_object_vars($this);
        $parts = [];
        foreach ($vars as $key => $value) {
            $parts[] = sprintf('%s: %s', $key, var_export($value, true));
        }

        return implode(PHP_EOL, $parts);
    }
}
