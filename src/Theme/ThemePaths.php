<?php

namespace App\Theme;

use App\Util\Enum\BackedEnumTrait;

enum ThemePaths: string
{
    use BackedEnumTrait;

    case DEFAULT = 'image/wall/default.png';
    case OVERLAY = 'image/overlay.png';
}
