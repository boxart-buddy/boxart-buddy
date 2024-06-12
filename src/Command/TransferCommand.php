<?php

namespace App\Command;

readonly class TransferCommand implements CommandInterface
{
    public function __construct(public string $packageName)
    {
    }
}
