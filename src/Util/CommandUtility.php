<?php

namespace App\Util;

use Symfony\Component\Stopwatch\StopwatchEvent;

class CommandUtility
{
    public static function formatStopwatchEvent(StopwatchEvent $s): string
    {
        return sprintf(
            '%.1F seconds (Memory Used %.2F MB)',
            $s->getDuration() / 1000,
            $s->getMemory() / 1024 / 1024
        );
    }
}
