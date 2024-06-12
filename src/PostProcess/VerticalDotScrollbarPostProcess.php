<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;
use App\FolderNames;
use App\Util\Path;
use Intervention\Image\Geometry\Factories\CircleFactory;
use Intervention\Image\ImageManager;
use Intervention\Image\Interfaces\ImageInterface;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;

readonly class VerticalDotScrollbarPostProcess implements PostProcessInterface
{
    use ArtworkTrait;

    public const NAME = 'vertical_dot_scrollbar';

    public function __construct(private Path $path, private LoggerInterface $logger)
    {
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
        $options = $this->processOptions($command->options);
        $workset = $this->getSortedArtwork($command->target, $options, $this->logger);
        $this->processWorkset($workset, $command->target, $options);
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
        $borderColor = 'white';
        $dotColor = 'white';
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
