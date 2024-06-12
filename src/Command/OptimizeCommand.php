<?php

namespace App\Command;

readonly class OptimizeCommand implements CommandInterface
{
    public function __construct(public string $target, public ?int $optimizeJpg)
    {
    }
}
