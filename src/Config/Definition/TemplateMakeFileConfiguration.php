<?php

namespace App\Config\Definition;

use Symfony\Component\Config\Definition\Builder\TreeBuilder;
use Symfony\Component\Config\Definition\ConfigurationInterface;

class TemplateMakeFileConfiguration implements ConfigurationInterface
{
    public function getConfigTreeBuilder(): TreeBuilder
    {
        $treeBuilder = new TreeBuilder('make');

        $root = $treeBuilder->getRootNode();

        $root
            ->arrayPrototype()
                ->children()
                    ->scalarNode('description')
                        ->isRequired()
                    ->end()
                    ->scalarNode('package_name')
                        ->isRequired()
                    ->end()
                    ->arrayNode('metadata')
                        ->children()
                            ->enumNode('height')->isRequired()->values(['full', 'inner', 'partial'])->end()
                            ->enumNode('type')->isRequired()->values(['standalone', 'sibling'])->end()
                        ->end()
                    ->end()
//                    ->arrayNode('preview')
//                        ->children()
//                            ->scalarNode('static')
//                                ->isRequired()
//                            ->end()
//                            ->scalarNode('animated')
//                                ->isRequired()
//                            ->end()
//                        ->end()
                    // ->end()
                    ->arrayNode('artwork')
                        ->children()
                            ->scalarNode('file')
                                ->isRequired()
                            ->end()
                            ->arrayNode('post_process')
                                ->arrayPrototype()
                                    ->variablePrototype()->end()
                                ->end()
                            ->end()
                            ->arrayNode('token')
                                ->scalarPrototype()->end()
                            ->end()
                        ->end()
                    ->end()
                    ->arrayNode('folder')
                        ->children()
                            ->scalarNode('file')
                                ->isRequired()
                            ->end()
                            ->arrayNode('post_process')
                                ->arrayPrototype()
                                    ->variablePrototype()->end()
                                ->end()
                            ->end()
                            ->arrayNode('token')
                                ->scalarPrototype()->end()
                            ->end()
                        ->end()
                    ->end()
                    ->arrayNode('portmaster')
                        ->children()
                            ->scalarNode('file')
                                ->isRequired()
                            ->end()
                            ->arrayNode('post_process')
                                ->arrayPrototype()
                                    ->variablePrototype()->end()
                                ->end()
                            ->end()
                            ->arrayNode('token')
                                ->scalarPrototype()->end()
                            ->end()
                        ->end()
                    ->end()
                ->end()
            ->end()
            ->end();

        return $treeBuilder;
    }
}
