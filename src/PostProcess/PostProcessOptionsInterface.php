<?php

namespace App\PostProcess;

interface PostProcessOptionsInterface
{
    /**
     * @return array Returns an array keyed by option name, with an array of valid values for that option
     */
    public static function getOptions(): array;

    public static function mergeDefaults(array $options): array;
}
