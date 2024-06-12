<?php

namespace App\PostProcess;

readonly class VerticalDotScrollbarPostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;

    public const POSITION = 'position';
    public const OPACITY = 'opacity';

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
