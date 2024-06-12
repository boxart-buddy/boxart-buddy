<?php

namespace App\Model;

class Artwork
{
    public function __construct(public string $absoluteFilepath)
    {
    }

    public function filename(): string
    {
        return basename($this->absoluteFilepath);
    }

    public function name(): string
    {
        return basename($this->absoluteFilepath, '.xml');
    }

    public function read(): string
    {
        return file_get_contents($this->absoluteFilepath);
    }
}
