<?php

namespace App\Provider;

use App\Util\Path;

class NamesProvider
{
    private ?array $names = null;

    public function __construct(private Path $path)
    {
    }

    public function getNamesInIniFormat(): string
    {
        $names = $this->getNames();
        $ini = '';
        foreach ($names as $romName => $title) {
            $ini = $ini.sprintf("%s.zip=%s\n", $romName, $title);
        }

        return $ini;
    }

    public function getNames(): array
    {
        if ($this->names) {
            return $this->names;
        }
        $this->loadNames();

        return $this->getNames();
    }

    private function loadNames(): void
    {
        // load all 'names' from resources
        $namesFilePath = $this->path->joinWithBase(
            'resources',
            'name.json',
        );
        $extraNamesFilePath = $this->path->joinWithBase(
            'resources',
            'name_extra.json',
        );

        $n = file_get_contents($namesFilePath);
        $ne = file_get_contents($extraNamesFilePath);
        if (!$n || !$ne) {
            throw new \RuntimeException('Cannot read names');
        }

        $names = json_decode($n, true, 512, JSON_BIGINT_AS_STRING);
        $namesExtra = json_decode($ne, true, 512, JSON_BIGINT_AS_STRING);
        if (empty($names)) {
            throw new \RuntimeException('name.json is invalid');
        }
        if (empty($namesExtra)) {
            throw new \RuntimeException('names_extra.json is invalid');
        }

        $combined = $names + $namesExtra;

        $this->names = $combined;
    }
}
