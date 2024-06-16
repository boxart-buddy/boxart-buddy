<?php

namespace App\Generator;

use App\Builder\SkyscraperCommandDirector;
use App\FolderNames;
use App\Model\Artwork;
use App\Provider\PathProvider;
use App\Reader\ArtworkXMLReader;
use App\Translator\ArtworkTranslator;
use App\Util\Finder;
use App\Util\Path;
use Monolog\Attribute\WithMonologChannel;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
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
        bool $folderMode,
        array $runtimeTranslationTokens,
        ?string $romName,
    ): void {
        // add runtime translations, maybe the wrong place to do this as it seems redundant doing it over and over again
        if (count($runtimeTranslationTokens) > 0) {
            $this->artworkTranslator->addRuntimeTranslationTokens($runtimeTranslationTokens);
        }

        $tempArtworkPath = $this->getTmpArtworkPath($artwork, $namespace, $platform, $single, $romName ? Path::removeExtension($romName) : null);

        $command = $this->skyscraperCommandDirector->getBoxartGenerateCommand(
            $platform,
            $namespace,
            $tempArtworkPath,
            $single,
            $romName
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
            if (!$process->isSuccessful()) {
                throw new \RuntimeException('The artwork generation process failed. Check `var/log/skyscraper*.log` log file');
            }
        } catch (\Exception $e) {
            $this->logger->error($e->getMessage());
            throw new \RuntimeException('The artwork generation process failed. Check `var/log/skyscraper*.log` log file');
        }

        if ($folderMode) {
            // for 'folderMode' the output filename needs to be renamed to the platform name instead of rom name
            // this breaks SOC a lot because it's fairly specific to muos
            $finder = new Finder();
            $base = $this->pathProvider->getOutputPathForGeneratedArtwork($namespace, $platform);
            $finder->in($base);
            $finder->files()->name('*.png');
            $file = $finder->first();
            $fileSystem = new Filesystem();
            $fileSystem->rename(
                $file->getRealPath(),
                Path::join($file->getPath(), $platform.'.png')
            );
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
        bool $single,
        ?string $romName
    ): string {
        $filesystem = new Filesystem();

        $tempArtworkPath = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'artwork_tmp',
            $namespace,
            $platform.'.xml'
        );

        // if $romName is provided then the artwork needs retranslated every time
        if ($single && $romName) {
            $tempArtworkPath = $this->path->joinWithBase(
                FolderNames::TEMP->value,
                'artwork_tmp',
                $namespace,
                sprintf('%s-%s.xml', $platform, $romName)
            );
        }

        if ($filesystem->exists($tempArtworkPath)) {
            return $tempArtworkPath;
        }

        $artworkTranslated = $this->artworkTranslator->translateArtwork(
            $artwork,
            $platform,
            $romName
        );

        $filesystem->appendToFile(
            $tempArtworkPath,
            $artworkTranslated
        );

        return $tempArtworkPath;
    }
}
