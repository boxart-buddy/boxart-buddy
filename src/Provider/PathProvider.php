<?php

namespace App\Provider;

use App\FolderNames;
use App\Util\Path;

// this class possibly redundant and functions to be moved back to classes where used
readonly class PathProvider
{
    public function __construct(private Path $path)
    {
    }

    public function getOutputPathForGeneratedArtwork(string $namespace, string $platform): string
    {
        return $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'output',
            $namespace,
            'generated_artwork',
            $platform
        );
    }

    public function getGamelistPath(string $namespace, string $platform): string
    {
        return $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'output',
            $namespace,
            'gamelist',
            $platform
        );
    }

    public function getPortmasterRomPath(): string
    {
        return $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'roms/');
    }

    public function getFontPath(?string $variant = null): string
    {
        return match ($variant) {
            'bold' => $this->path->joinWithBase('resources', 'font', 'Cousine-Bold.ttf'),
            'italic' => $this->path->joinWithBase('resources', 'font', 'Cousine-Italic.ttf'),
            'bold-italic' => $this->path->joinWithBase('resources', 'font', 'Cousine-BoldItalic.ttf'),
            default => $this->path->joinWithBase('resources', 'font', 'Cousine-Regular.ttf')
        };
    }
}
