<?php

namespace App\Generator;

use Symfony\Component\Filesystem\Filesystem;

readonly class ManualImportXMLGenerator
{
    public function generateXML(string $path, string $title, string $description, ?string $genre = null, bool $pretty = false): void
    {
        $filesystem = new Filesystem();

        $xml = new \SimpleXMLElement('<game/>');

        $xml->addChild('title', htmlspecialchars($title));
        $xml->addChild('description', htmlspecialchars($description));
        if ($genre) {
            $xml->addChild('genre', htmlspecialchars($genre));
        }

        if ($filesystem->exists($path)) {
            $filesystem->remove($path);
        }

        $xmlString = $xml->asXML();

        if ($pretty && $xmlString) {
            $dom = new \DOMDocument();
            $dom->preserveWhiteSpace = false;
            $dom->formatOutput = true;
            $dom->loadXML($xmlString);
            $xmlString = $dom->saveXML();
        }

        $filesystem->appendToFile(
            $path,
            $xmlString ?: ''
        );
    }
}
