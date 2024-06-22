<?php

namespace App\Translator;

use App\Util\Path;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\Filesystem\Filesystem;

class CachedTranslationEraser
{
    public function __construct(
        #[Autowire('%kernel.cache_dir%')]
        private string $cacheDir,
    ) {
    }

    public function erase(): void
    {
        // @todo remove this class I dont think it's needed
        //        $filesystem = new Filesystem();
        //        $filesystem->remove(Path::join($this->cacheDir, 'translations'));
    }
}
