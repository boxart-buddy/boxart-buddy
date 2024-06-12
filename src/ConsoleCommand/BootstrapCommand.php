<?php

namespace App\ConsoleCommand;

use App\Config\Processor\ApplicationConfigurationProcessor;
use App\FolderNames;
use App\PlatformDists;
use App\Portmaster\PortmasterDataImporter;
use App\Util\Console\BlockSectionHelper;
use App\Util\Path;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;

#[AsCommand(
    name: 'bootstrap',
    description: 'Add a short description for your command',
)]
class BootstrapCommand extends Command
{
    public function __construct(
        readonly private Path $path,
        readonly private PortmasterDataImporter $portmasterDataImporter,
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addOption('preset', 'p', InputOption::VALUE_REQUIRED, 'If set will use a predefined default to populate platform configuration', 'DEFAULT')
            ->addOption('overwrite', 'o', InputOption::VALUE_NONE, 'If set will overwrite any user configurations')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        if (!$output instanceof ConsoleOutput) {
            throw new \RuntimeException();
        }

        $outputHelper = new BlockSectionHelper($input, $output);

        $outputHelper->section('configs');
        $outputHelper->wait('Creating config files and folders');

        $overwrite = $input->getOption('overwrite');
        if ($overwrite) {
            $outputHelper->wait('Creating config files and folders (using overwrite mode)', true);
        }

        // config bootstrap
        $this->createNewFileFromDist(
            ApplicationConfigurationProcessor::CONFIG_FILENAME,
            'config.yml.dist',
            $overwrite
        );

        // platform config bootstrap
        $platformConfig = strtoupper($input->getOption('preset'));

        // check is valid platform config name
        if (!PlatformDists::exists($platformConfig)) {
            $outputHelper->failure(
                sprintf('Preset option `%s` unknown, use one of `%s` ', $platformConfig, implode(', ', PlatformDists::names()))
            );
            exit;
        }

        $platformConfigFilename = PlatformDists::fromName($platformConfig);

        $this->createNewFileFromDist(
            ApplicationConfigurationProcessor::CONFIG_PLATFORM_FILENAME,
            $platformConfigFilename,
            $overwrite
        );

        // make sure folders exist
        $filesystem = new Filesystem();
        foreach (FolderNames::values() as $folder) {
            if ($filesystem->exists($this->path->joinWithBase($folder))) {
                continue;
            }
            $filesystem->mkdir($this->path->joinWithBase($folder));
        }
        $outputHelper->done('Creating config files and folders', true);

        $outputHelper->section('portmaster')->wait('Importing Portmaster data');
        $this->portmasterDataImporter->importPortmasterDataIfNotImportedSince(new \DateInterval('PT5M'));

        $outputHelper->done('Importing Portmaster data', true);

        $outputHelper->section('end')->complete(
            'Bootstrap complete. Edit config.yml & config_platform.yml to set credentials and preferences
        ');

        return Command::SUCCESS;
    }

    private function createNewFileFromDist(string $filename, string $distFilename, bool $overwrite): void
    {
        $filesystem = new Filesystem();

        if (!$overwrite && $filesystem->exists($this->path->joinWithBase($filename))) {
            return;
        }

        $filesystem->copy(
            $this->path->joinWithBase('resources', 'config', $distFilename),
            $this->path->joinWithBase($filename),
            $overwrite
        );
    }

    //    private function copyIncludedTemplatesToRootFolder(bool $overwrite)
    //    {
    //        $filesystem = new Filesystem();
    //
    //        $filesystem->mirror(
    //            base_path().'/resources/template',
    //            base_path().'/'.FolderNames::TEMPLATE->value,
    //            null,
    //            ['override' => $overwrite]
    //        );
    //    }
}
