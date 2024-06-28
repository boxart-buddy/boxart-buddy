<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\CopyResourcesCommand;
use App\Config\Processor\ApplicationConfigurationProcessor;
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

        $filesystem = new Filesystem();

        // removes existing resources to reduce chances of filename collisions
        // and reduce amount of files loaded into skyscraper memory
        $skyscraperResourcesDirectory = Path::join($skyscraperConfigFolderPath, 'resources');
        if ($filesystem->exists($skyscraperResourcesDirectory)) {
            // create a backup of it the first time this code is run
            // in case user is unaware it is going to be removed
            if (!$filesystem->exists($skyscraperResourcesDirectory.'-bak')) {
                $filesystem->mirror($skyscraperResourcesDirectory, $skyscraperResourcesDirectory.'-bak');
            }
            $filesystem->remove($skyscraperResourcesDirectory);
        }

        $filesystem = new Filesystem();
        $filesystem->mkdir($skyscraperResourcesDirectory);

        // COPY FROM Templates
        $finder = new Finder();

        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value));
        $finder->directories();

        foreach ($command->artworkFolders as $folder) {
            $pattern = sprintf('#%s$#', Path::join($folder, 'resources/'));
            $finder->path($pattern);
        }

        foreach ($finder as $directory) {
            $filesystem->mirror(
                $directory->getRealPath(),
                $skyscraperResourcesDirectory
            );
        }

        // COPY FROM resources/common
        $finder = new Finder();

        $finder->in($this->path->joinWithBase('resources'));
        $finder->directories()->name('skyscraper');

        foreach ($finder as $directory) {
            $filesystem->mirror(
                $directory->getRealPath(),
                $skyscraperResourcesDirectory
            );
        }
    }

    private function copyPostProcessResourcesToTemp(CopyResourcesCommand $command): void
    {
        $filesystem = new Filesystem();

        $postProcessTemp = $this->path->joinWithBase(FolderNames::TEMP->value, 'post-process', 'resources');
        if ($filesystem->exists($postProcessTemp)) {
            $filesystem->remove($postProcessTemp);
        }
        $filesystem->mkdir($postProcessTemp);

        // COPY FROM templates
        $finder = new Finder();
        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value));
        $finder->directories();

        foreach ($command->artworkFolders as $folder) {
            $pattern = sprintf('#%s$#', Path::join($folder, 'resources-post-process/'));
            $finder->path($pattern);
        }

        foreach ($finder as $directory) {
            $filesystem->mirror(
                $directory->getRealPath(),
                $postProcessTemp
            );
        }

        // COPY rom translations
        $filesystem->dumpFile(
            Path::join($postProcessTemp, ApplicationConfigurationProcessor::CONFIG_ROM_TRANSLATIONS),
            $filesystem->readFile(
                $this->path->joinWithBase(FolderNames::USER_CONFIG->value, ApplicationConfigurationProcessor::CONFIG_ROM_TRANSLATIONS)
            )
        );
        $finder = new Finder();

        $finder->in($this->path->joinWithBase('resources'));
        $finder->directories()->name('post-process');

        foreach ($finder as $directory) {
            $filesystem->mirror(
                $directory->getRealPath(),
                $postProcessTemp
            );
        }
    }
}
