<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;
use App\FolderNames;
use App\Util\Path;
use Intervention\Image\ImageManager;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;

readonly class OffsetWithSiblingsPostProcess implements PostProcessInterface
{
    use ArtworkTrait;

    public const NAME = 'offset_with_siblings';

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
        return OffsetWithSiblingsPostProcessOptions::mergeDefaults($options);
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
        $count = 0;
        $workset = [];

        $siblingsAmount = (int) $options[OffsetWithSiblingsPostProcessOptions::SIBLING_COUNT];
        $totalSiblingCount = (int) ($siblingsAmount * 2) + 1;

        foreach ($files as $currentFile) {
            $set = [];

            for ($x = 0; $x < $totalSiblingCount; ++$x) {
                $siblingKey = (int) ($count - (($x - $siblingsAmount) * -1));

                $set[$x] = $files[$siblingKey] ?? null;
            }
            $workset[] = $set;
            ++$count;
        }

        $filesystem = new Filesystem();

        $tmpFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'post-process',
            self::NAME,
            hash('xxh3', (string) mt_rand())
        );

        $iteration = 0;
        foreach ($workset as $set) {
            ++$iteration;
            $canvasX = 640;
            $canvasY = 480;
            $manager = ImageManager::imagick();
            $canvas = $manager->create($canvasX, $canvasY);

            //            $logoWidth = 220;
            //            $outerSize = 40;
            //            $innerSize = 120;

            $middleKey = floor(count($set) / 2);

            $siblings = $this->reorderArrayOutToIn($set);
            $originalImage = array_pop($siblings);
            $originalFilename = basename($originalImage);

            foreach ($siblings as $siblingKey => $sibling) {
                if (null === $sibling) {
                    continue;
                }

                $offsetIndex = (int) ($siblingKey - $middleKey);
                $siblingImage = $manager->read($sibling);

                $totalOffsetY = $options[OffsetWithSiblingsPostProcessOptions::OFFSET_Y] * $offsetIndex;
                $totalOffsetX = $options[OffsetWithSiblingsPostProcessOptions::OFFSET_X] * $offsetIndex;

                $scale = $options[OffsetWithSiblingsPostProcessOptions::SCALE] ?? null;

                if ($scale) {
                    $targetWidth = $this->getTargetWidth($canvasX, $scale, $offsetIndex, (float) $totalSiblingCount);
                    $siblingImage->scaleDown(width: $targetWidth);
                    $totalOffsetY = $this->getTargetOffset(
                        $options[OffsetWithSiblingsPostProcessOptions::OFFSET_Y], $scale, $offsetIndex, $totalSiblingCount
                    );
                    $totalOffsetX = $this->getTargetOffset(
                        $options[OffsetWithSiblingsPostProcessOptions::OFFSET_X], $scale, $offsetIndex, $totalSiblingCount
                    );
                }

                $effects = $options[OffsetWithSiblingsPostProcessOptions::EFFECT];
                if ($effects) {
                    foreach ($effects as $effect) {
                        $siblingImage = match ($effect) {
                            'greyscale' => $siblingImage->greyscale(),
                            'blur' => $siblingImage->blur(3),
                            'pixelate' => $siblingImage->pixelate(4),
                            default => throw new \InvalidArgumentException(sprintf('Unknown effect `%s`', $effect)),
                        };
                    }
                }

                $canvas->place(
                    $siblingImage,
                    'center',
                    $totalOffsetX,
                    $totalOffsetY,
                );
            }

            // insert the original 'middle' image on top
            $canvas->place($originalImage);

            // save to temp location
            if (!$filesystem->exists($tmpFolder)) {
                $filesystem->mkDir($tmpFolder);
            }

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

    private function getTargetWidth(int $originalWidth, float $scale, int $offsetIndex, float $logScale): int
    {
        $diff = (int) floor($originalWidth - ($originalWidth * $scale));
        $mult = log(abs($offsetIndex), $logScale);

        return (int) max(round($originalWidth - ($diff + ($diff * $mult))), 40);
    }

    private function getTargetOffset(int $offset, float $scale, int $offsetIndex, float $logScale): int
    {
        $diff = (int) floor($offset - ($offset * $scale));

        $mult = log(abs($offsetIndex), $logScale);

        return (int) (($offset - min(round($diff * $mult), $diff)) * $offsetIndex);
    }

    private function reorderArrayOutToIn(array $source): array
    {
        $keys = array_keys($source);
        $result = [];
        $n = count($keys);

        // Left and right pointers
        $left = 0;
        $right = $n - 1;

        // Loop to rearrange the keys
        while ($left <= $right) {
            if ($left <= $right) {
                $result[$keys[$left]] = $source[$keys[$left]];
                ++$left;
            }
            if ($left <= $right) {
                $result[$keys[$right]] = $source[$keys[$right]];
                --$right;
            }
        }

        return $result;
    }
}
