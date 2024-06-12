<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;
use App\FolderNames;
use App\Util\Path;
use Intervention\Image\ImageManager;
use Symfony\Component\Filesystem\Filesystem;

class BackgroundImagePostProcess implements PostProcessInterface
{
    use ArtworkTrait;

    public const NAME = 'background';

    public function __construct(readonly private Path $path)
    {
    }

    public function getName(): string
    {
        return self::NAME;
    }

    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    public function process(PostProcessCommand $command): void
    {
        $options = $this->processOptions($command->options);
        $workset = $this->getArtwork($command->target);
        $this->processWorkset($workset, $command->target, $options);
    }

    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    public function processOptions(array $options): array
    {
        return BackgroundImagePostProcessOptions::mergeDefaults($options);
    }

    private function processWorkset(array $files, string $target, array $options): void
    {
        $filesystem = new Filesystem();

        $tmpFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'post-process',
            self::NAME,
            hash('xxh3', (string) mt_rand())
        );

        foreach ($files as $originalFilePath) {
            $originalFilename = basename($originalFilePath);

            $manager = ImageManager::imagick();
            $canvasX = 640;
            $canvasY = 480;
            $canvas = $manager->create($canvasX, $canvasY);

            if (!isset($options['background'])) {
                throw new \RuntimeException('Background option is missing and is required');
            }

            // @todo check this file exists
            $bg = $this->path->joinWithBase(
                FolderNames::TEMP->value,
                'post-process',
                'resources',
                $options['background']
            );

            if (!$filesystem->exists($bg)) {
                throw new \InvalidArgumentException(sprintf('Background image "%s" does not exist', $bg));
            }

            $canvas->place($bg);

            // insert the image on top
            $originalImage = $manager->read($originalFilePath);
            $canvas->place($originalImage);

            // save to temp location
            $filesystem->mkDir($tmpFolder);
            $canvas->save(Path::join($tmpFolder, $originalFilename));
        }

        // bug where canvas saving appears to be too slow, and subsequent mirroring fails ?!
        sleep(5);

        // once all processed the copy them all back into the original folder
        $filesystem->mirror(
            $tmpFolder,
            $target
        );
    }
}
