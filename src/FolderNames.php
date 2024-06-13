<?php

namespace App;

use App\Util\Enum\BackedEnumTrait;

enum FolderNames: string
{
    use BackedEnumTrait;

    case PACKAGE = 'package';
    case ZIPPED = 'zipped';
    case TEMPLATE = 'template';
    case THEME = 'themes';
    case TEMP = 'temp';
    case SKIPPED = 'skipped';
    case USER_CONFIG = 'user_config';
}
