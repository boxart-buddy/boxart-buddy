<?php

namespace App\Config\Processor;

use App\Config\Definition\TemplateMakeFileConfiguration;
use App\FolderNames;
use App\Util\Path;
use Symfony\Component\Config\Definition\Processor;
use Symfony\Component\Yaml\Yaml;

readonly class TemplateMakeFileProcessor
{
    public function __construct(private Path $path)
    {
    }

    public function process(string $templatePackage): array
    {
        $config = Yaml::parseFile(
            $this->path->joinWithBase(FolderNames::TEMPLATE->value, $templatePackage, 'make.yml')
        );

        $processor = new Processor();
        $templateMakeFileConfiguration = new TemplateMakeFileConfiguration();

        return $processor->processConfiguration(
            $templateMakeFileConfiguration,
            [
                $config,
            ]
        );
    }
}
