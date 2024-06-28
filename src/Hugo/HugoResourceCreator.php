<?php

namespace App\Hugo;

use App\Config\Processor\TemplateMakeFileProcessor;
use App\FolderNames;
use App\Util\Path;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

class HugoResourceCreator
{
    public function __construct(
        readonly private Path $path,
        readonly private TemplateMakeFileProcessor $templateMakeFileProcessor
    ) {
    }

    public function copyTemplatePreviewsToStatic(): void
    {
        $filesystem = new Filesystem();
        $finder = new Finder();
        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value, '*', 'preview'));
        $finder->files()->name('*.png')->name('*.webp');

        $out = $this->path->joinWithBase('static', 'template', 'preview');

        foreach ($finder as $file) {
            $filesystem->copy(
                $file->getRealPath(),
                Path::join($out, $file->getFilename()),
            );
        }
    }

    public function createHugoDataFixtureForTemplates(): void
    {
        $filesystem = new Filesystem();
        $finder = new Finder();
        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value, '*'));
        $finder->files()->name('make.yml');

        $out = $this->path->joinWithBase('docs-data', 'templates.json');

        $entries = [];

        foreach ($finder as $file) {
            $templateName = basename($file->getPath());
            $make = $this->templateMakeFileProcessor->process($templateName);
            foreach ($make as $variantName => $variantData) {
                $entries[] = $this->createHugoTemplateDataFixtureEntry($templateName, $variantName, $variantData);
            }
        }

        $filesystem->dumpFile($out, json_encode($entries, JSON_PRETTY_PRINT) ?: '{}');
    }

    private function createHugoTemplateDataFixtureEntry(
        string $templateName,
        string $variantName,
        array $variant
    ): HugoTemplateDataFixtureEntry {
        $previewName = $variant['package_name'].'-no-theme.webp';
        $previewPath = sprintf('/template/preview/%s', $previewName);

        return new HugoTemplateDataFixtureEntry(
            $templateName,
            $variantName,
            $previewPath,
            $variant['metadata']['type'],
            $variant['metadata']['height'],
            array_key_exists('portmaster', $variant),
            array_key_exists('folder', $variant),
        );
    }
}
