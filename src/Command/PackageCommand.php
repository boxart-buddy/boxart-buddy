<?php

namespace App\Command;

readonly class PackageCommand implements CommandInterface
{
    public const NAME = 'package';

    public function __construct(public string $packageName)
    {
    }

    public function getName(): string
    {
        return self::NAME;
    }
}
