<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\CopyBackPreviewCommand;
use App\FolderNames;
use App\Provider\PathProvider;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;

readonly class CopyBackPreviewHandler implements CommandHandlerInterface
{
    public function __construct(
        private Path $path,
        private PathProvider $pathProvider
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        $filesystem = new Filesystem();

        if (!$command instanceof CopyBackPreviewCommand) {
            throw new \InvalidArgumentException();
        }

        $packagePreviewFolder = Path::join(
            $this->pathProvider->getPackageRootPath($command->packageName),
            'extra',
            'preview'
        );

        if (!$filesystem->exists($packagePreviewFolder)) {
            return;
        }

        // get artwork preview folder
        $templatePreviewFolder = $this->path->joinWithBase(
            FolderNames::TEMPLATE->value,
            $command->artworkPackage,
            'preview'
        );

        // mirror one to the other (copy/overwrite)
        $filesystem = new Filesystem();
        $filesystem->mirror($packagePreviewFolder, $templatePreviewFolder);
    }
}
