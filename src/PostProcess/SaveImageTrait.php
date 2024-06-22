<?php

namespace App\PostProcess;

use App\FolderNames;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\SplFileInfo;

trait SaveImageTrait
{
    protected ?string $tmpFolder = null;

    private function setupSaveBehaviour(bool $useIntermediateFolder): void
    {
        if (!$useIntermediateFolder) {
            return;
        }

        if (!isset($this->path) || !$this->path instanceof Path) {
            throw new \RuntimeException('Path must be defined to use this postprocessing trait');
        }

        $this->tmpFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'post-process',
            $this->getName(),
            hash('xxh3', (string) mt_rand())
        );

        $filesystem = new Filesystem();

        $filesystem->mkdir($this->tmpFolder);
    }

    private function getSavePath(SplFileInfo|string $file): string
    {
        if (null === $this->tmpFolder) {
            return is_string($file) ? $file : $file->getRealPath();
        }

        $filename = null;

        if ($file instanceof SplFileInfo) {
            $filename = $file->getFilename();
        }

        if (is_string($file)) {
            $filename = basename($file);
        }

        if (!$filename) {
            throw new \LogicException();
        }

        return Path::join($this->tmpFolder, $filename);
    }

    private function mirrorTemporaryFolderIfRequired(string $target): void
    {
        if (!$this->tmpFolder) {
            return;
        }

        $filesystem = new Filesystem();

        try {
            // filesystem update issues?
            sleep(5);

            // once all processed the copy them all back into the original folder
            // bug where canvas saving appears to be too slow, and subsequent mirroring fails ?!
            $filesystem->mirror(
                $this->tmpFolder,
                $target
            );
        } catch (\Throwable $t) {
            if (isset($this->logger)) {
                $this->logger->error($t->getMessage());
            }
        }
    }
}
