<?php

namespace App\Command;

use App\Util\Enum\BackedEnumTrait;

enum CommandNamespace: string
{
    use BackedEnumTrait;

    case ARTWORK = 'artwork';
    case FOLDER = 'folder';
    case PORTMASTER = 'portmaster';
}
