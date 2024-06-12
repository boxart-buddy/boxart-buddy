<?php

namespace App\Command;

readonly class CopyResourcesCommand implements CommandInterface
{
    public function __construct(public array $artworkFolders)
    {
    }
}
