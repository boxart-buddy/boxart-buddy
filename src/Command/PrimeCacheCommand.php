<?php

namespace App\Command;

readonly class PrimeCacheCommand implements CommandInterface
{
    public function __construct(public string $platform)
    {
    }
}
