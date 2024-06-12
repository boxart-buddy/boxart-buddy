<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\CompressPackageCommand;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Util\Path;
use PhpZip\Constants\ZipCompressionMethod;
use PhpZip\Exception\ZipException;
use PhpZip\ZipFile;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;

readonly class CompressPackageHandler implements CommandHandlerInterface
{
    public function __construct(
        private ConfigReader $configReader,
        private Path $path,
        private LoggerInterface $logger
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof CompressPackageCommand) {
            throw new \InvalidArgumentException();
        }

        $config = $this->configReader->getConfig();
        $romSetName = $config->romsetName;

        $packagePath = $this->path->joinWithBase(
            FolderNames::PACKAGE->value,
            sprintf('%s_%s', $command->packageName, $romSetName)
        );

        $outPath = $this->path->joinWithBase(
            FolderNames::ZIPPED->value,
            sprintf('%s_%s.zip', $command->packageName, $romSetName)
        );

        $filesystem = new Filesystem();
        if ($filesystem->exists($outPath)) {
            $filesystem->remove($outPath);
        }

        $zip = new ZipFile();

        try {
            $zip->addDirRecursive($packagePath, '/', ZipCompressionMethod::DEFLATED)
                ->saveAsFile($outPath);
        } catch (ZipException $e) {
            $this->logger->error($e->getMessage());
        }
    }
}
