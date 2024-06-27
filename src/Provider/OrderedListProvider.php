<?php

namespace App\Provider;

use Symfony\Component\Finder\Finder;

readonly class OrderedListProvider
{
    public function __construct(
        private NamesProvider $namesProvider
    ) {
    }

    public function getOrderedList(?string $target = null): array
    {
        return $this->getOrderedListForArtwork($target);
    }

    private function getOrderedListForArtwork(?string $target): array
    {
        if (!$target) {
            throw new \RuntimeException();
        }

        // get artwork list from this packaged platform folder
        $finder = new Finder();
        $finder->in($target);
        $finder->files()->name('*.png');

        $artwork = [];
        foreach ($finder as $file) {
            $romName = $file->getBasename('.png');
            $artwork[$romName] = $romName;
        }

        $names = $this->namesProvider->getNames();

        $relevant = array_intersect_key($names, $artwork);
        asort($relevant);
        $relevant = array_flip($relevant);

        return $relevant;
    }
}
