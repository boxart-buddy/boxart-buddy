<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;
use App\Util\Path;
use Intervention\Image\Geometry\Factories\CircleFactory;
use Intervention\Image\ImageManager;
use Intervention\Image\Interfaces\ImageInterface;
use Psr\Log\LoggerInterface;

class VerticalDotScrollbarPostProcess implements PostProcessInterface
{
    use ArtworkTrait;
    use SaveImageTrait;

    public const NAME = 'vertical_dot_scrollbar';

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
        return VerticalDotScrollbarPostProcessOptions::mergeDefaults($options);
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
            $scrollBar = $this->getDotsScrollBar($files, $options, $originalFilePath, $manager);

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

    private function getDotsScrollBar(array $files, array $options, string $currentFile, ImageManager $manager): ImageInterface
    {
        // could use a more elegant solution for pagination here probably but this works for now

        $dotDiameter = 8;
        $height = 300;
        $yPadding = 10;
        $width = 30;
        $maxNumberOfDots = (int) floor($height / ($dotDiameter + 8));
        $numberOfDots = min(count($files), $maxNumberOfDots);
        $spaces = $numberOfDots - 1;

        $totalSpace = floor($height - ($numberOfDots * $dotDiameter));

        $singleSpace = floor($totalSpace / $spaces);
        $borderColor = $options[VerticalDotScrollbarPostProcessOptions::DOTCOLOR];
        $dotColor = $options[VerticalDotScrollbarPostProcessOptions::DOTCOLOR];
        $activeDotBorder = 4;

        $scrollBar = $manager->create($width, $height + (2 * $yPadding));

        $totalFiles = count($files);

        $currentPosition = (int) array_search($currentFile, $files);

        $itemsPerPage = (int) max(round($totalFiles / $numberOfDots), 1);

        $currentPage = (int) floor($currentPosition / $itemsPerPage);

        for ($x = 0; $x < $numberOfDots; ++$x) {
            $activeDot = ($x == $currentPage);
            $yPos = (int) ($yPadding + ($x * $dotDiameter) + ($x * $singleSpace));
            $scrollBar->drawCircle($width / 2, $yPos, function (CircleFactory $circle) use ($dotDiameter, $dotColor, $borderColor, $activeDot, $activeDotBorder) {
                $circle->radius($dotDiameter / 2);
                if (!$activeDot) {
                    $circle->background($dotColor);
                }
                // only if selected
                if ($activeDot) {
                    $circle->border($borderColor, $activeDotBorder);
                }
            });
        }

        return $scrollBar;
    }
}
