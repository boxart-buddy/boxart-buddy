<?php

namespace App\Event;

class CommandProcessingStageProgressedEvent extends CommandProcessingEvent
{
    public function __construct(string $name, public ?string $message = null)
    {
        parent::__construct($name);
    }
}
