<?php

namespace App\Command;

readonly class PostProcessCommand implements TargetableCommandInterface
{
    public function __construct(
        public string $target,
        public string $strategy,
        public array $options
    ) {
    }

    public function getTarget(): string
    {
        return sprintf(
            '%s: `%s`',
            $this->strategy,
            basename(dirname($this->target))
        );
    }
}
