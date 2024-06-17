<?php

namespace App\Translator;

use App\Model\Artwork;
use App\Util\Path;
use Psr\Log\LoggerInterface;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Translation\Loader\ArrayLoader;
use Symfony\Component\Translation\Translator;
use Symfony\Component\Yaml\Yaml;
use Twig\Environment as TwigEnvironment;
use Twig\Loader\ArrayLoader as TwigArrayLoader;

class ArtworkTranslator
{
    private array $runtimeTokenMemoization = [];
    private array $translationAddedForArtwork = [];
    private Translator $translator;

    public function __construct(
        readonly private LoggerInterface $logger
    ) {
        $this->translator = new Translator('default');
        $this->translator->setFallbackLocales(['default']);
        $this->translator->addLoader('array', new ArrayLoader());
    }

    private function loadTranslations(Artwork $artwork): void
    {
        // only loads for a given artwork one time
        if (isset($this->translationAddedForArtwork[$artwork->absoluteFilepath])) {
            return;
        }

        // sketchy - relies on artwork template structure
        $tokenPath = dirname($artwork->absoluteFilepath, 2);
        // setup and load translations
        $finder = new Finder();

        $finder->in(Path::join($tokenPath, 'tokens'));
        $finder->files()->name('*.yml');

        foreach ($finder as $file) {
            $translationData = Yaml::parseFile($file->getRealPath());
            // assume yml file is keyed by platform
            foreach ($translationData as $platformName => $translations) {
                $this->translator->addResource(
                    'array',
                    $translations,
                    $platformName,
                    // use the filename as the domain name
                    $file->getFilenameWithoutExtension()
                );
            }
        }

        $this->translationAddedForArtwork[$artwork->absoluteFilepath] = true;
    }

    public function addRuntimeTranslationTokens(array $tokens): void
    {
        // ensure identical tokens only added once
        $hash = hash('xxh3', serialize($tokens));
        if (isset($this->runtimeTokenMemoization[$hash])) {
            return;
        }

        $this->logger->debug('Adding runtime translations to general catalogue');
        $this->logger->debug(json_encode($tokens));

        $this->translator->addResource(
            'array',
            $tokens,
            'default',
            // use 'general' as the domain (?)
            'general'
        );

        $this->runtimeTokenMemoization[$hash] = true;
    }

    public function translateArtwork(Artwork $artwork, string $locale, ?string $romName): string
    {
        $this->loadTranslations($artwork);

        $t = ['template' => $artwork->read()];

        $twig = new TwigEnvironment(
            new TwigArrayLoader($t)
        );
        $twig->addExtension(new EmptyTranslatingTwigExtension($this->translator));

        $vars = ['locale' => $locale];
        if ($romName) {
            $vars['rom'] = $romName;
        }

        return $twig->render(
            'template',
            $vars
        );
    }
}
