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
    use SaveImageTrait;

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
        $this->setupSaveBehaviour(false);

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

        foreach ($files as $originalFilePath) {
            $manager = ImageManager::imagick();
            $canvasX = 640;
            $canvasY = 480;
            $canvas = $manager->create($canvasX, $canvasY);

            if (!isset($options['background']) && !isset($options['overlay'])) {
                throw new \RuntimeException('Background and/or Overlay options are required');
            }

            if (isset($options['background'])) {
                foreach ($options['background'] as $background) {
                    $bg = $this->path->joinWithBase(
                        FolderNames::TEMP->value,
                        'post-process',
                        'resources',
                        $background
                    );

                    if (!$filesystem->exists($bg)) {
                        throw new \InvalidArgumentException(sprintf('Background image "%s" does not exist', $bg));
                    }

                    $canvas->place($bg);
                }
            }

            // insert the image on top
            $originalImage = $manager->read($originalFilePath);
            $canvas->place($originalImage);

            if (isset($options['overlay'])) {
                // overlay
                $overlay = $this->path->joinWithBase(
                    FolderNames::TEMP->value,
                    'post-process',
                    'resources',
                    $options['overlay']
                );

                if (!$filesystem->exists($overlay)) {
                    throw new \InvalidArgumentException(sprintf('Overlay image "%s" does not exist', $overlay));
                }

                $canvas->place($overlay);
            }

            $canvas->save($this->getSavePath($originalFilePath));
        }

        $this->mirrorTemporaryFolderIfRequired($target);
    }
}
