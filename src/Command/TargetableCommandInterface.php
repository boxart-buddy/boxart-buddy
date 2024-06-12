<?php

namespace App\Command;

interface TargetableCommandInterface extends CommandInterface
{
    public function getTarget(): string;
}
