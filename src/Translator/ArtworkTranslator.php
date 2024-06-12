<?php

namespace App\Translator;

use App\FolderNames;
use App\Model\Artwork;
use App\Util\Path;
use Symfony\Bridge\Twig\Extension\TranslationExtension;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Translation\DataCollectorTranslator;
use Symfony\Component\Translation\Loader\ArrayLoader;
use Symfony\Component\Yaml\Yaml;
use Symfony\Contracts\Translation\TranslatorInterface;
use Twig\Environment as TwigEnvironment;
use Twig\Loader\ArrayLoader as TwigArrayLoader;

class ArtworkTranslator
{
    private array $runtimeTokenMemoization = [];

    public function __construct(
        readonly private TranslatorInterface $translator,
        readonly private Path $path
    ) {
        if (!$this->translator instanceof DataCollectorTranslator) {
            throw new \RuntimeException(get_class($this->translator));
        }

        // setup and load translations
        $finder = new Finder();

        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value));
        $finder->files()->path("#[^\/]+\/tokens\/#")->name('*.yml');

        $this->translator->setFallbackLocales(['default']);
        $this->translator->addLoader('array', new ArrayLoader());

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
    }

    public function addRuntimeTranslationTokens(array $tokens): void
    {
        // ensure identical tokens only added once

        $hash = hash('xxh3', serialize($tokens));
        if (isset($this->runtimeTokenMemoization[$hash])) {
            return;
        }

        $this->translator->addResource(
            'array',
            $tokens,
            'default',
            // use 'general' as the domain (?)
            'general'
        );

        $this->runtimeTokenMemoization[$hash] = true;
    }

    public function translateArtwork(Artwork $artwork, string $locale): string
    {
        $artworkBasepath = $this->path->joinWithBase(FolderNames::TEMPLATE->value, 'artwork');

        $t = ['template' => $artwork->read()];
        $twig = new TwigEnvironment(
            new TwigArrayLoader($t)
        );
        $twig->addExtension(new TranslationExtension($this->translator));

        return $twig->render(
            'template',
            ['locale' => $locale]
        );
    }
}
