<?php

namespace App\ConsoleCommand;

use App\Hugo\HugoResourceCreator;
use App\Util\Console\BlockSectionHelper;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'template-to-hugo',
    description: 'Copies template resources to locations they can be used by hugo',
)]
class TemplateToHugoCommand extends Command
{
    public function __construct(readonly private HugoResourceCreator $hugoResourceCreator)
    {
        parent::__construct();
    }

    protected function configure(): void
    {
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new BlockSectionHelper($input, $output);
        $io->heading();

        $this->hugoResourceCreator->copyTemplatePreviewsToStatic();
        $this->hugoResourceCreator->createHugoDataFixtureForTemplates();

        $io->complete('Complete');

        return Command::SUCCESS;
    }
}
