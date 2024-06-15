<?php

namespace App\Util;

class LogUtility
{
    public static function cleanAnsiString(string $string): string
    {
        return preg_replace('/\e[[][A-Za-z0-9];?[0-9]*m?/', '', $string);
    }
}
