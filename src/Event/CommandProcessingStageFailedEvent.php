<?php

namespace App\Event;

class CommandProcessingStageFailedEvent extends CommandProcessingEvent
{
    public function __construct(string $name, public string $message)
    {
        parent::__construct($name);
    }
}
