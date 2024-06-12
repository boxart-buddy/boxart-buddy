<?php

namespace App\Provider;

use App\FolderNames;
use App\Model\Artwork;
use App\Model\Mapping;
use App\Util\Finder;
use App\Util\Path;
use Symfony\Component\Yaml\Yaml;

readonly class MappingProvider
{
    public function __construct(private Path $path, private ArtworkProvider $artworkProvider)
    {
    }

    public function getMapping(string $artworkPackage, string $filename): Mapping
    {
        $finder = new Finder();

        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value, 'mapping'));
        $finder->depth('== 0')->files()->name($filename);

        if (!$finder->hasResults()) {
            throw new \RuntimeException(sprintf('Cannot get mapping with name `%s`. Not Found!', $filename));
        }

        $fileInfo = $finder->first();

        // parse the yml file and fetch the artwork files
        $mappingConfig = Yaml::parseFile($fileInfo->getRealPath());
        $artworkFiles = $this->artworkProvider->getArtworkFiles($artworkPackage);

        $artworks = [];
        foreach ($mappingConfig as $platform => $artworkFile) {
            // make sure the mapped artwork actually exists
            if (!array_search($artworkFile, $artworkFiles)) {
                throw new \RuntimeException(sprintf('Artwork file "%s", mapped for platform `%s` does not exist', $artworkFile, $platform));
            }

            $artworks[$platform] = new Artwork(
                $this->path->joinWithBase(FolderNames::TEMPLATE->value, $artworkPackage, 'artwork', $artworkFile)
            );
        }

        return new Mapping(
            $fileInfo->getRealPath(),
            $artworks
        );
    }

    //    public function getMappingFiles(): array
    //    {
    //        $finder = new Finder();
    //
    //        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value, 'mapping'));
    //        $finder->depth('== 0')->files()->name('*.yml');
    //
    //        $mappingFiles = [];
    //        foreach ($finder as $artwork) {
    //            $mappingFiles[] = $artwork->getFilename();
    //        }
    //
    //        return $mappingFiles;
    //    }
}
