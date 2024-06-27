<?php

namespace App\Command;

readonly class OptimizeCommand implements CommandInterface
{
    public const NAME = 'optimize';

    public function __construct(public string $packageName, public bool $convertToJpg, public int $jpgQuality)
    {
    }

    public function getName(): string
    {
        return self::NAME;
    }
}
