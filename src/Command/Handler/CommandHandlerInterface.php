<?php

namespace App\Command\Handler;

use App\Command\CommandInterface;

interface CommandHandlerInterface
{
    public function handle(CommandInterface $command): void;
}
