<?php

namespace App\Command\Handler;

use App\Builder\SkyscraperCommandDirector;
use App\Command\CommandInterface;
use App\Command\PrimeCacheCommand;
use App\Portmaster\PortmasterDataImporter;
use Monolog\Attribute\WithMonologChannel;
use Psr\Log\LoggerInterface;
use Symfony\Component\Process\Process;

#[WithMonologChannel('skyscraper')]
readonly class PrimeCacheHandler implements CommandHandlerInterface
{
    public function __construct(
        private LoggerInterface $logger,
        private SkyscraperCommandDirector $skyscraperCommandDirector,
        private PortmasterDataImporter $portmasterDataImporter
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

        if (!$process->isSuccessful()) {
            throw new \RuntimeException('The scraping process failed. Check `var/log/skyscraper*.log` log file');
        }

        $this->portmasterDataImporter->scrapeUsingAlternatesList();
    }
}
