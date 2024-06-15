<?php

namespace App\Config\Definition;

use Symfony\Component\Config\Definition\Builder\TreeBuilder;
use Symfony\Component\Config\Definition\ConfigurationInterface;

class ApplicationConfiguration implements ConfigurationInterface
{
    public function getConfigTreeBuilder(): TreeBuilder
    {
        $treeBuilder = new TreeBuilder('application');

        $root = $treeBuilder->getRootNode();

        $root
            ->children()
                ->scalarNode('rom_folder')
                    ->isRequired()
                    ->cannotBeEmpty()
                ->end()
                ->scalarNode('romset_name')
                    ->cannotBeEmpty()
                    ->treatNullLike('custom')
                ->end()
                ->scalarNode('screenscraper_user')
                    ->isRequired()
                    ->cannotBeEmpty()
                ->end()
                ->scalarNode('screenscraper_pass')
                    ->isRequired()
                    ->cannotBeEmpty()
                ->end()
                ->integerNode('optimize_jpg')
                    ->defaultNull()
                ->end()
                ->scalarNode('skyscraper_config_folder_path')
                    ->defaultValue('~/.skyscraper')
                ->end()
                ->arrayNode('sftp')
                    ->children()
                        ->scalarNode('ip')->end()
                        ->scalarNode('port')
                            ->defaultValue('2022')
                            ->treatNullLike('2022')
                        ->end()
                        ->scalarNode('user')
                            ->defaultValue('muos')
                            ->treatNullLike('muos')
                        ->end()
                        ->scalarNode('pass')
                            ->defaultValue('muos')
                            ->treatNullLike('muos')
                        ->end()
                    ->end()
                ->end()
                ->arrayNode('platforms')
                    ->isRequired()
                    ->scalarPrototype()
                        ->validate()
                        ->ifEmpty()
                        ->thenUnset()
                        ->end()
                    ->end()
                ->end()
                ->arrayNode('package')
                    ->isRequired()
                    ->requiresAtLeastOneElement()
                    ->scalarPrototype()
                        ->validate()
                        ->ifEmpty()
                        ->thenUnset()
                        ->end()
                    ->end()
                ->end()
                ->arrayNode('portmaster')
                    ->scalarPrototype()
                        ->validate()
                        ->ifEmpty()
                        ->thenUnset()
                        ->end()
                    ->end()
                ->end()
            ->end();

        return $treeBuilder;
    }
}
