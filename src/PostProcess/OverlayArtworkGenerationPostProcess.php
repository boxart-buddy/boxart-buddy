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
    use SaveImageTrait;

    public const NAME = 'artwork_generation';

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
        $this->setupSaveBehaviour(false);

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

        if (CommandNamespace::FOLDER === $namespace) {
            // for folders
            $commands = $this->commandFactory->createGenerateArtworkCommandsForAllPlatforms(
                $namespace,
                $split['artworkPackage'],
                $split['filename'],
                ('' !== $options['token']) ? TokenUtility::parseRuntimeTokens($options['token']) : [],
                false,
                false
            );
        }

        if (CommandNamespace::ARTWORK === $namespace) {
            // for artwork
            $commands = $this->commandFactory->createGenerateArtworkCommandsForPlatforms(
                $namespace,
                $split['artworkPackage'],
                $split['filename'],
                ('' !== $options['token']) ? TokenUtility::parseRuntimeTokens($options['token']) : [],
                false,
                true, // hardcoded - will be slow and sometimes not needed?
                $command->platforms ?? [] // should probably throw an exception if platforms null
            );
        }

        if (CommandNamespace::PORTMASTER === $namespace) {
            // for portmaster
            $commands = $this->commandFactory->createGenerateArtworkCommandForPortmaster(
                $split['artworkPackage'],
                $split['filename'],
                ('' !== $options['token']) ? TokenUtility::parseRuntimeTokens($options['token']) : []
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

    private function processWorkset(array $files, string $target, array $options): void
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

            $finder = new Finder();
            $finder->in($generatedFolder);
            $pattern = '#/covers/#';

            $finder->files()->path($pattern);

            if ($options['namespace'] === CommandNamespace::ARTWORK->value) {
                $finder->name($originalFilename);
            }

            if ($options['namespace'] === CommandNamespace::PORTMASTER->value) {
                $finder->name($originalFilename);
            }

            // folder filenames needs to be reverse mapped due to package related hack in the artworkgenerator
            if ($options['namespace'] === CommandNamespace::FOLDER->value) {
                foreach ($this->configReader->getConfig()->getPlatformsByRomFolder(Path::removeExtension($originalFilename)) as $p => $rf) {
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

                return;
            }

            $file = $finder->first();
            $generatedImagePath = $file->getRealPath();

            $layer = $options[OverlayArtworkGenerationPostProcessOptions::LAYER];

            if ('bottom' === $layer) {
                $generatedImage = $manager->read($generatedImagePath);
                $canvas->place($generatedImage);
            }

            $canvas->place($originalFilePath);

            if ('top' === $layer) {
                $generatedImage = $manager->read($generatedImagePath);
                $canvas->place($generatedImage);
            }

            // save to original location
            $canvas->save($this->getSavePath($originalFilePath));
        }

        $this->mirrorTemporaryFolderIfRequired($target);
    }
}
