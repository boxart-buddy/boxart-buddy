<?php

namespace App\PostProcess;

class OffsetWithSiblingsPostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;

    public const OFFSET_Y = 'offset-y';
    public const OFFSET_X = 'offset-x';
    public const SIBLING_COUNT = 'sibling-count';
    public const SCALE = 'scale';
    public const EFFECT = 'effect';

    public static function getOptions(): array
    {
        $options = [];
        $options[] = new PostProcessOption(
            self::OFFSET_Y,
            null,
            '0',
            'The number of pixels to offset from siblings on the Y axis',
        );
        $options[] = new PostProcessOption(
            self::OFFSET_X,
            null,
            '0',
            'The number of pixels to offset from siblings on the X axis',
        );
        $options[] = new PostProcessOption(
            self::SIBLING_COUNT,
            null,
            '5',
            'The number of siblings to offset in each direction (e.g setting 2 will yield 4 siblings)',
        );
        $options[] = new PostProcessOption(
            self::SCALE,
            null,
            null,
            'Scale parameter will resize siblings using a logarithmic scale. A float between 0-1 (e.g 0.8)',
            false
        );
        $options[] = new PostProcessOption(
            self::EFFECT,
            ['greyscale', 'blur', 'pixelate'],
            null,
            'Effect parameter will apply a graphical effect to siblings, can use more than one',
            false,
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
