<?php

namespace App\Util\Enum;

trait BackedEnumTrait
{
    use EnumTrait;

    public static function fromName(string $name): string
    {
        if (!self::exists($name)) {
            throw new \InvalidArgumentException(sprintf('Case name `%s` is invalid', $name));
        }

        return constant('self::'.strtoupper($name))->value;
    }

    public static function valueExists(string $caseValue): bool
    {
        $cases = self::cases();

        return in_array($caseValue, array_column($cases, 'value'), true);
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
