<?php

namespace App\Event;

class CommandProcessingEvents
{
    public const STARTED = 'command.processing.started';
    public const FAILED = 'command.processing.failed';
    public const PROGRESSED = 'command.processing.progressed';
    public const COMPLETED = 'command.processing.completed';
}
