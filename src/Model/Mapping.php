<?php

namespace App\Model;

class Mapping
{
    public function __construct(
        public string $absoluteFilepath,
        private array $artworks
    ) {
    }

    // Artworks should be keys by platform
    public function getArtworkByPlatform(string $key): ?Artwork
    {
        if (array_key_exists($key, $this->artworks)) {
            return $this->artworks[$key];
        }

        if (array_key_exists('default', $this->artworks)) {
            return $this->artworks['default'];
        }

        return null;
    }

    public function filename(): string
    {
        return basename($this->absoluteFilepath);
    }

    public function name(): string
    {
        return basename($this->absoluteFilepath, '.yml');
    }
}
