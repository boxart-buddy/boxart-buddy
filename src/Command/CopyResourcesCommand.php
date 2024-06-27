<?php

namespace App\Command;

readonly class CopyResourcesCommand implements CommandInterface
{
    public const NAME = 'copy-resources';

    public function __construct(public array $artworkFolders)
    {
    }

    public function getName(): string
    {
        return self::NAME;
    }
}
