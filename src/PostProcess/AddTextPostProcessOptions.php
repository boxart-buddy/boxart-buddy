<?php

namespace App\PostProcess;

class AddTextPostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;
    public const POSITION_Y = 'position_y';
    public const MAPPING = 'mapping';
    public const TEXT_COLOR = 'text_color';
    public const TEXT_BG_COLOR = 'text_bg_color';
    public const TEXT_BG_OPACITY = 'text_bg_opacity';
    public const TEXT_FONT_FAMILY = 'font_family';
    public const TEXT_FONT_VARIANT = 'font_variant';

    public static function getOptions(): array
    {
        $options = [];
        $options[] = new PostProcessOption(
            self::POSITION_Y,
            ['center', 'bottom'],
            'bottom',
            'The vertical position',
            true
        );
        $options[] = new PostProcessOption(
            self::MAPPING,
            null,
            null,
            'Filename containing mapping of romname to text',
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
            self::TEXT_BG_COLOR,
            null,
            'black',
            'Text Background Color',
            true
        );
        $options[] = new PostProcessOption(
            self::TEXT_BG_OPACITY,
            null,
            '100',
            'Text Background Opacity',
            true
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
