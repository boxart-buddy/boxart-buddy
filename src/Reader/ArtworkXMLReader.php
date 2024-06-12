<?php

namespace App\Reader;

use App\FolderNames;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;

class ArtworkXMLReader
{
    public function __construct(
        private Path $path
    ) {
    }

    private function readMetadata(string $artworkAbsolutePath): array
    {
        $xml = simplexml_load_file($artworkAbsolutePath);
        $data = [];
        if (false === $xml || !isset($xml->meta[0])) {
            return $data;
        }

        $attributes = ['author', 'notes'];
        $artwork = basename($artworkAbsolutePath);
        foreach ($xml->meta[0]->attributes() as $attr => $value) {
            foreach ($attributes as $attribute) {
                if ($attr === $attribute) {
                    $data[$artwork][$attribute] = $value;
                }
            }
        }

        return $data;
    }

    public function writeNotesForArtwork(string $artworkAbsolutePath): void
    {
        $meta = $this->readMetadata($artworkAbsolutePath);
        $artwork = basename($artworkAbsolutePath);

        $filesystem = new Filesystem();
        $noteFilepath = $this->path->joinWithBase(
            FolderNames::TEMP->value, 'output', 'notes', basename($artwork, '.xml').'.txt'
        );

        if ($filesystem->exists($noteFilepath)) {
            $filesystem->remove($noteFilepath);
        }

        if (0 === count($meta)) {
            return;
        }

        $author = $meta[$artwork]['author'] ?? 'unknown';
        $notes = $meta[$artwork]['notes'] ?? '';
        $note = <<<EOT
                Template: $artwork
                Author: $author
                ------------------------------
                $notes


                EOT;

        $filesystem->appendToFile($noteFilepath, $note);
    }
}
