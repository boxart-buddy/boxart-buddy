<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;
use App\FolderNames;
use App\Provider\PathProvider;
use App\Translator\Fuzzy\FuzzyMatchingMessageCatalogue;
use App\Util\Path;
use Intervention\Image\ImageManager;
use Intervention\Image\Interfaces\ImageInterface;
use Intervention\Image\Typography\FontFactory;
use Monolog\Attribute\WithMonologChannel;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Yaml\Yaml;

#[WithMonologChannel('postprocessing')]
class AddTextPostProcess implements PostProcessInterface
{
    use ArtworkTrait;
    use SaveImageTrait;

    public const NAME = 'add-text';

    public function __construct(
        readonly private Path $path,
        readonly private PathProvider $pathProvider,
        readonly private LoggerInterface $logger
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
        $this->processWorkset($workset, $command->target, $options, $command->platforms);
    }

    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    public function processOptions(array $options): array
    {
        return AddTextPostProcessOptions::mergeDefaults($options);
    }

    private function processWorkset(array $files, string $target, array $options, ?array $platforms): void
    {
        if (null === $platforms) {
            $this->logger->warning('$platforms should never be null in this context, cannot add text during post processing');

            return;
        }

        $filesystem = new Filesystem();

        // read text in
        $mappingFilePath = $this->path->joinWithBase(
            FolderNames::TEMP->value,
            'post-process',
            'resources',
            $options['mapping']
        );

        $mapping = Yaml::parseFile($mappingFilePath);

        // only care about platforms we care about
        $messages = [];
        foreach ($mapping as $p => $t) {
            if (in_array($p, $platforms)) {
                $messages = array_merge($messages, $t);
            }
        }

        $addedAtLeastOneText = false;

        foreach ($files as $originalFilePath) {
            $originalFilename = basename($originalFilePath);

            $textToInsert = null;
            if (isset($mapping)) {
                $textToInsert = FuzzyMatchingMessageCatalogue::getFuzzyMatch(
                    Path::removeExtension($originalFilename),
                    $messages
                );
            }

            if (!$textToInsert) {
                continue;
            }

            $manager = ImageManager::imagick();
            $canvasX = 640;
            $canvasY = 480;
            $canvas = $manager->create($canvasX, $canvasY);

            // insert the image on top
            $originalImage = $manager->read($originalFilePath);
            $canvas->place($originalImage);

            $yOffset = match ($options[AddTextPostProcessOptions::POSITION_Y]) {
                'center' => 0,
                'bottom' => 110,
                default => 240
            };

            $text = $this->getTextImage($textToInsert, $options);
            $textBgOpacity = (int) $options[AddTextPostProcessOptions::TEXT_BG_OPACITY];
            $canvas->place($text, 'center', 0, $yOffset, $textBgOpacity);

            // save to temp location
            $canvas->save($this->getSavePath($originalFilename));
            $addedAtLeastOneText = true;
        }

        if ($addedAtLeastOneText) {
            $this->mirrorTemporaryFolderIfRequired($target);
        }
    }

    private function getTextImage(string $textToAdd, array $options): ImageInterface
    {
        $textColor = $options[AddTextPostProcessOptions::TEXT_COLOR];
        $textBgColor = $options[AddTextPostProcessOptions::TEXT_BG_COLOR];
        $fontFamily = $options[AddTextPostProcessOptions::TEXT_FONT_FAMILY];
        $fontVariant = $options[AddTextPostProcessOptions::TEXT_FONT_VARIANT];

        $manager = ImageManager::imagick();
        $canvasX = 320;
        $canvasY = 80;
        $text = $manager->create($canvasX, $canvasY)->fill($textBgColor);

        $fontPath = $this->pathProvider->getFontPath($fontFamily, $fontVariant);

        $text->text($textToAdd, 160, 40, function (FontFactory $font) use ($fontPath, $textColor) {
            $font->filename($fontPath);
            $font->size(22);
            $font->color($textColor);
            $font->align('center');
            $font->valign('middle');
            $font->lineHeight(1.9);
            $font->wrap(320);
        });

        $textNative = $text->core()->native();

        $textNative->trimImage(10);
        $textNative->setImagePage(0, 0, 0, 0);

        $bgWidth = $textNative->getImageWidth() + 30;
        $bgHeight = $textNative->getImageHeight() + 10;

        $bg = $manager->create($bgWidth, $bgHeight)->fill($textBgColor);

        $bg->place($textNative, 'center');

        return $bg;
    }
}
