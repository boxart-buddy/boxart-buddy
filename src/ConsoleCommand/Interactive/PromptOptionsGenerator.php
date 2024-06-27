<?php

namespace App\ConsoleCommand\Interactive;

use App\Config\Processor\TemplateMakeFileProcessor;
use App\Config\Reader\ConfigReader;
use App\FolderNames;
use App\Util\Path;
use Psr\Log\LoggerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

readonly class PromptOptionsGenerator
{
    public function __construct(
        private Path $path,
        private LoggerInterface $logger,
        private ConfigReader $configReader,
        private TemplateMakeFileProcessor $templateMakeFileProcessor,
    ) {
    }

    public function generate(): PromptOptions
    {
        $finder = new Finder();
        $filesystem = new Filesystem();

        // iterate template folders
        $finder->in($this->path->joinWithBase(FolderNames::TEMPLATE->value));
        $finder->directories()->depth(0);

        $variants = [];
        $options = [];

        foreach ($finder as $folder) {
            $packageName = $folder->getFilename();
            $makePath = Path::join($folder->getPathname(), 'make.yml');
            if (!$filesystem->exists($makePath)) {
                $this->logger->warning(sprintf('make.yml missing for template package %s', $packageName));
                continue;
            }

            $make = $this->templateMakeFileProcessor->process($packageName);

            foreach ($make as $variantName => $d) {
                $description = array_key_exists('description', $d) ? sprintf('(%s) %s', $variantName, $d['description']) : $variantName;

                $variants[$packageName][$variantName] = $description;
                $options[$packageName][$variantName] = [];
                if (array_key_exists('artwork', $d)) {
                    $options[$packageName][$variantName]['artwork'] = 'Build rom artwork?';
                }
                if (array_key_exists('folder', $d)) {
                    $options[$packageName][$variantName]['folder'] = 'Build folder artwork?';
                }
                if (array_key_exists('portmaster', $d)) {
                    $options[$packageName][$variantName]['portmaster'] = 'Build portmaster artwork?';
                }
                $options[$packageName][$variantName]['zip'] = 'Zip output into archive?';
                if ($this->configReader->getConfig()->sftpIp) {
                    $options[$packageName][$variantName]['transfer'] = 'Attempt SFTP Transfer?';
                }
            }
        }

        return new PromptOptions(
            $variants,
            $options
        );
    }
}
