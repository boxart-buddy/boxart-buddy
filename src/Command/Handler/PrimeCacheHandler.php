<?php

namespace App\Command\Handler;

use App\Builder\SkyscraperCommandDirector;
use App\Command\CommandInterface;
use App\Command\PrimeCacheCommand;
use Psr\Log\LoggerInterface;
use Symfony\Component\Process\Process;

readonly class PrimeCacheHandler implements CommandHandlerInterface
{
    public function __construct(
        private LoggerInterface $logger,
        private SkyscraperCommandDirector $skyscraperCommandDirector
    ) {
    }

    public function handle(CommandInterface $command): void
    {
        if (!$command instanceof PrimeCacheCommand) {
            throw new \InvalidArgumentException();
        }

        $command = $this->skyscraperCommandDirector->getScrapeCommand($command->platform);

        $process = new Process($command);
        $process->setTimeout(60 * 60 * 6);

        $process->run(function ($type, $buffer): void {
            $this->logger->info($buffer);
        });
    }
}
