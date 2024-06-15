<?php

namespace App\Generator;

use App\Builder\SkyscraperCommandDirector;
use App\FolderNames;
use App\Model\Artwork;
use App\Provider\PathProvider;
use App\Reader\ArtworkXMLReader;
use App\Translator\ArtworkTranslator;
use App\Util\Path;
use Monolog\Attribute\WithMonologChannel;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Process\Process;

#[WithMonologChannel('skyscraper')]
readonly class ArtworkGenerator
{
    public function __construct(
        private SkyscraperCommandDirector $skyscraperCommandDirector,
        private ArtworkTranslator $artworkTranslator,
        private GameDescriptionGenerator $gameDescriptionGenerator,
        private PathProvider $pathProvider,
        private LoggerInterface $logger,
        private ArtworkXMLReader $artworkXMLReader,
        private Path $path
    ) {
    }

    public function generateArtwork(
        string $namespace,
        Artwork $artwork,
        string $platform,
        bool $single,
        array $runtimeTranslationTokens
    ): void {
        // add runtime translations, maybe the wrong place to do this as it seems redundant doing it over and over again
        if (count($runtimeTranslationTokens) > 0) {
            $this->artworkTranslator->addRuntimeTranslationTokens($runtimeTranslationTokens);
        }

        $tempArtworkPath = $this->getTmpArtworkPath($artwork, $namespace, $platform);

        $command = $this->skyscraperCommandDirector->getBoxartGenerateCommand(
            $platform,
            $namespace,
            $tempArtworkPath,
            $single
        );

        $this->logger->debug(
            sprintf('Running skyscraper command "%s"', implode(' ', $command))
        );

        $process = new Process($command);
        $process->setTimeout(60 * 60 * 3);

        try {
            $process->run();

            $output = $process->getOutput();

            $this->logger->info($output);
        } catch (\Exception $e) {
            $this->logger->debug($e->getMessage());
            throw new \RuntimeException('Unable to generate Artwork. Check debug log (/var/log) for more information.');
        }

        if ($single) {
            // for 'single' the output filename needs to be renamed to the platform name instead of rom name
            // this breaks SOC a lot because it's fairly specific to muos
            $finder = new Finder();
            $base = $this->pathProvider->getOutputPathForGeneratedArtwork($namespace, $platform);
            $finder->in($base);
            $finder->files()->name('*.png');
            foreach ($finder as $file) {
                $fileSystem = new Filesystem();
                $fileSystem->rename(
                    $file->getRealPath(),
                    Path::join($file->getPath(), $platform.'.png')
                );
            }
        }

        if (!$single) {
            $this->gameDescriptionGenerator->generateGameDescriptions(
                $namespace,
                $platform
            );
        }

        $this->artworkXMLReader->writeNotesForArtwork($artwork->absoluteFilepath);
    }

    public function getTmpArtworkPath(
        Artwork $artwork,
        string $namespace,
        string $platform,
    ): string {
        $filesystem = new Filesystem();

        $tempArtworkPath = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'artwork_tmp',
            $namespace,
            $platform.'.xml'
        );

        if ($filesystem->exists($tempArtworkPath)) {
            return $tempArtworkPath;
        }

        $artworkTranslated = $this->artworkTranslator->translateArtwork(
            $artwork,
            $platform
        );

        $filesystem->appendToFile(
            $tempArtworkPath,
            $artworkTranslated
        );

        return $tempArtworkPath;
    }
}
