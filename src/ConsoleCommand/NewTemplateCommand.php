<?php

namespace App\ConsoleCommand;

use App\FolderNames;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;

#[AsCommand(
    name: 'new-template',
    description: 'Bootstraps a new template with correct folder structure',
)]
class NewTemplateCommand extends Command
{
    public function __construct(readonly private Path $path)
    {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addArgument('template-name', InputArgument::REQUIRED, 'The name of the template folder to create')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new BlockSectionHelper($input, $output, $this->logger);
        $io->heading();

        $filesystem = new Filesystem();

        $folders = ['artwork', 'mapping', 'preview', 'resources', 'resources-post-process', 'tokens'];

        $templateName = $input->getArgument('template-name');
        $templateName = preg_replace('/[^a-z0-9]+/', '-', strtolower($templateName)) ?? 'default';

        $base = $this->path->joinWithBase(FolderNames::TEMPLATE->value, $templateName);

        if ($filesystem->exists($base)) {
            $io->failure(sprintf('Cannot create template folder `%s`, directory already exists. Delete the directory or choose another name', $templateName));

            return Command::FAILURE;
        }

        foreach ($folders as $folder) {
            $filesystem->mkdir(Path::join($base, $folder));
        }

        // copy basic artwork.xml and Makefile
        $exampleCommandName = sprintf('%s-example-one', $templateName);
        $makefileContents = sprintf("%s: ## Describe this recipe\n\tphp bin/console build --artwork=artwork.xml", $exampleCommandName);
        $filesystem->appendToFile(
            Path::join($base, 'Makefile'),
            $makefileContents
        );

        $filesystem->copy(
            $this->path->joinWithBase('resources', 'artwork.xml'),
            Path::join($base, 'artwork', 'artwork.xml')
        );

        $io->done(sprintf('Template folder `%s` created', $templateName));

        $io->help(sprintf('Edit the artwork file at `%s` and run `make %s` to generate artwork', Path::join($templateName, 'artwork', 'artwork.xml'), $exampleCommandName));

        return Command::SUCCESS;
    }
}
