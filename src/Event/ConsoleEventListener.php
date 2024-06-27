<?php

namespace App\Event;

use App\Util\Console\BlockSectionHelper;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Helper\ProgressBar;
use Symfony\Component\Console\Helper\ProgressIndicator;
use Symfony\Component\Console\Input\ArgvInput;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\EventDispatcher\Attribute\AsEventListener;

final class ConsoleEventListener
{
    private BlockSectionHelper $blockSectionHelper;
    private ProgressBar|ProgressIndicator|null $progress = null;

    public function __construct(
        LoggerInterface $logger,
        #[Autowire(param: 'kernel.runtime_mode.cli')]
        private bool $runtimeModeCli
    ) {
        if ($this->runtimeModeCli) {
            $i = new ArgvInput();
            $o = new ConsoleOutput();
            $this->blockSectionHelper = new BlockSectionHelper($i, $o, $logger);
        }
    }

    #[AsEventListener]
    public function onCommandProcessingStageStartedEvent(CommandProcessingStageStartedEvent $event): void
    {
        if (!$this->runtimeModeCli) {
            return;
        }
        $this->blockSectionHelper->section($event->name);
        $this->blockSectionHelper->wait($event->name);

        if (!$event->withProgression) {
            return;
        }

        // if max steps then use progress bar, otherwise progress indicator
        if ($event->steps) {
            $this->progress = $this->blockSectionHelper->getProgressBar();
            $this->progress->setMaxSteps($event->steps);
            $this->progress->start();
        }
        if (!$event->steps) {
            $this->progress = $this->blockSectionHelper->getProgressIndicator();
            $this->progress->start('Working...');
        }
    }

    #[AsEventListener]
    public function onCommandProcessingStageProgressedEvent(CommandProcessingStageProgressedEvent $event): void
    {
        if (!$this->runtimeModeCli) {
            return;
        }

        if (!$this->progress) {
            return;
        }

        if ($event->message) {
            $this->progress->setMessage($event->message);
        }

        $this->progress->advance();
    }

    #[AsEventListener]
    public function onCommandProcessingStageCompletedEvent(CommandProcessingStageCompletedEvent $event): void
    {
        if (!$this->runtimeModeCli) {
            return;
        }

        if ($this->progress) {
            ($this->progress instanceof ProgressBar) ? $this->progress->finish() : $this->progress->finish('Finished');
            $this->progress = null;
        }

        $this->blockSectionHelper->done($event->name, true);
    }

    #[AsEventListener]
    public function onCommandProcessingStageFailedEvent(CommandProcessingStageFailedEvent $event): void
    {
        if (!$this->runtimeModeCli) {
            return;
        }

        if ($this->progress) {
            ($this->progress instanceof ProgressBar) ? $this->progress->finish() : $this->progress->finish('Finished');
            $this->progress = null;
        }

        $this->blockSectionHelper->failure(sprintf('%s: %s', $event->name, $event->message), true);
    }
}
