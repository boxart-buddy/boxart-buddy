<?php

namespace App\Preview;

use App\Theme\ThemePaths;
use App\Theme\ThemeReader;
use App\Util\Path;
use Intervention\Image\Geometry\Factories\RectangleFactory;
use Intervention\Image\ImageManager;
use Intervention\Image\Interfaces\ImageInterface;
use Intervention\Image\Typography\FontFactory;
use PhpZip\Exception\ZipException;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

readonly class PreviewGenerator
{
    public function __construct(
        private ThemeReader $themeReader,
        private Path $path,
        private LoggerInterface $logger
    ) {
    }

    public function generatePreview(string $target, int $gridSize, string $previewName, ?string $theme): void
    {
        if ($gridSize < 1) {
            throw new \InvalidArgumentException('Grid size must be greater than 0');
        }

        $themeImages = [];
        if ($theme) {
            try {
                $themeImages = $this->themeReader->getImagePaths($theme);
            } catch (ZipException $e) {
                $this->logger->error(
                    $e->getMessage(),
                );
            }
        }

        $inFolder = Path::join($target, 'MUOS');
        $outFolder = Path::join($target, 'extra', 'preview');

        $filesystem = new Filesystem();

        $filesystem->mkDir($outFolder);

        // jump into each folder and get random screenshots
        $finder = new Finder();
        $finder->in($inFolder);
        $pattern = '#/box/#';
        $finder->files()->path($pattern)->name('*.png');

        if (!$finder->hasResults()) {
            return;
        }
        // randomize the screenshots
        $files = [];
        foreach ($finder as $screenshot) {
            $files[$screenshot->getRealPath()] = $screenshot->getFilename();
        }
        // shuffle but preserves keys
        uksort($files, function ($k, $v) { return rand() > rand() ? 1 : -1; });

        $screenshotCount = 0;
        $screenshotLimit = $gridSize * $gridSize;
        $screenshots = [];

        foreach ($files as $screenshotRealPath => $screenshotFilename) {
            if ($screenshotCount === $screenshotLimit) {
                break;
            }
            $screenshots[$screenshotRealPath] = $screenshotFilename;
            ++$screenshotCount;
        }

        $previews = array_chunk($screenshots, $gridSize, true);

        $canvas = $this->initializeCanvas(
            $gridSize,
            $gridSize,
            $previewName,
            $theme
        );

        $i = 0;
        foreach ($previews as $screenshots) {
            $this->addScreenshotsToImage($i, $canvas, $screenshots, $themeImages);
            ++$i;
        }

        $canvas->save(Path::join($outFolder, $previewName.'-'.($theme ?: 'transparent').'.png'));
    }

    private function addScreenshotsToImage(
        int $row,
        ImageInterface $canvas,
        array $screenshots,
        array $themeImages
    ): void {
        $dimensions = $this->getDimensions();
        $i = 0;

        $bgImage = $themeImages[ThemePaths::DEFAULT->name] ?? null;
        $overlayImage = $themeImages[ThemePaths::OVERLAY->name] ?? null;

        foreach ($screenshots as $filepath => $filename) {
            $x = $dimensions['spacerX'] + ($i * ($dimensions['spacerX'] + $dimensions['screenX']));
            $y = $dimensions['headerY'] + $dimensions['spacerY'] + ($row * ($dimensions['spacerY'] + $dimensions['screenY']));

            // inset background image if it exists....
            if ($bgImage) {
                $canvas->place(
                    $bgImage,
                    'top-left',
                    $x,
                    $y
                );
            }

            $canvas->place(
                $filepath,
                'top-left',
                $x,
                $y,
            );

            // inset overlay image if it exists....
            if ($overlayImage) {
                $canvas->place(
                    $overlayImage,
                    'top-left',
                    $x,
                    $y
                );
            }

            // draw an rectangle with a border
            // $this->canvas->drawRectangle($x - 2, $y - 2, function (RectangleFactory $rectangle) use ($dimensions) {
            //     $rectangle->size($dimensions['screenX'], $dimensions['screenY']); // width & height of rectangle
            //     $rectangle->border('black', 2); // border color & size of rectangle
            // });

            /**
             * Add title.
             */
            $title = $filename;
            $titleX = $x + 2;
            $titleY = (int) round($y + $dimensions['screenY'] + floor($dimensions['spacerY'] / 4));

            // dirty trim title method - would be better to have staggered font sizes?
            if (strlen($title) > 40) {
                $title = substr($title, 0, 36).'…';
            }

            $fontPath = $this->getFontPath('bold');
            $canvas->text($title, $titleX, $titleY, function (FontFactory $font) use ($fontPath) {
                $font->filename($fontPath);
                $font->size(28);
                $font->color('000');
                $font->align('left');
                $font->valign('middle');
            });

            ++$i;
        }
    }

    private function initializeCanvas(
        int $width,
        int $height,
        string $title,
        ?string $themeTitle = null
    ): ImageInterface {
        $dimensions = $this->getDimensions();

        $canvasX = ($width * $dimensions['screenX']) + (($width + 1) * $dimensions['spacerX']);
        $canvasY = $dimensions['headerY'] + ($height * $dimensions['screenY']) + (($height + 1) * $dimensions['spacerY']);

        $manager = ImageManager::imagick();

        $canvas = $manager->create($canvasX, $canvasY);

        // fill the background in a 'grid'
        $bgColor = 'white';
        for ($x = 0; $x <= $height + 1; ++$x) {
            $placementY = $dimensions['headerY'] + ($x * $dimensions['screenY']) + ($x * $dimensions['spacerY']);
            $canvas->drawRectangle(0, $placementY, function (RectangleFactory $rectangle) use ($dimensions, $canvasX, $bgColor) {
                $rectangle->size($canvasX, $dimensions['spacerY']);
                $rectangle->background($bgColor);
            });
            for ($z = 0; $z <= $width + 1; ++$z) {
                $placementX = ($z * $dimensions['screenX']) + ($z * $dimensions['spacerX']);
                $gridHeight = $canvasY - $dimensions['headerY'];
                $canvas->drawRectangle($placementX, $dimensions['headerY'], function (RectangleFactory $rectangle) use ($dimensions, $gridHeight, $bgColor) {
                    $rectangle->size($dimensions['spacerX'], $gridHeight);
                    $rectangle->background($bgColor);
                });
            }
        }
        $canvas->drawRectangle(0, 0, function (RectangleFactory $rectangle) use ($dimensions, $canvasX, $bgColor) {
            $rectangle->size($canvasX, $dimensions['headerY']);
            $rectangle->background($bgColor);
        });

        // add a title
        $fontPath = $this->getFontPath();

        $fontSize = min([floor($canvasX / mb_strlen($title) * 1.25), 100]);
        $canvas->text(
            $title,
            $canvasX / 2,
            100,
            function (FontFactory $font) use ($fontPath, $fontSize) {
                $font->filename($fontPath);
                $font->size($fontSize);
                $font->color('000');
                $font->align('center');
                $font->valign('middle');
            }
        );

        if ($themeTitle) {
            $fontSize = min([floor($canvasX / (mb_strlen($themeTitle) + 11) * 0.6), 50]);
            $canvas->text(
                sprintf('with theme `%s`', $themeTitle),
                $canvasX / 2,
                200,
                function (FontFactory $font) use ($fontPath, $fontSize) {
                    $font->filename($fontPath);
                    $font->size($fontSize);
                    $font->color('000');
                    $font->align('center');
                    $font->valign('middle');
                }
            );
        }

        return $canvas;
    }

    private function getDimensions(): array
    {
        return [
            'screenX' => 640,
            'screenY' => 480,
            'spacerX' => 80,
            'spacerY' => 120,
            'headerY' => 200,
        ];
    }

    private function getFontPath(?string $variant = null): string
    {
        return match ($variant) {
            'bold' => $this->path->joinWithBase('resources', 'font', 'Cousine-Bold.ttf'),
            'italic' => $this->path->joinWithBase('resources', 'font', 'Cousine-Italic.ttf'),
            'bold-italic' => $this->path->joinWithBase('resources', 'font', 'Cousine-BoldItalic.ttf'),
            default => $this->path->joinWithBase('resources', 'font', 'Cousine-Regular.ttf')
        };
    }
}
