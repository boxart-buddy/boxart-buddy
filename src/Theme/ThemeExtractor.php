<?php

namespace App\Theme;

use App\FolderNames;
use App\Util\Path;
use PhpZip\Exception\ZipException;
use PhpZip\ZipFile;
use Symfony\Component\Filesystem\Filesystem;

class ThemeExtractor
{
    public function __construct(private Path $path)
    {
    }

    /**
     * @throws ZipException
     */
    public function extract(string $theme): void
    {
        $themePath = $this->getThemePath($theme);

        $zipFile = new ZipFile();
        $zipFile->openFile($themePath);

        $tmp = $this->path->joinWithBase(FolderNames::TEMP->value, 'theme', 'inner', $theme);

        $filesystem = new Filesystem();
        $filesystem->mkDir($tmp);

        $zipFile->extractTo($tmp);
    }

    /**
     * Gets the path to the theme folder containing the artwork
     * Unzips 'inner' zip file and extracts to tmp if needed.
     *
     * @throws ZipException
     */
    public function getThemePath(string $theme): string
    {
        $zipPath = $this->path->joinWithBase(FolderNames::THEME->value, $theme);

        $filesystem = new Filesystem();

        if (!$filesystem->exists($zipPath)) {
            throw new \InvalidArgumentException(sprintf('Cannot find theme with filename `%s` in the project /theme folder', $theme));
        }

        $zipFile = new ZipFile();
        $zipFile->openFile($zipPath);
        $dotsToSpaces = preg_replace('/\.(?=.*\.)/', ' ', $theme);
        $innerTheme = 'mnt/mmc/MUOS/theme/'.$dotsToSpaces;
        $hasEntry = $zipFile->hasEntry($innerTheme);

        if (!$hasEntry) {
            // no inner theme
            return $zipPath;
        }

        $tmp = $this->path->joinWithBase(FolderNames::TEMP->value, 'theme', 'wrapper', $theme);

        $filesystem->mkDir($tmp);

        $zipFile->extractTo($tmp);

        return Path::join($tmp, $innerTheme);
    }
}
