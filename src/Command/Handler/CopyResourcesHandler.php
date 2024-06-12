<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\CopyResourcesCommand;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

readonly class CopyResourcesHandler implements CommandHandlerInterface
{
    public function __construct(private ConfigReader $configReader, private Path $path)
    {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof CopyResourcesCommand) {
            throw new \InvalidArgumentException();
        }

        $this->copyResourcesToSkyscraper($command);
        $this->copyPostProcessResourcesToTemp($command);
    }

    private function copyResourcesToSkyscraper(CopyResourcesCommand $command): void
    {
        $skyscraperConfigFolderPath = $this->configReader->getConfig()->skyscraperConfigFolderPath;

        $finder = new Finder();
        $filesystem = new Filesystem();

        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value));
        $finder->directories();

        foreach ($command->artworkFolders as $folder) {
            $pattern = sprintf('#%s$#', Path::join($folder, 'resources/'));
            $finder->path($pattern);
        }

        // removes existing resources to reduce chances of filename collisions
        // and reduce amount of files loaded into skyscraper memory
        $skyscraperResourcesDirectory = Path::join($skyscraperConfigFolderPath, 'resources/');
        if ($filesystem->exists($skyscraperResourcesDirectory)) {
            $filesystem->remove($skyscraperResourcesDirectory);
        }
        $filesystem->mkdir($skyscraperResourcesDirectory);

        foreach ($finder as $directory) {
            $filesystem->mirror(
                $directory->getRealPath(),
                $skyscraperResourcesDirectory
            );
        }
    }

    private function copyPostProcessResourcesToTemp(CopyResourcesCommand $command): void
    {
        $finder = new Finder();
        $filesystem = new Filesystem();

        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value));
        $finder->directories();

        foreach ($command->artworkFolders as $folder) {
            $pattern = sprintf('#%s$#', Path::join($folder, 'resources-post-process/'));
            $finder->path($pattern);
        }

        $postProcessTemp = $this->path->joinWithBase(FolderNames::TEMP->value, 'post-process', 'resources');

        if ($filesystem->exists($postProcessTemp)) {
            $filesystem->remove($postProcessTemp);
        }

        $filesystem->mkdir($postProcessTemp);

        foreach ($finder as $directory) {
            $filesystem->mirror(
                $directory->getRealPath(),
                $postProcessTemp
            );
        }
    }
}
