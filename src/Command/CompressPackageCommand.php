<?php

namespace App\Command;

readonly class CompressPackageCommand implements CommandInterface
{
    public function __construct(public string $packageName)
    {
    }
}
