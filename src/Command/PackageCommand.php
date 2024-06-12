<?php

namespace App\Command;

readonly class PackageCommand implements CommandInterface
{
    public function __construct(public string $packageName)
    {
    }
}
