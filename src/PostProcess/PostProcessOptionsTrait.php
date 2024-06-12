<?php

namespace App\PostProcess;

trait PostProcessOptionsTrait
{
    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    protected static function validateOptions(array $postProcessOptions, array $options): void
    {
        foreach ($postProcessOptions as $postProcessOption) {
            if (!$postProcessOption instanceof (PostProcessOption::class)) {
                throw new \InvalidArgumentException();
            }

            if (!$postProcessOption->multi && isset($options[$postProcessOption->name]) && is_array($options[$postProcessOption->name])) {
                throw new \InvalidArgumentException(sprintf('Cannot set multiple values for option `%s`, only one value is allowed. `[%s]` given', $postProcessOption->name, implode(', ', $options[$postProcessOption->name])));
            }

            if (!$postProcessOption->default && $postProcessOption->required && !isset($options[$postProcessOption->name])) {
                throw new PostProcessMissingOptionException($postProcessOption->name);
            }

            if (isset($options[$postProcessOption->name])) {
                if ($postProcessOption->valid) {
                    if (!$postProcessOption->multi && !in_array($options[$postProcessOption->name], $postProcessOption->valid)) {
                        throw new PostProcessOptionException($postProcessOption->name, $options[$postProcessOption->name], $postProcessOption->valid);
                    }
                    if ($postProcessOption->multi && count(array_diff($options[$postProcessOption->name], $postProcessOption->valid)) > 0) {
                        throw new PostProcessOptionException($postProcessOption->name, implode(' ,', $options[$postProcessOption->name]), $postProcessOption->valid);
                    }
                }
            }
        }
    }

    /**
     * @throws PostProcessOptionException
     * @throws PostProcessMissingOptionException
     */
    public static function mergeOptionsUsingPostProcessOptions(array $postProcessOptions, array $options): array
    {
        $defaults = [];
        foreach ($postProcessOptions as $postProcessOption) {
            if (null !== $postProcessOption->default) {
                // set defaults
                $defaults[$postProcessOption->name] = $postProcessOption->default;
            }

            // coalesce multi to array if not array already
            if ((true === $postProcessOption->multi) && isset($options[$postProcessOption->name]) && !is_array($options[$postProcessOption->name])) {
                $options[$postProcessOption->name] = [$options[$postProcessOption->name]];
            }
        }

        $merged = array_merge($defaults, $options);

        self::validateOptions($postProcessOptions, $merged);

        return $merged;
    }
}
