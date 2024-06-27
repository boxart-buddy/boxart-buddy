<?php

namespace App\ConsoleCommand\Interactive;

readonly class PromptOptions
{
    public function __construct(
        private array $variants,
        private array $options
    ) {
    }

    public function getPackages(): array
    {
        return array_keys($this->variants);
    }

    public function getVariants(string $package): array
    {
        if (!isset($this->variants[$package])) {
            throw new \InvalidArgumentException();
        }

        return $this->variants[$package];
    }

    public function getOptions(string $package, string $variant): array
    {
        if (!isset($this->options[$package]) || !isset($this->options[$package][$variant])) {
            throw new \InvalidArgumentException();
        }

        return $this->options[$package][$variant];
    }

    public function getOptionDefaults(string $package, string $variant): array
    {
        $options = $this->getOptions($package, $variant);
        $default = [];
        if (array_key_exists('artwork', $options)) {
            $default[] = 'artwork';
        }
        if (array_key_exists('folder', $options)) {
            $default[] = 'folder';
        }

        return $default;
    }
}
