<?php

namespace App\Config\Processor;

use App\Config\Definition\ApplicationConfiguration;
use App\Util\Path;
use Symfony\Component\Config\Definition\Processor;
use Symfony\Component\Yaml\Yaml;

readonly class ApplicationConfigurationProcessor
{
    public const CONFIG_FILENAME = 'config.yml';
    public const CONFIG_PLATFORM_FILENAME = 'config_platform.yml';
    public const CONFIG_PACKAGE_FILENAME = 'config_package_muos.yml';

    public function __construct(private Path $path)
    {
    }

    public function process(): array
    {
        $config = Yaml::parseFile($this->path->joinWithBase(self::CONFIG_FILENAME));
        $platformConfig = Yaml::parseFile($this->path->joinWithBase(self::CONFIG_PLATFORM_FILENAME));
        $packageConfig = Yaml::parseFile($this->path->joinWithBase('config/application/', self::CONFIG_PACKAGE_FILENAME));

        $processor = new Processor();
        $applicationConfiguration = new ApplicationConfiguration();

        return $processor->processConfiguration(
            $applicationConfiguration,
            [$config, ['platforms' => $platformConfig], ['package' => $packageConfig]]
        );
    }
}
