<?php

namespace App;

use App\Util\Enum\BackedEnumTrait;

enum PlatformDists: string
{
    use BackedEnumTrait;

    case DEFAULT = 'config_platform.yml.dist';
    case DONE2 = 'config_platform_done2set.yml.dist';
    case TINYBEST = 'config_platform_tinybestset.yml.dist';
}
