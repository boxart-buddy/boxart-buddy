<?php

namespace App\Event;

class CommandProcessingStageStartedEvent extends CommandProcessingEvent
{
    public function __construct(string $name, public bool $withProgression = false, public ?int $steps = null)
    {
        parent::__construct($name);
    }
}
