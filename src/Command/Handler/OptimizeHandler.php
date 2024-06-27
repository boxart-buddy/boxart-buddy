<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\OptimizeCommand;
use App\Provider\PathProvider;
use App\Util\Path;
use Intervention\Image\Encoders\JpegEncoder;
use Intervention\Image\ImageManager;
use Spatie\ImageOptimizer\OptimizerChainFactory;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

readonly class OptimizeHandler implements CommandHandlerInterface
{
    public function __construct(private PathProvider $pathProvider)
    {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof OptimizeCommand) {
            throw new \InvalidArgumentException();
        }

        $packagePath = $this->pathProvider->getPackageRootPath($command->packageName);

        $optimizeBase = Path::join($packagePath, 'MUOS');

        $filesystem = new Filesystem();
        if ($command->convertToJpg) {
            $manager = ImageManager::imagick();
            // find all
            $finder = new Finder();
            $finder->in($optimizeBase);
            $finder->files()->name('*.png');
            foreach ($finder as $file) {
                $image = $manager->read($file->getRealPath());
                $encoded = $image->encode(new JpegEncoder((int) $command->jpgQuality));
                $old = $file->getRealPath();
                $new = substr($old, 0, -4).'.jpg';
                $encoded->save($new);
                $filesystem->remove($old);
            }
        }

        $finder = new Finder();
        $finder->in($optimizeBase);
        $finder->files()->name('*.png')->name('*.jpg');

        $optimizerChain = OptimizerChainFactory::create();

        foreach ($finder as $file) {
            $optimizerChain->optimize($file->getRealPath());
        }
    }
}
