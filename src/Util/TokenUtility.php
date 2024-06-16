<?php

namespace App\Util;

class TokenUtility
{
    public static function splitArgumentAndOptions(string $inputString): array
    {
        if (!str_contains($inputString, '|')) {
            return [
                'argument' => $inputString,
                'options' => [],
            ];
        }

        $argAndOptons = explode('|', $inputString, 2);

        return [
            'argument' => $argAndOptons[0],
            'options' => self::parseRuntimeTokens($argAndOptons[1]),
        ];
    }

    public static function parseRuntimeTokens(string $token): array
    {
        if (str_starts_with($token, '{') || str_starts_with($token, '[')) {
            return self::parseAsJson($token);
        }

        $runtimeTokens = [];

        $tokens = explode('|', $token);

        foreach ($tokens as $t) {
            $t = trim($t);
            if (strpos($t, ':')) {
                $tokenParts = explode(':', $t, 2);
                if (1 === count($tokenParts)) {
                    throw new \InvalidArgumentException(sprintf('Cannot parse runtime token (parsing as pipe seperated): `%s`, double check the format (must be a colon seperated pair)', $token));
                }
                if (2 === count($tokenParts)) {
                    $k = $tokenParts[0];
                    $v = $tokenParts[1];
                    // if an option with the same key has already been set then store the values in an array
                    if (isset($runtimeTokens[$k]) && is_array($runtimeTokens[$k])) {
                        $runtimeTokens[$k][] = $v;
                    }
                    if (isset($runtimeTokens[$k]) && !is_array($runtimeTokens[$k])) {
                        $runtimeTokens[$k] = [$runtimeTokens[$k], $v];
                    }
                    if (!isset($runtimeTokens[$k])) {
                        $runtimeTokens[$k] = $v;
                    }
                }
            }
        }

        if (0 === count($runtimeTokens)) {
            throw new \InvalidArgumentException(sprintf('Cannot parse runtime token (parsing as pipe seperated): `%s`, double check the format (must be a colon seperated pair)', $token));
        }

        return $runtimeTokens;
    }

    private static function parseAsJson(string $token): array
    {
        $runtimeTokens = json_decode($token, true);

        if (null === $runtimeTokens) {
            throw new \InvalidArgumentException(sprintf('Cannot parse runtime token (parsing as json) double check your formatting: `%s` ', $token));
        }

        return $runtimeTokens;
    }

    public static function splitStringIntoArtworkPackageAndFileName(string $input): array
    {
        $token = self::parseRuntimeTokens($input);
        if (1 !== count($token)) {
            throw new \InvalidArgumentException(sprintf('Argument must be of form `your-template:artwork-name.xml` or `your-template:mapping-name.yml`. Given value was `%s`', $input));
        }

        $packageName = key($token);
        $filename = reset($token);

        if (!in_array(pathinfo($filename, PATHINFO_EXTENSION), ['yml', 'xml'])) {
            throw new \InvalidArgumentException(sprintf('Argument must end with `.xml` or `.yml`. `%s` given', $filename));
        }

        return [
            'artworkPackage' => $packageName,
            'filename' => $filename,
        ];
    }
}
