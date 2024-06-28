<?php

namespace App\Hugo;

readonly class HugoTemplateDataFixtureEntry implements \JsonSerializable
{
    public function __construct(
        private string $templateName,
        private string $variantName,
        private string $previewPath,
        private string $type,
        private string $height,
        private bool $portmaster,
        private bool $folder,
    ) {
    }

    public function jsonSerialize(): array
    {
        return get_object_vars($this);
    }
}
