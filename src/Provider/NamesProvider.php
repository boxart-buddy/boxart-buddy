<?php

namespace App\Provider;

use App\FolderNames;
use App\Util\Path;

class NamesProvider
{
    private ?array $names = null;

    public function __construct(private Path $path)
    {
    }

    public function getNamesInJsonFormat(): string
    {
        $names = $this->getNames();

        return json_encode($names, JSON_THROW_ON_ERROR | JSON_FORCE_OBJECT);
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
            FolderNames::USER_CONFIG->value,
            'name_extra.json',
        );

        $n = file_get_contents($namesFilePath);
        $ne = file_get_contents($extraNamesFilePath);
        if (!$n || !$ne) {
            throw new \RuntimeException('Cannot read names');
        }

        $names = json_decode($n, true, 512, JSON_THROW_ON_ERROR);
        $namesExtra = json_decode($ne, true, 512, JSON_THROW_ON_ERROR);

        $combined = $names + $namesExtra;

        $this->names = $combined;
    }
}
