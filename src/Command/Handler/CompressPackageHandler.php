<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\CompressPackageCommand;
use App\Provider\PathProvider;
use PhpZip\Constants\ZipCompressionMethod;
use PhpZip\Exception\ZipException;
use PhpZip\ZipFile;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;

readonly class CompressPackageHandler implements CommandHandlerInterface
{
    public function __construct(
        private PathProvider $pathProvider,
        private LoggerInterface $logger
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof CompressPackageCommand) {
            throw new \InvalidArgumentException();
        }

        $packagePath = $this->pathProvider->getPackageRootPath($command->packageName);

        $outPath = $this->pathProvider->getPackageZipPath($command->packageName);

        $filesystem = new Filesystem();
        if ($filesystem->exists($outPath)) {
            $filesystem->remove($outPath);
        }

        $zip = new ZipFile();

        try {
            $zip->addDirRecursive($packagePath, '/mnt/mmc/', ZipCompressionMethod::DEFLATED)
                ->saveAsFile($outPath);
        } catch (ZipException $e) {
            $this->logger->error($e->getMessage());
        }
    }
}
