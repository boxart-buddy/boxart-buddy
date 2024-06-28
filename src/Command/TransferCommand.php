<?php

namespace App\Command;

readonly class TransferCommand implements CommandInterface
{
    public const NAME = 'transfer';

    public function __construct(
        public string $packageName,
        public bool $zipped,
    ) {
    }

    public function getName(): string
    {
        return self::NAME;
    }
}
