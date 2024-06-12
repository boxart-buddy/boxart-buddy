<?php

namespace App\Provider;

use App\FolderNames;
use App\Model\Artwork;
use App\Util\Finder;
use App\Util\Path;

readonly class ArtworkProvider
{
    public function __construct(private Path $path)
    {
    }

    public function getArtwork(string $artworkPackage, string $filename): Artwork
    {
        $finder = new Finder();

        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value, $artworkPackage, 'artwork'));
        $finder->depth('== 0')->files()->name($filename);

        if (!$finder->hasResults()) {
            throw new \RuntimeException(sprintf('Cannot get artwork with name `%s`. Not Found!', $filename));
        }

        $fileInfo = $finder->first();

        return new Artwork(
            $fileInfo->getRealPath()
        );
    }

    public function getArtworkFiles(string $artworkPackage): array
    {
        $finder = new Finder();

        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value, $artworkPackage, 'artwork'));
        $finder->depth('== 0')->files()->name('*.xml');

        $artworkFiles = [];
        foreach ($finder as $artwork) {
            $artworkFiles[] = $artwork->getFilename();
        }

        return $artworkFiles;
    }
}
