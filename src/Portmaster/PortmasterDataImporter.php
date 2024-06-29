<?php

namespace App\Portmaster;

use App\ApplicationConstant;
use App\Builder\SkyscraperCommandDirector;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Generator\ManualImportXMLGenerator;
use App\Importer\SkyscraperManualDataImporter;
use App\Provider\PathProvider;
use App\Util\DateTimeFile;
use App\Util\Path;
use Intervention\Image\ImageManager;
use Intervention\Image\Typography\FontFactory;
use Monolog\Attribute\WithMonologChannel;
use PhpZip\Exception\ZipException;
use PhpZip\ZipFile;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Process\Process;
use Symfony\Contracts\HttpClient\Exception\ClientExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\DecodingExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\RedirectionExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\ServerExceptionInterface;
use Symfony\Contracts\HttpClient\Exception\TransportExceptionInterface;
use Symfony\Contracts\HttpClient\HttpClientInterface;

/**
 * Download screenshots and metadata from portmaster git repo and import into skyscraper cache.
 */
#[WithMonologChannel('skyscraper')]
class PortmasterDataImporter
{
    private ?array $metadata = null;

    public function __construct(
        readonly private HttpClientInterface $client,
        readonly private ConfigReader $configReader,
        readonly private Path $path,
        readonly private PathProvider $pathProvider,
        readonly private ManualImportXMLGenerator $manualImportXMLGenerator,
        readonly private SkyscraperManualDataImporter $skyscraperManualDataImporter,
        readonly private SkyscraperCommandDirector $skyscraperCommandDirector,
        readonly private LoggerInterface $logger
    ) {
    }

    /**
     * @throws RedirectionExceptionInterface
     * @throws DecodingExceptionInterface
     * @throws ClientExceptionInterface
     * @throws TransportExceptionInterface
     * @throws \Throwable
     * @throws ZipException
     * @throws ServerExceptionInterface
     */
    public function importPortmasterDataIfNotImportedSince(\DateInterval $dateInterval): void
    {
        $folder = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster/');
        $lastAttempted = DateTimeFile::readDatetimeValueFromFile($folder, 'LASTIMPORTATTEMPTED');
        $compare = new \DateTime();
        $compare->sub($dateInterval);
        $outofDate = !$lastAttempted || $lastAttempted < $compare;

        if ($outofDate || $this->hasConfigHashChanged()) {
            try {
                $this->importPortmasterData();
                DateTimeFile::writeDatetimeValueToFile($folder, 'LASTIMPORTATTEMPTED');
                $this->writeConfigHash();
            } catch (\Throwable $t) {
                throw $t;
            }
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
            $this->downloadPortsMetadataFile();
        }

        // get meta
        $meta = $this->getMetaData();

        // then create and import 'fake' resources
        $this->makeFakeRoms($meta);

        $this->writeTextualDataToImportLocation($meta);
        $this->copyImagesToImportLocation($meta);
        $this->import();
    }

