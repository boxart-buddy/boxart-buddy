<?php

namespace App\PostProcess;

readonly class CounterPostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;

    public const OFFSET_X = 'offset_x';
    public const OFFSET_Y = 'offset_y';
    public const POSITION = 'position';
    public const OPACITY = 'opacity';
    public const TEXT_COLOR = 'color';
    public const TEXT_FONT_FAMILY = 'font_family';
    public const TEXT_FONT_VARIANT = 'font_variant';

    public static function getOptions(): array
    {
        $options = [];
        $options[] = new PostProcessOption(
            self::POSITION,
            ['bottom-left', 'bottom-right', 'top-left', 'top-right', 'left', 'right', 'top', 'bottom'],
            'bottom-right',
            'Position of the counter'
        );
        $options[] = new PostProcessOption(
            self::OPACITY,
            null,
            '100',
            'The opacity of the counter'
        );
        $options[] = new PostProcessOption(
            self::TEXT_FONT_FAMILY,
            null,
            'roboto',
            'Text Font Family',
            true
        );
        $options[] = new PostProcessOption(
            self::TEXT_FONT_VARIANT,
            null,
            'medium',
            'Text Font Variant',
            true
        );
        $options[] = new PostProcessOption(
            self::TEXT_COLOR,
            null,
            'white',
            'Text Color',
            true
        );
        $options[] = new PostProcessOption(
            self::OFFSET_X,
            null,
            0,
            'The number of pixels to offset on the X axis',
        );
        $options[] = new PostProcessOption(
            self::OFFSET_Y,
            null,
            0,
            'The number of pixels to offset on the Y axis',
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
