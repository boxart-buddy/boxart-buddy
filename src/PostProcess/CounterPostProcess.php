<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;
use App\Provider\OrderedListProvider;
use App\Provider\PathProvider;
use App\Util\Path;
use Intervention\Image\Geometry\Factories\LineFactory;
use Intervention\Image\ImageManager;
use Intervention\Image\Interfaces\ImageInterface;
use Intervention\Image\Typography\FontFactory;
use Psr\Log\LoggerInterface;

class CounterPostProcess implements PostProcessInterface
{
    use ArtworkTrait;
    use SaveImageTrait;

    public const NAME = 'counter';

    public function __construct(
        readonly private LoggerInterface $logger,
        readonly private Path $path,
        readonly private OrderedListProvider $orderedListProvider,
        readonly private PathProvider $pathProvider,
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
        return CounterPostProcessOptions::mergeDefaults($options);
    }

    /**
     * @throws PostProcessOptionException|PostProcessMissingOptionException
     */
    public function process(PostProcessCommand $command): void
    {
        $this->setupSaveBehaviour(true);

        $options = $this->processOptions($command->options);
        $workset = $this->getSortedArtwork($command->target, $options, $this->logger, $this->orderedListProvider);
        $this->processWorkset($workset, $command->target, $options);
    }

    private function processWorkset(array $files, string $target, array $options): void
    {
        foreach ($files as $originalFilePath) {
            $manager = ImageManager::imagick();
            $canvasX = 640;
            $canvasY = 480;
            $canvas = $manager->create($canvasX, $canvasY);

            // insert the image on top
            $originalImage = $manager->read($originalFilePath);
            $canvas->place($originalImage);

            // Add a 'counter'
            $counter = $this->getCounter($files, $options, $originalFilePath, $manager);

            $position = $options[CounterPostProcessOptions::POSITION];

            $offsetX = $options[CounterPostProcessOptions::OFFSET_X];
            $offsetY = $options[CounterPostProcessOptions::OFFSET_Y];

            $canvas->place(
                $counter,
                $position,
                $offsetX,
                $offsetY,
                $options[CounterPostProcessOptions::OPACITY]
            );

            $canvas->save($this->getSavePath($originalFilePath));
        }

        $this->mirrorTemporaryFolderIfRequired($target);
    }

    private function getCounter(array $files, array $options, string $currentFile, ImageManager $manager): ImageInterface
    {
        $height = 180;
        $width = 180;

        $fontFamily = $options[CounterPostProcessOptions::TEXT_FONT_FAMILY];
        $fontVariant = $options[CounterPostProcessOptions::TEXT_FONT_VARIANT];
        $color = $options[CounterPostProcessOptions::TEXT_COLOR];

        $counter = $manager->create($width, $height);
        $total = count($files);

        $currentPosition = (int) array_search($currentFile, $files);

        $fontPath = $this->pathProvider->getFontPath($fontFamily, $fontVariant);

        $counter->text(
            (string) ($currentPosition + 1),
            95,
            90,
            function (FontFactory $font) use ($fontPath, $color) {
                $font->filename($fontPath);
                $font->size(30);
                $font->color($color);
                $font->align('right');
                $font->valign('center');
            }
        );

        $counter->text(
            (string) $total,
            100,
            125,
            function (FontFactory $font) use ($fontPath, $color) {
                $font->filename($fontPath);
                $font->size(30);
                $font->color($color);
                $font->align('left');
                $font->valign('center');
            }
        );

        // draw splitter
        $counter->drawLine(function (LineFactory $line) use ($color) {
            $line->from(78, 113);
            $line->to(118, 99);
            $line->color($color); // color of line
            $line->width(2); // line width in pixels
        });

        return $counter;
    }
}
