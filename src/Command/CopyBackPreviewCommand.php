<?php

namespace App\Command;

readonly class CopyBackPreviewCommand implements CommandInterface
{
    public const NAME = 'copy-back-preview';

    public function __construct(public string $packageName, public string $artworkPackage)
    {
    }

    public function getName(): string
    {
        return self::NAME;
    }
}
