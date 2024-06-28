<?php

namespace App\PostProcess;

class BackgroundImagePostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;
    public const BACKGROUND = 'background';
    public const OVERLAY = 'overlay';

    public static function getOptions(): array
    {
        $options = [];
        $options[] = new PostProcessOption(
            self::BACKGROUND,
            null,
            null,
            'The background image file: resources/background/{image.png}',
            false,
            true
        );
        $options[] = new PostProcessOption(
            self::OVERLAY,
            null,
            null,
            'The overlay image file: resources/background/{image.png}',
            false
        );

        return $options;
    }

    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    public static function mergeDefaults(array $options): array
    {
        return self::mergeOptionsUsingPostProcessOptions(self::getOptions(), $options);
    }
}
