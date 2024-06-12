<?php

namespace App\PostProcess;

use Psr\Log\LoggerInterface;
use Symfony\Component\Finder\Finder;

trait ArtworkTrait
{
    protected function getSortedArtwork(string $target, array $options, LoggerInterface $logger): array
    {
        $finder = new Finder();
        $finder->in($target);
        $finder->files()->name('*.png');

        $sortOrder = $options['sort_order'] ?? null;

        if (!$sortOrder) {
            $finder->sortByCaseInsensitiveName();
        }

        if ($sortOrder) {
            // need to sort by the ultimate folder name not the current filename
            $finder->sort(function (\SplFileInfo $a, \SplFileInfo $b) use ($sortOrder, $logger): int {
                // sortorder is an array ordered correctly with 'image filename ex png
                $platformNameA = basename($a->getRealPath(), '.png');
                $platformNameB = basename($b->getRealPath(), '.png');

                $positionA = array_search($platformNameA, $sortOrder);
                $positionB = array_search($platformNameB, $sortOrder);

                if (false === $positionA) {
                    $logger->debug(
                        sprintf('Unknown rom in sort_list, rom artwork will appear out of order. To fix this add an entry to names_extra.json for `%s`', $platformNameA)
                    );
                }
                if (false === $positionB) {
                    $logger->debug(
                        sprintf('Unknown rom in sort_list, rom artwork will appear out of order. To fix this add an entry to names_extra.json for `%s`', $platformNameB)
                    );
                }

                return ($positionA < $positionB) ? -1 : 1;
            });
        }

        $workset = [];
        foreach ($finder as $file) {
            $workset[] = $file->getRealPath();
        }

        return $workset;
    }

    protected function getArtwork(string $target): array
    {
        $finder = new Finder();
        $finder->in($target);
        $finder->files()->name('*.png');
        foreach ($finder as $file) {
            $workset[] = $file->getRealPath();
        }

        return $workset;
    }
}
