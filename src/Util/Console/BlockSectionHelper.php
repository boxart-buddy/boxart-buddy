<?php

namespace App\Util\Console;

use App\Command\TargetableCommandInterface;
use Symfony\Component\Console\Helper\ProgressBar;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\ConsoleSectionOutput;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * A facade that allows simpler styling of sections/blocks of console output.
 * Provides a minimal interface for ouputting blocks of text that can be overwritten.
 */
class BlockSectionHelper
{
    private array $sections = [];
    private ?string $currentSection = null;

    public function __construct(
        readonly private InputInterface $input,
        readonly private OutputInterface $consoleOutput
    ) {
    }

    public function style(): CustomSymfonyStyle
    {
        return $this->getStyleForCurrentSection();
    }

    private function getStyleForCurrentSection(): CustomSymfonyStyle
    {
        return new CustomSymfonyStyle($this->input, $this->getCurrentSectionOutput());
    }

    public function waitOrFail(string $sectionName, string $message, callable $callable): void
    {
        $this->section($sectionName);
        $this->wait($message);
        try {
            $callable();
            $this->done($message, true);
        } catch (\Exception $e) {
            $this->failure(sprintf("$message: %s", $e->getMessage()), true);
        }
    }

    public function waitOrFailTargetableCommandsWithProgressBar(string $sectionName, string $message, iterable $iterable, callable $callable): void
    {
        $this->section($sectionName);
        $this->wait($message);

        $progressBar = $this->getProgressBar();
        try {
            foreach ($progressBar->iterate($iterable) as $i) {
                if ($i instanceof TargetableCommandInterface) {
                    $progressBar->setMessage($i->getTarget());
                }
                $callable($i);
            }
            $this->done($message, true);
        } catch (\Exception $e) {
            $this->failure(sprintf("$message: %s", $e->getMessage()), true);
        }
    }

    public function section(string $name): BlockSectionHelper
    {
        if (array_key_exists($name, $this->sections)) {
            $this->currentSection = $name;

            return $this;
        }
        if (!$this->consoleOutput instanceof ConsoleOutput) {
            throw new \RuntimeException();
        }
        $this->sections[$name] = $this->consoleOutput->section();
        $this->currentSection = $name;

        return $this;
    }

    private function getCurrentSectionOutput(): ConsoleSectionOutput
    {
        if (!$this->currentSection || !array_key_exists($this->currentSection, $this->sections)) {
            throw new \RuntimeException();
        }

        return $this->sections[$this->currentSection];
    }

    public function wait(string $message, bool $overwrite = false): void
    {
        $this->callBlockMethodOnStyle($message, $overwrite, 'wait');
    }

    public function done(string $message, bool $overwrite = false): void
    {
        $this->callBlockMethodOnStyle($message, $overwrite, 'done');
    }

    public function complete(string $message, bool $overwrite = false): void
    {
        $this->callBlockMethodOnStyle($message, $overwrite, 'complete');
    }

    public function failure(string $message, bool $overwrite = false): void
    {
        $this->callBlockMethodOnStyle($message, $overwrite, 'failure');
    }

    public function newLine(): void
    {
        $this->getStyleForCurrentSection()->newLine();
    }

    public function getProgressBar(string $defaultMessage = ''): ProgressBar
    {
        $progressBar = $this->getStyleForCurrentSection()->createProgressBar();
        $progressBar->setFormat('%current%/%max% [%bar%] %percent:3s%% (%message%)');
        $progressBar->setMessage($defaultMessage);

        return $progressBar;
    }

    private function callBlockMethodOnStyle(string $message, bool $overwrite, string $type): void
    {
        if ($overwrite) {
            $o = $this->getCurrentSectionOutput();
            $o->clear();
        }

        $this->getStyleForCurrentSection()->$type($message);
    }

    public function clear(): void
    {
        $o = $this->getCurrentSectionOutput();
        $o->clear();
    }
}
