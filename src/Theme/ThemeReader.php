<?php

namespace App\Theme;

use App\FolderNames;
use App\Util\Finder;
use App\Util\Path;
use PhpZip\Exception\ZipException;

readonly class ThemeReader
{
    public function __construct(
        private ThemeExtractor $themeExtractor,
        private Path $path
    ) {
    }

    /**
     * Returns relevant image paths from the given theme if they are present.
     * Accepts the name of a folder OR a zip file containing a theme.
     *
     * @throws ZipException
     */
    public function getImagePaths(string $themeName): array
    {
        $results = [];

        $themePath = $this->path->joinWithBase(FolderNames::THEME->value, $themeName);

        if (!is_dir($themePath)) {
            $extension = pathinfo($themePath, PATHINFO_EXTENSION);
            if ('zip' !== $extension) {
                throw new \InvalidArgumentException(sprintf('`%s` must be a theme folder OR zipfile in the project /theme folder', $themeName));
            }
            $this->themeExtractor->extract($themeName);

            $themePath = $this->path->joinWithBase(FolderNames::TEMP->value, 'theme', 'inner', $themeName);
        }

        // default
        $finder = new Finder();
        $finder->in($themePath);
        $finder->files()->path(ThemePaths::DEFAULT->value);
        if ($finder->hasResults()) {
            $results[ThemePaths::DEFAULT->name] = $finder->first()->getRealPath();
        }

        // overlay
        $finder = new Finder();
        $finder->in($themePath);
        $finder->files()->path(ThemePaths::OVERLAY->value);
        if ($finder->hasResults()) {
            $results[ThemePaths::OVERLAY->name] = $finder->first()->getRealPath();
        }

        return $results;
    }
}
