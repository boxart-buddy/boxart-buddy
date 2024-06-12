<?php

namespace App\PostProcess;

class PostProcessMissingOptionException extends \Exception
{
    public function __construct(
        readonly private string $option
    ) {
        parent::__construct(
            sprintf(
                '`%s` option is missing and it doesnt have a default value',
                $this->option
            )
        );
    }
}
