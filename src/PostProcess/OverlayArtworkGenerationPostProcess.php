<?php

namespace App\PostProcess;

use App\Command\CommandNamespace;
use App\Command\Factory\CommandFactory;
use App\Command\Handler\GenerateArtworkHandler;
use App\Command\PostProcessCommand;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Util\Finder;
use App\Util\Path;
use App\Util\TokenUtility;
use Intervention\Image\ImageManager;
use Monolog\Attribute\WithMonologChannel;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;

/**
 * Allows you to run another skyscraper artwork generation,
 * handy to overlay wheels and logos etc after other post processing.
 */
#[WithMonologChannel('postprocessing')]
class OverlayArtworkGenerationPostProcess implements PostProcessInterface
{
    use ArtworkTrait;

    public const NAME = 'artwork-generation';

    public function __construct(
        readonly private Path $path,
        readonly private CommandFactory $commandFactory,
        readonly private GenerateArtworkHandler $generateArtworkHandler,
        readonly private LoggerInterface $logger,
        readonly private ConfigReader $configReader
    ) {
    }

    public function getName(): string
    {
        return self::NAME;
    }

    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    public function process(PostProcessCommand $command): void
    {
        $options = $this->processOptions($command->options);
        $workset = $this->getArtwork($command->target);

        $this->logger->info(
            sprintf(
                'Running post processor `artwork-generation` with command %s and options `%s`',
                json_encode($command),
                json_encode($options)
            )
        );

        $split = TokenUtility::splitStringIntoArtworkPackageAndFileName($options['artwork']);

        $namespace = CommandNamespace::from($options['namespace']);

        $commands = [];

        if (!$command->platforms) {
            // for folders
            $commands = $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
                $namespace,
                $split['artworkPackage'],
                $split['filename'],
                ('' !== $options['token']) ? TokenUtility::parseRuntimeTokens($options['token']) : [],
                false,
                CommandNamespace::ARTWORK === $namespace // hardcoded - will be slow and sometimes not needed?
            );
        }

        if ($command->platforms) {
            // for artwork
            $commands = $this->commandFactory->createGenerateArtworkCommandsForPlatforms(
                $namespace,
                $split['artworkPackage'],
                $split['filename'],
                ('' !== $options['token']) ? TokenUtility::parseRuntimeTokens($options['token']) : [],
                false,
                CommandNamespace::ARTWORK === $namespace, // hardcoded - will be slow and sometimes not needed?
                $command->platforms
            );
        }

        // hack to wipe the output folder every time to ensure no clashes with earlier generations
        $filesystem = new Filesystem();
        $outputFolder = $this->path->joinWithBase(FolderNames::TEMP->value, 'output');
        $tempArtworkPath = $this->path->joinWithBase(FolderNames::TEMP->value, 'artwork_tmp');

        if ($filesystem->exists($outputFolder)) {
            $filesystem->remove($outputFolder);
        }

        if ($filesystem->exists($tempArtworkPath)) {
            $filesystem->remove($tempArtworkPath);
        }

        foreach ($commands as $cmd) {
            $this->generateArtworkHandler->handle($cmd);
        }

        $this->processWorkset($workset, $command->target, $options);
    }

    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    public function processOptions(array $options): array
    {
        return OverlayArtworkGenerationPostProcessOptions::mergeDefaults($options);
    }

    private function processWorkset(array $files, string $target, array $options)
    {
        $generatedFolder = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'output',
            $options['namespace'],
            'generated_artwork'
        );

        foreach ($files as $originalFilePath) {
            $originalFilename = basename($originalFilePath);

            $manager = ImageManager::imagick();
            $canvasX = 640;
            $canvasY = 480;
            $canvas = $manager->create($canvasX, $canvasY);

            $canvas->place($originalFilePath);

            $finder = new Finder();
            $finder->in($generatedFolder);
            $pattern = '#/covers/#';

            $finder->files()->path($pattern);

            if ($options['namespace'] !== CommandNamespace::FOLDER->value) {
                $finder->name($originalFilename);
            }

            // folder filenames needs to be reverse mapped due to package related hack in the artworkgenerator
            if ($options['namespace'] === CommandNamespace::FOLDER->value) {
                foreach ($this->getPlatformsByPackagedFolderName(Path::removeExtension($originalFilename)) as $p) {
                    $finder->name($p.'.png');
                }
            }

            if (1 !== count($finder)) {
                $this->logger->warning(
                    sprintf('%s matching images found when postprocessing with artwork, possible incorrect image inserted: %s', count($finder), $originalFilename)
                );
            }

            if (!$finder->hasResults()) {
                $this->logger->warning(
                    sprintf('No image found matching original filename %s, probable issue when generating artwork in post process', $originalFilename)
                );
            }

            $file = $finder->first();
            $generatedImagePath = $file->getRealPath();

            // insert the generated image on top
            $generatedImage = $manager->read($generatedImagePath);
            $canvas->place($generatedImage);

            // save to original location
            $canvas->save($originalFilePath);
        }
    }

    private function getPlatformsByPackagedFolderName(string $filename): array
    {
        $package = $this->configReader->getConfig()->package;
        $keys = array_keys($package, $filename);
        if (0 === count($keys)) {
            throw new \RuntimeException(sprintf('Cannot reverse map to platform for packed name `%s`', $filename));
        }

        return $keys;
    }
}
