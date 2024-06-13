<?php

namespace App\Generator;

use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

/**
 * Creates rom import data files for skipped roms, namespaced by romset.
 */
readonly class SkippedRomImportDataGenerator
{
    public function __construct(
        private ConfigReader $configReader,
        private Path $path,
        private ManualImportXMLGenerator $manualImportXMLGenerator
    ) {
    }

    public function generate(bool $idempotent = false): array
    {
        $report = $this->createSkippedRomImportData();
        if (empty($report)) {
            return $report;
        }

        if (!$idempotent) {
            $this->deleteSkippedCacheFiles();
        }

        return $report;
    }

    private function deleteSkippedCacheFiles(): void
    {
        $skyscraperConfigFolder = $this->configReader->getConfig()->skyscraperConfigFolderPath;
        $filesystem = new Filesystem();
        $finder = new Finder();
        $finder->in(Path::join($skyscraperConfigFolder));
        $finder->files()->name('skipped-*-cache.txt');
        foreach ($finder as $file) {
            $filesystem->remove($file->getRealPath());
        }
    }

    private function createSkippedRomImportData(): array
    {
        $config = $this->configReader->getConfig();
        $skyscraperConfigFolder = $config->skyscraperConfigFolderPath;
        $romset = $config->romsetName;
        $filesystem = new Filesystem();

        // get files from SS directory
        $finder = new Finder();
        $finder->in(Path::join($skyscraperConfigFolder));
        $finder->files()->name('skipped-*-cache.txt');

        $report = [];

        if (!$finder->hasResults()) {
            return $report;
        }

        $skippedBase = $this->path->joinWithBase(FolderNames::SKIPPED->value, $romset);

        foreach ($finder as $file) {
            $filename = $file->getBasename();
            // $filepath = $file->getRealPath();
            if (preg_match('/skipped-(.*?)-cache\.txt/', $filename, $matches)) {
                $platform = $matches[1];
            } else {
                throw new \RuntimeException();
            }

            $platformSkippedBase = Path::join($skippedBase, $platform);

            // read the file and iterate it line by line
            $fileObject = $file->openFile();
            while (!$fileObject->eof()) {
                $romPath = trim($fileObject->fgets());
                if (!$romPath) {
                    continue;
                }
                $title = basename($romPath, '.'.pathinfo($romPath, PATHINFO_EXTENSION));
                // text
                $this->manualImportXMLGenerator->generateXML(
                    Path::join($platformSkippedBase, 'textual', $title.'.xml'),
                    $title,
                    'Add a description',
                    null,
                    true
                );

                // screenshot
                $filesystem->copy(
                    $this->path->joinWithBase('resources', 'missing.png'),
                    Path::join($platformSkippedBase, 'screenshots', $title.'.png'),
                );

                // wheels
                $filesystem->copy(
                    $this->path->joinWithBase('resources', 'missing-logo.png'),
                    Path::join($platformSkippedBase, 'wheels', $title.'.png'),
                );

                // add to report
                $report[$platform] = isset($report[$platform]) ? $report[$platform]++ : 1;
            }
        }

        return $report;
    }
}
