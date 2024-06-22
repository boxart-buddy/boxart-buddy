<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;
use App\Util\Path;
use Intervention\Image\Geometry\Factories\RectangleFactory;
use Intervention\Image\ImageManager;
use Intervention\Image\Interfaces\ImageInterface;
use Psr\Log\LoggerInterface;

class VerticalScrollbarPostProcess implements PostProcessInterface
{
    use ArtworkTrait;
    use SaveImageTrait;

    public const NAME = 'vertical_scrollbar';

    public function __construct(
        readonly private Path $path,
        readonly private LoggerInterface $logger
    ) {
    }

    public function getName(): string
    {
        return self::NAME;
    }

    /**
     * @throws PostProcessOptionException|PostProcessMissingOptionException
     */
    public function processOptions(array $options): array
    {
        return VerticalScrollbarPostProcessOptions::mergeDefaults($options);
    }

    /**
     * @throws PostProcessOptionException|PostProcessMissingOptionException
     */
    public function process(PostProcessCommand $command): void
    {
        $this->setupSaveBehaviour(true);

        $options = $this->processOptions($command->options);
        $workset = $this->getSortedArtwork($command->target, $options, $this->logger);
        $this->processWorkset($workset, $command->target, $options);
    }

    private function processWorkset(array $files, string $target, array $options): void
    {
        foreach ($files as $originalFilePath) {
            $originalFilename = basename($originalFilePath);
            $manager = ImageManager::imagick();
            $canvasX = 640;
            $canvasY = 480;
            $canvas = $manager->create($canvasX, $canvasY);

            // insert the image on top
            $originalImage = $manager->read($originalFilePath);
            $canvas->place($originalImage);

            // Add a 'scrollbar'
            $scrollBar = $this->getBarScrollBar($files, $options, $originalFilePath, $manager);

            $scrollBarPosition = match ($options[VerticalScrollbarPostProcessOptions::POSITION]) {
                'left' => 'top-left',
                'right' => 'top-right',
                default => throw new \RuntimeException()
            };

            $canvas->place(
                $scrollBar,
                $scrollBarPosition,
                20,
                90,
                $options[VerticalScrollbarPostProcessOptions::OPACITY]
            );

            $canvas->save($this->getSavePath($originalFilePath));
        }

        $this->mirrorTemporaryFolderIfRequired($target);
    }

    private function getBarScrollBar(array $files, array $options, string $currentFile, ImageManager $manager): ImageInterface
    {
        $height = 300;
        $width = 20;
        // applied _inside_ the track
        $trackPadding = 2;
        $thumbHeight = 30;
        $thumbWidth = ($width - (2 * $trackPadding));

        $trackRange = ($height - $thumbHeight - ($trackPadding * 2));

        $trackColor = $options[VerticalScrollbarPostProcessOptions::TRACK_COLOR];
        $thumbColor = $options[VerticalScrollbarPostProcessOptions::THUMB_COLOR];

        $scrollBar = $manager->create($width, $height);

        $totalFiles = count($files);

        $currentPosition = (int) array_search($currentFile, $files);

        $thumbYPosition = (int) round($currentPosition * ($trackRange / ($totalFiles - 1))) + $trackPadding;
        $thumbXPosition = (($width - $thumbWidth) / 2);

        // draw track
        $scrollBar->drawRectangle(0, 0, function (RectangleFactory $rectangle) use ($height, $width, $trackColor) {
            $rectangle->size($width, $height);
            $rectangle->background($trackColor);
            // $rectangle->border('white', 2);
        });

        // draw thumb
        $scrollBar->drawRectangle($thumbXPosition, $thumbYPosition, function (RectangleFactory $rectangle) use ($thumbWidth, $thumbHeight, $thumbColor) {
            $rectangle->size($thumbWidth - 1, $thumbHeight);
            $rectangle->background($thumbColor);
        });

        return $scrollBar;
    }
}
