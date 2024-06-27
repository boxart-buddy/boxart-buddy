<?php

namespace App\Event;

use Symfony\Contracts\EventDispatcher\Event;

class CommandProcessingEvent extends Event
{
    public function __construct(public string $name)
    {
    }
}
