<?php

namespace App\PostProcess;

class PostProcessOptionException extends \Exception
{
    public function __construct(
        readonly private string $option,
        readonly private string $value,
        readonly private array $validOptions
    ) {
        parent::__construct(
            sprintf(
                '`%s` is an invalid option for PostProcessing option `%s`, use one of `%s`',
                $this->value,
                $this->option,
                implode(', ', $this->validOptions)
            )
        );
    }
}
