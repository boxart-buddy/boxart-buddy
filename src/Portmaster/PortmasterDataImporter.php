<?php

namespace App\Portmaster;

use App\ApplicationConstant;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Generator\ManualImportXMLGenerator;
use App\Importer\SkyscraperManualDataImporter;
use App\Provider\PathProvider;
use App\Util\DateTimeFile;
use App\Util\Path;
use PhpZip\Exception\ZipException;
use PhpZip\ZipFile;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Contracts\HttpClient\Exception\ClientExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\DecodingExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\RedirectionExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\ServerExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\TransportExceptionInterface;
use Symfony\Contracts\HttpClient\HttpClientInterface;

/**
 * Download screenshots and metadata from portmaster git repo and import into skyscraper cache.
 */
readonly class PortmasterDataImporter
{
    public function __construct(
        private HttpClientInterface $client,
        private ConfigReader $configReader,
        private Path $path,
        private PathProvider $pathProvider,
        private ManualImportXMLGenerator $manualImportXMLGenerator,
        private SkyscraperManualDataImporter $skyscraperManualDataImporter
    ) {
    }

    public function importPortmasterDataIfNotImportedSince(\DateInterval $dateInterval): void
    {
        $folder = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster/');
        $lastAttempted = DateTimeFile::readDatetimeValueFromFile($folder, 'LASTIMPORTATTEMPTED');
        $compare = new \DateTime();
        $compare->sub($dateInterval);

        if (!$lastAttempted || $lastAttempted < $compare) {
            $this->importPortmasterData();
            DateTimeFile::writeDatetimeValueToFile($folder, 'LASTIMPORTATTEMPTED');
        }
    }

    /**
     * @throws RedirectionExceptionInterface
     * @throws DecodingExceptionInterface
     * @throws ClientExceptionInterface
     * @throws TransportExceptionInterface
     * @throws ZipException
     * @throws ServerExceptionInterface
     */
    public function importPortmasterData(): void
    {
        // Download and unzip latest images if needed
        $lastDownloadedVersion = $this->getLastDownloadedVersionDateTime();
        $latestPublished = $this->getLatestReleasePublishedDateTime();
        if (null === $lastDownloadedVersion || null === $latestPublished || ($latestPublished > $lastDownloadedVersion)) {
            $this->downloadAndUnzipLatestImages($latestPublished);
        }

        // get meta
        $meta = $this->getMetaData();

        // then create and import 'fake' resources
        $fakeRomPath = $this->pathProvider->getPortmasterRomPath();
        $this->makeFakeRoms($meta, $fakeRomPath);
        $this->writeTextualDataToImportLocation($meta);
        $this->copyScreenshotsToImportLocation($meta);
        $this->import();
    }

    private function import(): void
    {
        $importIn = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'portmaster',
            'import',
            ApplicationConstant::FAKE_PORTMASTER_PLATFORM
        );

        $this->skyscraperManualDataImporter->importResources($importIn, ApplicationConstant::FAKE_PORTMASTER_PLATFORM);
    }

    private function makeFakeRoms(array $metadata, string $fakeRomPath): void
    {
        $filesystem = new Filesystem();

        foreach ($metadata as $name => $attr) {
            $filesystem->appendToFile(Path::join($fakeRomPath, $name.'.zip'), 'fake');
        }
    }

    private function writeTextualDataToImportLocation(array $metadata): void
    {
        $tmpFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'portmaster',
            'import',
            ApplicationConstant::FAKE_PORTMASTER_PLATFORM,
            'textual/'
        );

        foreach ($metadata as $name => $attr) {
            $path = Path::join($tmpFolder, $name.'.xml');
            $this->manualImportXMLGenerator->generateXML($path, $attr['title'], $attr['description'], $attr['genre']);
        }
    }

    private function copyScreenshotsToImportLocation(array $metadata): void
    {
        $tmpFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'portmaster',
            'import',
            ApplicationConstant::FAKE_PORTMASTER_PLATFORM,
            'screenshots/'
        );
        $filesystem = new Filesystem();

        foreach ($metadata as $name => $attr) {
            foreach (['jpg', 'png'] as $extension) {
                $screenshotInPath = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'images', $name.'.screenshot.'.$extension);
                $screenshotOutPath = Path::join($tmpFolder, $name.'.'.$extension);
                if (!$filesystem->exists($screenshotInPath)) {
                    continue;
                }
                $filesystem->copy(
                    $screenshotInPath,
                    $screenshotOutPath
                );
            }
        }
    }

    /**
     * @throws TransportExceptionInterface
     * @throws ServerExceptionInterface
     * @throws RedirectionExceptionInterface
     * @throws DecodingExceptionInterface
     * @throws ClientExceptionInterface
     */
    private function getMetaData(): array
    {
        $supportedSystems = ['rg35xx-plus:ALL', 'rg35xx-h:ALL'];

        $portDataUrl = 'https://raw.githubusercontent.com/PortsMaster/PortMaster-Info/master/ports.json';

        $response = $this->client->request(
            'GET',
            $portDataUrl
        );

        $responseArray = $response->toArray();

        // just store the stuff we care about
        $metaProcessed = [];

        foreach ($responseArray['ports'] as $portZipName => $attrWrapper) {
            $portData = $attrWrapper['attr'];

            // if not supported then skip
            if (array_key_exists('avail', $portData)) {
                $supported = array_intersect($portData['avail'], $supportedSystems);
                if (0 === count($supported)) {
                    continue;
                }
            }

            $portName = basename($portZipName, '.zip');
            $metaProcessed[$portName]['title'] = $portData['title'] ?? $portName;
            $metaProcessed[$portName]['description'] = $portData['desc'] ?? $portName;
            $metaProcessed[$portName]['genre'] = isset($portData['genres']) ? reset($portData['genres']) : $portName;
        }

        return $metaProcessed;
    }

    /**
     * @throws TransportExceptionInterface
     * @throws ZipException
     */
    private function downloadAndUnzipLatestImages(?\DateTimeImmutable $latestPublished): void
    {
        $remoteUrl = 'https://github.com/PortsMaster/PortMaster-New/releases/latest/download/images.zip';

        $response = $this->client->request(
            'GET',
            $remoteUrl
        );

        $tmpFolder = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster/');

        $filesystem = new Filesystem();
        if (!$filesystem->exists($tmpFolder)) {
            $filesystem->mkDir($tmpFolder);
        }

        $imageZipPath = Path::join($tmpFolder, 'images.zip');
        if ($filesystem->exists($imageZipPath)) {
            $filesystem->remove($imageZipPath);
        }

        $fileHandler = fopen($imageZipPath, 'w');
        if (!$fileHandler) {
            throw new \RuntimeException();
        }

        foreach ($this->client->stream($response) as $chunk) {
            fwrite($fileHandler, $chunk->getContent());
        }

        // unzip
        $imageFolderPath = Path::join($tmpFolder, 'images/');
        if ($filesystem->exists($imageFolderPath)) {
            $filesystem->remove($imageFolderPath);
        }
        $filesystem->mkDir($imageFolderPath);

        $zip = new ZipFile();
        $zip->openFile($imageZipPath)->extractTo($imageFolderPath);

        // write version file
        DateTimeFile::writeDatetimeValueToFile($tmpFolder, 'LASTPUBLISHED', $latestPublished);

        // delete the zip
        $filesystem->remove($imageZipPath);
    }

    /**
     * @throws TransportExceptionInterface
     * @throws ServerExceptionInterface
     * @throws RedirectionExceptionInterface
     * @throws DecodingExceptionInterface
     * @throws ClientExceptionInterface
     */
    private function getLatestReleasePublishedDateTime(): ?\DateTimeImmutable
    {
        $apiUrl = 'https://api.github.com/repos/PortsMaster/PortMaster-New/releases/latest';

        $response = $this->client->request(
            'GET',
            $apiUrl
        );

        $data = $response->toArray();

        return \DateTimeImmutable::createFromFormat(
            \DateTimeInterface::ATOM,
            $data['published_at']
        ) ?: null;
    }

    private function getLastDownloadedVersionDateTime(): ?\DateTimeImmutable
    {
        $tmpFolder = $this->path->joinWithBase(FolderNames::TEMP->value, '/portmaster');

        return DateTimeFile::readDatetimeValueFromFile($tmpFolder, 'LASTPUBLISHED');
    }
}