    public function scrapeUsingAlternatesList(): void
    {
        // read file
        $alternates = $this->configReader->getConfig()->portmasterAlternates;
        $romList = $this->configReader->getConfig()->portmaster;

        foreach ($alternates as $game => $data) {
            if (!empty($romList) && !in_array($game, $romList)) {
                // skips roms not explicitly set in config
                continue;
            }

            $queryString = '';
            if (isset($data['romnom'])) {
                $queryString = 'romnom='.$data['romnom'];
            }
            if (isset($data['crc'])) {
                $queryString = 'crc='.$data['crc'];
            }
            if ('' === $queryString || !isset($data['platform'])) {
                continue;
            }

            $command = $this->skyscraperCommandDirector->getScrapeCommandForSingleRomWithQuery(
                $data['platform'],
                sprintf('%s.zip', $game),
                $queryString,
                true
            );

            $process = new Process($command);
            $process->setTimeout(120);

            try {
                $process->run();

                $output = $process->getOutput();
                $this->logger->info($output);
                if (!$process->isSuccessful()) {
                    $this->logger->error('Importing alternate data for portmaster failed');
                }
            } catch (\Exception $e) {
                $this->logger->error($e->getMessage());
                throw new \RuntimeException('Importing alternate data for portmaster failed');
            }
        }
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

    private function makeFakeRoms(array $metadata): void
    {
        $fakeRomPath = $this->pathProvider->getPortmasterRomPath();

        $filesystem = new Filesystem();

        if ($filesystem->exists($fakeRomPath)) {
            $filesystem->remove($fakeRomPath);
        }

        foreach ($metadata as $scriptName => $attr) {
            $filesystem->appendToFile(Path::join($fakeRomPath, $attr['zipName']), 'fake');
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

        foreach ($metadata as $attr) {
            $path = Path::join($tmpFolder, $attr['name'].'.xml');
            $this->manualImportXMLGenerator->generateXML($path, $attr['title'], $attr['description'], $attr['genre']);
        }
    }

    private function copyImagesToImportLocation(array $metadata): void
    {
        $tmpFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'portmaster',
            'import',
            ApplicationConstant::FAKE_PORTMASTER_PLATFORM,
            'screenshots/'
        );
        $filesystem = new Filesystem();

        foreach ($metadata as $attr) {
            $this->createWheelForPortmaster($attr['title'], $attr['name']);

            foreach (['jpg', 'png'] as $extension) {
                $screenshotInPath = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'images', $attr['name'].'.screenshot.'.$extension);
                $screenshotOutPath = Path::join($tmpFolder, $attr['name'].'.'.$extension);
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

    private function createWheelForPortmaster(string $title, string $name): void
    {
        $filesystem = new Filesystem();
        $tmpFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'portmaster',
            'import',
            ApplicationConstant::FAKE_PORTMASTER_PLATFORM,
            'wheels/'
        );
        if (!$filesystem->exists($tmpFolder)) {
            $filesystem->mkDir($tmpFolder);
        }

        $manager = ImageManager::imagick();
        $canvas = $manager->create(300, 300);
        $fontPath = $this->pathProvider->getRandomFontPath();

        $canvas->text($title, 150, 50, function (FontFactory $font) use ($fontPath) {
            $font->filename($fontPath);
            $font->size(28);
            $font->color('white');
            $font->stroke('black', 2);
            $font->align('center');
            $font->valign('middle');
            $font->lineHeight(1.9);
            $font->wrap(280);
        });

        // save wheel
        $canvas->save(Path::join($tmpFolder, $name.'.png'));
    }

    /**
     * @throws TransportExceptionInterface
     * @throws ServerExceptionInterface
     * @throws RedirectionExceptionInterface
     * @throws ClientExceptionInterface
     */
    private function downloadPortsMetadataFile(): void
    {
        $filesystem = new Filesystem();
        $portDataUrl = 'https://raw.githubusercontent.com/PortsMaster/PortMaster-Info/master/ports.json';

        try {
            $response = $this->client->request(
                'GET',
                $portDataUrl
            );
        } catch (ClientExceptionInterface $exception) {
            $this->logger->critical($exception->getMessage());
            throw new \RuntimeException('There was a problem downloading information from portmaster github, you might want to run this command again later or check log output to see what the issue was. You can continue generate without portmaster data and add it later on.');
        }

        $metaFilePath = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'ports.json');

        $filesystem->dumpFile($metaFilePath, $response->getContent());
    }

    public function getMetaData(): array
    {
        if ($this->metadata) {
            return $this->metadata;
        }

        $filesystem = new Filesystem();
        $supportedSystems = ['rg35xx-plus:ALL', 'rg35xx-h:ALL'];

        // read ports data
        $metaFilePath = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'ports.json');

        if (!$filesystem->exists($metaFilePath)) {
            try {
                $this->downloadPortsMetadataFile();
            } catch (\Throwable $e) {
                $this->logger->critical('Could not download ports metadata file');
                $this->logger->debug($e->getMessage());
                // @todo throw an exception that will skip this step but not fail the whole process
            }
        }

        $metadataJson = json_decode($filesystem->readFile($metaFilePath), true);

        // just store the stuff we care about
        $metaProcessed = [];
        $romList = $this->configReader->getConfig()->portmaster;

        foreach ($metadataJson['ports'] as $portZipName => $attrWrapper) {
            $portData = $attrWrapper['attr'];
            $portName = basename($portZipName, '.zip');

            if (!empty($romList) && !in_array($portName, $romList)) {
                // skips roms not explicitly set in config
                continue;
            }

            // if not supported then skip
            if (array_key_exists('avail', $portData)) {
                $supported = array_intersect($portData['avail'], $supportedSystems);
                if (0 === count($supported)) {
                    continue;
                }
            }
            $scriptName = 'unknown.sh';
            if (array_key_exists('items', $attrWrapper)) {
                foreach ($attrWrapper['items'] as $item) {
                    if ('sh' === pathinfo($item, PATHINFO_EXTENSION)) {
                        $scriptName = $item;
                    }
                }
            }

            // keyed this way because this is what the port folder is ultimately called and it's used as a lookup
            // $scriptKey = basename($scriptName, 'sh');

            $metaProcessed[$portName]['title'] = $portData['title'] ?? $portName;
            $metaProcessed[$portName]['zipName'] = $portZipName;
            $metaProcessed[$portName]['name'] = $portName;
            $metaProcessed[$portName]['description'] = $portData['desc'] ?? $portName;
            $metaProcessed[$portName]['genre'] = isset($portData['genres']) ? reset($portData['genres']) : $portName;
            $metaProcessed[$portName]['script'] = $scriptName;
        }

        $this->metadata = $metaProcessed;

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

        try {
            $response = $this->client->request(
                'GET',
                $apiUrl
            );
        } catch (ClientExceptionInterface $exception) {
            $this->logger->critical($exception->getMessage());
            throw new \RuntimeException('There was a problem downloading information from portmaster github, you might want to run this command again later or check log output to see what the issue was. You can continue generate without portmaster data and add it later on.');
        }

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

    private function hasConfigHashChanged(): bool
    {
        $filesystem = new Filesystem();
        $configHash = $this->configReader->getConfigHash();
        $lastConfigHashPath = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'CONFIGHASH');

        if ($filesystem->exists($lastConfigHashPath)) {
            $lastConfigHash = $filesystem->readFile($lastConfigHashPath);
            if ($lastConfigHash === $configHash) {
                return false;
            }
        }

        return true;
    }

    private function writeConfigHash(): void
    {
        $filesystem = new Filesystem();
        $lastConfigHashPath = $this->path->joinWithBase(FolderNames::TEMP->value, 'portmaster', 'CONFIGHASH');

        if ($filesystem->exists($lastConfigHashPath)) {
            $filesystem->remove($lastConfigHashPath);
        }

        $filesystem->appendToFile($lastConfigHashPath, $this->configReader->getConfigHash());
    }
}
