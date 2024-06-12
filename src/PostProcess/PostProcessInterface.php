<?php

namespace App\PostProcess;

use App\Command\PostProcessCommand;

interface PostProcessInterface
{
    public function getName(): string;

    public function process(PostProcessCommand $command): void;

    public function processOptions(array $options): array;
}
