<?php

namespace App\Util;

use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\Filesystem\Path as SymfonyPath;

readonly class Path
{
    public function __construct(
        #[Autowire('%kernel.project_dir%')]
        private string $basePath,
    ) {
    }

    public function joinWithBase(string ...$pathParts): string
    {
        array_unshift($pathParts, $this->basePath);

        return call_user_func_array([__CLASS__, 'join'], $pathParts);
    }

    public static function join(string ...$pathParts): string
    {
        $pattern = '#(/)+#';

        return SymfonyPath::canonicalize(
            (string) preg_replace($pattern, '/', join('/', $pathParts))
        );
    }

    public static function removeExtension(string $filename): string
    {
        return preg_replace('/\.[^.]*$/', '', $filename) ?? $filename;
    }
}
