<?php

namespace App\Util\Enum;

trait EnumTrait
{
    public static function exists(string $caseName): bool
    {
        $cases = self::cases();

        return in_array(strtoupper($caseName), array_column($cases, 'name'), true);
    }

    public static function names(): array
    {
        return array_column(self::cases(), 'name');
    }
}
