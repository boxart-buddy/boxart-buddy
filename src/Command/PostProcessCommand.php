<?php

namespace App\Command;

readonly class PostProcessCommand implements TargetableCommandInterface
{
    public const NAME = 'post-process';

    public function __construct(
        public string $target,
        public string $strategy,
        public array $options,
        public ?array $platforms = null
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

    public function getName(): string
    {
        return self::NAME;
    }
}
