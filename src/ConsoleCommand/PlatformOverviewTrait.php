<?php

namespace App\ConsoleCommand;

use App\Config\InvalidConfigException;
use App\Config\Validator\ConfigValidator;
use App\Util\Console\BlockSectionHelper;

trait PlatformOverviewTrait
{
    protected function getPlatformOverview(BlockSectionHelper $io, ConfigValidator $configValidator)
    {
        $io->section('platform-overview');

        try {
            $report = $configValidator->getPlatformReport();
        } catch (InvalidConfigException $e) {
            $io->failure($e->getMessage(), true);
            exit;
        }

        $tableHeader = ['Platform', 'Folder', 'File Count'];
        $tableBody = [];

        foreach ($report as $platform => $data) {
            $tableBody[] = [$platform, $data['folder'], $data['count']];
        }

        $io->style()->table(
            $tableHeader,
            $tableBody
        );
    }
}
