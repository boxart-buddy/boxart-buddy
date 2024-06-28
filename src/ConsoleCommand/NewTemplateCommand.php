<?php

namespace App\ConsoleCommand;

use App\FolderNames;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;

use function Laravel\Prompts\text;

#[AsCommand(
    name: 'new-template',
    description: 'Bootstraps a new template with correct folder structure',
)]
class NewTemplateCommand extends Command
{
    public function __construct(
        readonly private Path $path,
        readonly private LoggerInterface $logger,
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new BlockSectionHelper($input, $output, $this->logger);
        $io->heading();

        $filesystem = new Filesystem();

        $folders = ['artwork', 'mapping', 'preview', 'resources', 'resources-post-process', 'tokens'];

        $templateName = text('Name of your template');

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
        $makefileContents = sprintf("%s:\n  metadata:\n    height: full\n    type: standalone\n  description: 'describe your template'\n  package_name: %s\n  artwork:\n    file: artwork.xml", $exampleCommandName, $exampleCommandName);

        $filesystem->appendToFile(
            Path::join($base, 'make.yml'),
            $makefileContents
        );

        $filesystem->copy(
            $this->path->joinWithBase('resources', 'artwork.xml'),
            Path::join($base, 'artwork', 'artwork.xml')
        );

        $io->done(sprintf('Template folder `%s` created', $templateName));

        $io->help(sprintf('Edit the artwork file at `%s` and run `make build` to generate artwork', Path::join($templateName, 'artwork', 'artwork.xml')));

        return Command::SUCCESS;
    }
}
