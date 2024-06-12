<?php

namespace App\Util;

use Symfony\Component\Finder\Finder as SymfonyFinder;

class Finder extends SymfonyFinder
{
    public function first(): mixed
    {
        try {
            $i = $this->getIterator();
            $i->rewind();

            return $i->current();
        } catch (\Exception $t) {
            return null;
        }
    }
}
