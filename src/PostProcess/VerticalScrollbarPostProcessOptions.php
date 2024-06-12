<?php

namespace App\PostProcess;

readonly class VerticalScrollbarPostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;

    public const POSITION = 'position';
    public const OPACITY = 'opacity';
    public const TRACK_COLOR = 'track-color';
    public const THUMB_COLOR = 'thumb-color';

    public static function getOptions(): array
    {
        $options = [];
        $options[] = new PostProcessOption(
            self::POSITION,
            ['left', 'right'],
            'left',
            'Position of the scrollbar'
        );
        $options[] = new PostProcessOption(
            self::OPACITY,
            null,
            '100',
            'The opacity of the scrollbar'
        );
        $options[] = new PostProcessOption(
            self::TRACK_COLOR,
            null,
            '#a2bfc2',
            'The color of the scrollbar track'
        );
        $options[] = new PostProcessOption(
            self::THUMB_COLOR,
            null,
            '#6e8284',
            'The color of the scrollbar thumb'
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
