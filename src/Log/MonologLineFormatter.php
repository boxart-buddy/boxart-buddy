<?php

namespace App\Log;

use App\Util\LogUtility;
use Monolog\Formatter\LineFormatter;
use Monolog\LogRecord;

/**
 * Allows line breaks and strips ANSI characters.
 */
class MonologLineFormatter extends LineFormatter
{
    public function __construct()
    {
        parent::__construct();
        $this->allowInlineLineBreaks = true;
    }

    public function format(LogRecord $record): string
    {
        return LogUtility::cleanAnsiString(parent::format($record));
    }
}
