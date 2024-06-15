<?php

namespace App\Command;

readonly class OptimizeCommand implements CommandInterface
{
    public function __construct(public string $target, public bool $convertToJpg, public int $jpgQuality)
    {
    }
}
