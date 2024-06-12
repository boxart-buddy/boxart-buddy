<?php

namespace App\Command;

readonly class PostProcessCommand implements CommandInterface
{
    public function __construct(
        public string $target,
        public string $strategy,
        public array $options
    ) {
    }
}
