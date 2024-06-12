<?php

namespace App\Generator;

use App\Provider\PathProvider;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;

class GameDescriptionGenerator
{
    public function __construct(
        private PathProvider $pathProvider
    ) {
    }

    public function generateGameDescriptions(string $namespace, string $platform): void
    {
        $filesystem = new Filesystem();

        // get gamelist
        $gamelistPath = Path::join($this->pathProvider->getGamelistPath($namespace, $platform), 'gamelist.xml');

        if (!$filesystem->exists($gamelistPath)) {
            return;
        }

        // iterate gamelist - dumping one text for each entry
        $xml = simplexml_load_file($gamelistPath);
        if (false === $xml) {
            return;
        }

        foreach ($xml->game as $key => $game) {
            $path = (string) $game->path;
            $romName = basename($path);
            $desc = $game->desc ?: 'No Description';
            $txtFileName = substr($romName, 0, -4);

            $txtFilePath = Path::join(
                $this->pathProvider->getOutputPathForGeneratedArtwork($namespace, $platform),
                'txt',
                $txtFileName.'.txt'
            );

            $filesystem->appendToFile($txtFilePath, $desc);
        }
    }
}
