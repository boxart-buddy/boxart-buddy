<?php

namespace App\Util\Console;

use Symfony\Component\Console\Style\StyleInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

class CustomSymfonyStyle extends SymfonyStyle implements StyleInterface
{
    public function wait(string $message): void
    {
        $this->block(
            $message,
            '⏳',
            'fg=white;bg=bright-blue',
            ' ',
            true
        );
    }

    public function help(string $message): void
    {
        $this->block(
            $message,
            'ℹ️',
            'fg=white;bg=black',
            ' ',
            true
        );
    }

    public function done(string $message): void
    {
        $this->block(
            $message,
            '✅',
            'fg=white;bg=bright-green',
            ' ',
            true
        );
    }

    public function complete(string $message): void
    {
        $this->block(
            $message,
            '🙌',
            'fg=black;bg=green',
            ' ',
            true
        );
    }

    public function failure(string $message): void
    {
        $this->block(
            $message,
            '💀',
            'fg=white;bg=bright-red',
            ' ',
            true
        );
    }
}
