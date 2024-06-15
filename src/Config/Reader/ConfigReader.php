<?php

namespace App\Config\Reader;

use App\Config\Processor\ApplicationConfigurationProcessor;
use App\Model\Config;

class ConfigReader
{
    private ?Config $config = null;

    public function __construct(
        readonly private ApplicationConfigurationProcessor $applicationConfigurationProcessor
    ) {
    }

    public function getConfig(): Config
    {
        // memoize config to prevent disk rereads
        if ($this->config) {
            return $this->config;
        }

        $processedConfig = $this->applicationConfigurationProcessor->process();

        $this->config = Config::fromArray($processedConfig);

        return $this->config;
    }

    public function getConfigHash(): string
    {
        return hash('xxh3', serialize($this->getConfig()));
    }
}
