<?php

namespace App\Provider;

use App\Command\CommandNamespace;
use App\Config\Reader\ConfigReader;
use Symfony\Component\Finder\Finder;

class OrderedListProvider
{
    private ?array $names = null;

    public function __construct(
        readonly private ConfigReader $configReader,
        readonly private NamesProvider $namesProvider
    ) {
    }

    public function getOrderedList(CommandNamespace $namespace, ?string $target = null): array
    {
        return match ($namespace) {
            CommandNamespace::ARTWORK => $this->getOrderedListForArtwork($target),
            default => []
        };
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
