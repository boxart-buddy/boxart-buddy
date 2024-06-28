<?php

namespace App\Skyscraper;

// reads the underlying peas.json file from skyscraper to provide rom extensions for platforms
use App\Config\Reader\ConfigReader;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

class RomExtensionProvider
{
    private ?array $peas = null;

    public function __construct(readonly private ConfigReader $configReader)
    {
    }

    public function addRomExtensionsToFinder(Finder $finder, $platform): void
    {
        $extensions = $this->getRomExtensionsForPlatform($platform);

        foreach ($extensions as $extension) {
            $finder->name($extension);
        }
    }

    public function getRomExtensionsForPlatform(string $platform): array
    {
        if (!$this->peas) {
            $this->peas = $this->loadPeas();
        }

        $extensions = $this->peas[$platform]['formats'] ?? [];

        if (!isset($this->peas[$platform]['aliases']) || !is_array($this->peas[$platform]['aliases'])) {
            return $extensions;
        }

        foreach ($this->peas[$platform]['aliases'] as $alias) {
            $aliasExtensions = $this->peas[$alias]['formats'] ?? [];
            $extensions = array_merge($extensions, $aliasExtensions);
        }

        // need to add zip formats manually
        $extensions = array_merge($extensions, ['*.zip', '*.tar', '*.tar.gz', '*.7z']);

        return array_values(array_unique($extensions));
    }

    private function loadPeas(): array
    {
        $peasPath = Path::join($this->configReader->getConfig()->skyscraperConfigFolderPath, 'peas.json');
        $filesystem = new Filesystem();

        if (!$filesystem->exists($peasPath)) {
            throw new \RuntimeException('Cannot read peas.json from skyscraper config folder');
        }

        return json_decode($filesystem->readFile($peasPath), true);
    }
}
