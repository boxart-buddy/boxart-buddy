<?php

namespace App\PostProcess;

class OverlayArtworkGenerationPostProcessOptions implements PostProcessOptionsInterface
{
    use PostProcessOptionsTrait;
    public const ARTWORK = 'artwork';
    public const NAMESPACE = 'namespace';
    public const TOKEN = 'token';
    public const LAYER = 'layer';

    public static function getOptions(): array
    {
        $options = [];
        $options[] = new PostProcessOption(
            self::ARTWORK,
            null,
            null,
            'The template-folder:artwork.xml pair {your-template-folder:artwork.xml}',
        );
        $options[] = new PostProcessOption(
            self::NAMESPACE,
            ['artwork', 'folder', 'portmaster'],
            'artwork',
            'Is this post-process running in folder or artwork mode?',
        );
        $options[] = new PostProcessOption(
            self::TOKEN,
            null,
            '',
            'A token string to be used to translate artwork tokens',
        );
        $options[] = new PostProcessOption(
            self::LAYER,
            ['top', 'bottom'],
            'top',
            'Layer the option on top or underneath',
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
