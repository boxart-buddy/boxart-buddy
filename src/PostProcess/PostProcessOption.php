<?php

namespace App\PostProcess;

readonly class PostProcessOption
{
    public function __construct(
        public string $name,
        public ?array $valid,
        public ?string $default,
        public string $description,
        public bool $required = true,
        public bool $multi = false
    ) {
    }
}
