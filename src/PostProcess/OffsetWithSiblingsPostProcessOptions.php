<?php

namespace App\PostProcess;

class OffsetWithSiblingsPostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;

    public const OFFSET_Y = 'offset_y';
    public const OFFSET_X = 'offset_x';
    public const SIBLING_COUNT = 'sibling_count';
    public const SCALE = 'scale';
    public const EFFECT = 'effect';
    public const OPACITY = 'opacity';
    public const LOOP = 'loop';
    public const CIRCLE = 'circle';
    public const RENDER = 'render';
    public const CIRCLE_RADIUS = 'circle_radius';

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
            'Scale parameter will resize siblings using a logarithmic scale. A float between 0-1 (e.g 0.8), the last sibling will be scaled to this size',
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
        $options[] = new PostProcessOption(
            self::OPACITY,
            null,
            null,
            'Opacity parameter will make siblings transparent using a logarithmic scale. A float between 0-1 (e.g 0.8), the last sibling will be this percent transparent',
            false
        );
        $options[] = new PostProcessOption(
            self::LOOP,
            ['true'],
            'false',
            'If set to true then first and last sibling will be amended to show a loop (rather than blanks)',
            false
        );
        $options[] = new PostProcessOption(
            self::CIRCLE,
            ['half-circle-left', 'half-circle-right', 'half-circle-top', 'half-circle-bottom'],
            null,
            'The amount of rotation of the final sibling',
            false
        );
        $options[] = new PostProcessOption(
            self::CIRCLE_RADIUS,
            null,
            320,
            'The radius of the circle. Only used if `circle` is set',
            false
        );
        $options[] = new PostProcessOption(
            self::RENDER,
            ['both', 'ahead', 'behind'],
            'both',
            'Which siblings to render, by default siblings behind and ahead are rendered',
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
