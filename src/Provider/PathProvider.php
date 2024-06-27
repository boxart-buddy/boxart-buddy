<?php

namespace App\Provider;

use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Util\Path;

// this class possibly redundant and functions to be moved back to classes where used
readonly class PathProvider
{
    public function __construct(private Path $path, private ConfigReader $configReader)
    {
    }

    public function getOutputPathForGeneratedArtwork(string $namespace, string $platform): string
    {
        return $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'output',
            $namespace,
            'generated_artwork',
            $platform
        );
    }

    public function getGamelistPath(string $namespace, string $platform): string
    {
        return $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'output',
            $namespace,
            'gamelist',
            $platform
        );
    }

    public function getPortmasterRomPath(): string
    {
        return $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'roms/');
    }

    public function getPackageRootPath(string $packageName): string
    {
        $romsetName = $this->configReader->getConfig()->romsetName;

        return $this->path->joinWithBase(FolderNames::PACKAGE->value, $packageName.'-'.$romsetName);
    }

    public function getPackageZipPath(string $packageName): string
    {
        $romsetName = $this->configReader->getConfig()->romsetName;

        return $this->path->joinWithBase(FolderNames::ZIPPED->value, $packageName.'-'.$romsetName.'.zip');
    }

    public function getFontPath(string $family, ?string $variant = null): string
    {
        if ('cousine' === $family) {
            return match ($variant) {
                'bold' => $this->path->joinWithBase('resources', 'font', 'cousine', 'Cousine-Bold.ttf'),
                'italic' => $this->path->joinWithBase('resources', 'font', 'cousine', 'Cousine-Italic.ttf'),
                'bold-italic' => $this->path->joinWithBase('resources', 'cousine', 'font', 'Cousine-BoldItalic.ttf'),
                default => $this->path->joinWithBase('resources', 'font', 'cousine', 'Cousine-Regular.ttf')
            };
        }
        if ('roboto' === $family) {
            return match ($variant) {
                'black' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Black.ttf'),
                'black-italic' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-BlackItalic.ttf'),
                'bold' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Bold.ttf'),
                'bold-italic' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-BoldItalic.ttf'),
                'italic' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Italic.ttf'),
                'light' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Light.ttf'),
                'light-italic' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-LightItalic.ttf'),
                'medium' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Medium.ttf'),
                'medium-italic' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-MediumItalic.ttf'),
                'regular' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Regular.ttf'),
                'thin' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Thin.ttf'),
                'thin-italic' => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-ThinItalic.ttf'),
                default => $this->path->joinWithBase('resources', 'font', 'roboto', 'Roboto-Regular.ttf'),
            };
        }

        return match ($family) {
            'AKDPixel' => $this->path->joinWithBase('resources', 'font', 'pixel', 'AKDPixel.ttf'),
            'AtariGames' => $this->path->joinWithBase('resources', 'font', 'pixel', 'AtariGames.ttf'),
            'Awexbmp' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Awexbmp.ttf'),
            'BIOSfontII' => $this->path->joinWithBase('resources', 'font', 'pixel', 'BIOSfontII.ttf'),
            'BasicChineseLine' => $this->path->joinWithBase('resources', 'font', 'pixel', 'BasicChineseLine.ttf'),
            'Beanstalk' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Beanstalk.ttf'),
            'Bitfantasy' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Bitfantasy.ttf'),
            'CelticTime' => $this->path->joinWithBase('resources', 'font', 'pixel', 'CelticTime.ttf'),
            'ClassicShit' => $this->path->joinWithBase('resources', 'font', 'pixel', 'ClassicShit.ttf'),
            'DisrespectfulTeenager' => $this->path->joinWithBase('resources', 'font', 'pixel', 'DisrespectfulTeenager.ttf'),
            'GTA2PSX' => $this->path->joinWithBase('resources', 'font', 'pixel', 'GTA2PSX.ttf'),
            'Habbo' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Habbo.ttf'),
            'KarenFat' => $this->path->joinWithBase('resources', 'font', 'pixel', 'KarenFat.ttf'),
            'Khonjin' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Khonjin.ttf'),
            'Kubasta' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Kubasta.ttf'),
            'LCDBlock' => $this->path->joinWithBase('resources', 'font', 'pixel', 'LCDBlock.ttf'),
            'LessRoundBox' => $this->path->joinWithBase('resources', 'font', 'pixel', 'LessRoundBox.ttf'),
            'LowIndustrial' => $this->path->joinWithBase('resources', 'font', 'pixel', 'LowIndustrial.ttf'),
            'MMXSNES' => $this->path->joinWithBase('resources', 'font', 'pixel', 'MMXSNES.ttf'),
            'MyHandwriting' => $this->path->joinWithBase('resources', 'font', 'pixel', 'MyHandwriting.ttf'),
            'NameHereCondensed' => $this->path->joinWithBase('resources', 'font', 'pixel', 'NameHereCondensed.ttf'),
            'PixNull' => $this->path->joinWithBase('resources', 'font', 'pixel', 'PixNull.ttf'),
            'PixelNewspaperIII' => $this->path->joinWithBase('resources', 'font', 'pixel', 'PixelNewspaperIII.ttf'),
            'Rockboxcond12' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Rockboxcond12.ttf'),
            'SandyForest' => $this->path->joinWithBase('resources', 'font', 'pixel', 'SandyForest.ttf'),
            'SquareSounds' => $this->path->joinWithBase('resources', 'font', 'pixel', 'SquareSounds.ttf'),
            'SuperTechnology' => $this->path->joinWithBase('resources', 'font', 'pixel', 'SuperTechnology.ttf'),
            'TWEENIESDODDLEBINES' => $this->path->joinWithBase('resources', 'font', 'pixel', 'TWEENIESDODDLEBINES.ttf'),
            'Tallpix' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Tallpix.ttf'),
            'ThickPixels' => $this->path->joinWithBase('resources', 'font', 'pixel', 'ThickPixels.ttf'),
            'TinyPixie2' => $this->path->joinWithBase('resources', 'font', 'pixel', 'TinyPixie2.ttf'),
            'TinyUnicode' => $this->path->joinWithBase('resources', 'font', 'pixel', 'TinyUnicode.ttf'),
            'TripleN' => $this->path->joinWithBase('resources', 'font', 'pixel', 'TripleN.ttf'),
            'Unknown' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Unknown.ttf'),
            'Zicons' => $this->path->joinWithBase('resources', 'font', 'pixel', 'Zicons.ttf'),
            'c64esque' => $this->path->joinWithBase('resources', 'font', 'pixel', 'c64esque.ttf'),
            'daryloo' => $this->path->joinWithBase('resources', 'font', 'pixel', 'daryloo.ttf'),
            'fude' => $this->path->joinWithBase('resources', 'font', 'pixel', 'fude.ttf'),
            'prevoard' => $this->path->joinWithBase('resources', 'font', 'pixel', 'prevoard.ttf'),
            'scribble1' => $this->path->joinWithBase('resources', 'font', 'pixel', 'scribble1.ttf'),
            default => $this->path->joinWithBase('resources', 'font', 'pixel', 'scribble1.ttf'),
        };
    }

    public function getRandomFontPath(): string
    {
        $fonts = ['AtariGames', 'CelticTime', 'MMXSNES', 'KarenFat', 'ClassicShit', 'PixelNewspaperIII', 'Rockboxcond12'];
        $family = $fonts[array_rand($fonts)];

        return $this->getFontPath($family);
    }
}
