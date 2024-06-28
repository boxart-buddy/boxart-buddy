<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;
use App\Command\TransferCommand;
use App\Config\Reader\ConfigReader;
use App\Provider\PathProvider;
use League\Flysystem\Filesystem;
use League\Flysystem\FilesystemException;
use League\Flysystem\Local\LocalFilesystemAdapter;
use League\Flysystem\MountManager;
use League\Flysystem\PhpseclibV3\SftpAdapter;
use League\Flysystem\PhpseclibV3\SftpConnectionProvider;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem as SymfonyFilesystem;

readonly class TransferHandler implements CommandHandlerInterface
{
    private const REMOTE_CARD_PATH = '/SD1 (mmc)/';

    public function __construct(
        private ConfigReader $configReader,
        private PathProvider $pathProvider,
        private LoggerInterface $logger,
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof TransferCommand) {
            throw new \InvalidArgumentException();
        }

        if ($command->zipped) {
            $this->transferZipped($command);
        }

        if (!$command->zipped) {
            $this->transferPackedFolder($command);
        }
    }

    private function transferZipped($command): void
    {
        $config = $this->configReader->getConfig();

        $zipPath = $this->pathProvider->getPackageZipPath($command->packageName);

        // check package folder exists
        $fs = new SymfonyFilesystem();
        if (!$fs->exists($zipPath)) {
            throw new \InvalidArgumentException(sprintf('No zip exists with name `%s`, cannot transfer', $zipPath));
        }

        if (!$config->sftpIp || !$config->sftpPass || !$config->sftpUser || !$config->sftpPort) {
            throw new \RuntimeException('Cannot transfer to SFTP as sftp config variables are missing. Make sure you set ip,pass,user,port in config.yml');
        }

        $local = new LocalFilesystemAdapter(dirname($zipPath));

        $connectionProvider = new SftpConnectionProvider(
            $config->sftpIp,
            $config->sftpUser,
            $config->sftpPass,
            null,
            null,
            (int) $config->sftpPort,
            false,
            8,
            1,
        );

        $sftpAdapter = new SftpAdapter(
            $connectionProvider,
            self::REMOTE_CARD_PATH
        );

        $filesystemSftp = new Filesystem($sftpAdapter);
        $filesystemLocal = new Filesystem($local);

        $mountManager = new MountManager([
            'local' => $filesystemLocal,
            'sftp' => $filesystemSftp,
        ]);

        try {
            $mountManager->copy(
                sprintf('local://%s', basename($zipPath)),
                sprintf('sftp://ARCHIVE/%s', basename($zipPath)),
            );
        } catch (FilesystemException $e) {
            $this->logger->info($e->getMessage());
            throw new \RuntimeException($e->getMessage());
        }
    }

    private function transferPackedFolder($command): void
    {
        $config = $this->configReader->getConfig();

        $packagePath = $this->pathProvider->getPackageRootPath($command->packageName);

        // check package folder exists
        $fs = new SymfonyFilesystem();
        if (!$fs->exists($packagePath)) {
            throw new \InvalidArgumentException(sprintf('No package exists with name `%s`, cannot transfer', $packagePath));
        }

        if (!$config->sftpIp || !$config->sftpPass || !$config->sftpUser || !$config->sftpPort) {
            throw new \RuntimeException('Cannot transfer to SFTP as sftp config variables are missing. Make sure you set ip,pass,user,port in config.yml');
        }

        $local = new LocalFilesystemAdapter($packagePath);

        $connectionProvider = new SftpConnectionProvider(
            $config->sftpIp,
            $config->sftpUser,
            $config->sftpPass,
            null,
            null,
            (int) $config->sftpPort,
            false,
            8,
            1,
        );

        $sftpAdapter = new SftpAdapter(
            $connectionProvider,
            self::REMOTE_CARD_PATH
        );

        $filesystemSftp = new Filesystem($sftpAdapter);
        $filesystemLocal = new Filesystem($local);

        $mountManager = new MountManager([
            'local' => $filesystemLocal,
            'sftp' => $filesystemSftp,
        ]);

        try {
            $localContents = $mountManager->listContents('local://', true);

            foreach ($localContents as $fileNode) {
                $localPath = $fileNode->path();
                $sftpPath = preg_replace('{^local://}', 'sftp://', $fileNode->path());
                if (!$sftpPath) {
                    throw new \RuntimeException();
                }

                if ('dir' == $fileNode['type']) {
                    $mountManager->createDirectory($sftpPath);
                    continue;
                }

                $mountManager->copy(
                    $localPath,
                    $sftpPath,
                );
            }
        } catch (FilesystemException $e) {
            $this->logger->info($e->getMessage());
            throw new \RuntimeException($e->getMessage());
        }
    }
}
