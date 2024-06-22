<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\GenerateArtworkCommand;
use App\Generator\ArtworkGenerator;
use App\Provider\ArtworkProvider;
use App\Provider\MappingProvider;

readonly class GenerateArtworkHandler implements CommandHandlerInterface
{
    public function __construct(
        private ArtworkGenerator $artworkGenerator,
        private ArtworkProvider $artworkProvider,
        private MappingProvider $mappingProvider
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof GenerateArtworkCommand) {
            throw new \InvalidArgumentException();
        }

        $artwork = null;
        if ($command->artwork) {
            $artwork = $this->artworkProvider->getArtwork($command->artworkPackage, $command->artwork);
        }
        if ($command->mapping) {
            $mapping = $this->mappingProvider->getMapping($command->artworkPackage, $command->mapping);
            $artwork = $mapping->getArtworkByPlatform($command->platform);
        }

        if (!$artwork) {
            throw new \InvalidArgumentException('Generate artwork command must have a valid mapping or artwork file property');
        }

        $this->artworkGenerator->generateArtwork(
            $command->namespace,
            $artwork,
            $command->platform,
            $command->single,
            $command->tokens,
            $command->generateDescriptions,
            $command->romName
        );
    }
}
