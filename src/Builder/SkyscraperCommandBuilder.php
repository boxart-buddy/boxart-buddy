<?php

namespace App\Builder;

class SkyscraperCommandBuilder
{
    public function __construct(
        private ?string $gamelistPath = null,
        private ?string $artworkPath = null,
        private ?string $inputPath = null,
        private ?string $outputPath = null,
        private ?array $flags = null,
        private ?string $platform = null,
        private ?string $credentials = null,
        private ?string $scraper = null,
        private ?int $verbosity = null,
        private ?string $romName = null,
        private ?string $query = null,
    ) {
    }

    public function build(): array
    {
        $parts = [];
        if (isset($this->gamelistPath)) {
            $parts['-g'] = $this->gamelistPath;
        }
        if (isset($this->artworkPath)) {
            $parts['-a'] = $this->artworkPath;
        }
        if (isset($this->inputPath)) {
            $parts['-i'] = $this->inputPath;
        }
        if (isset($this->outputPath)) {
            $parts['-o'] = $this->outputPath;
        }
        if (isset($this->platform)) {
            $parts['-p'] = $this->platform;
        }
        if (isset($this->credentials)) {
            $parts['-u'] = $this->credentials;
        }
        if (isset($this->scraper)) {
            $parts['-s'] = $this->scraper;
        }
        if (isset($this->flags)) {
            $parts['--flags'] = implode(',', $this->flags);
        }
        if (isset($this->verbosity)) {
            $parts['--verbosity'] = $this->verbosity;
        }
        if (isset($this->query)) {
            $parts['--query'] = $this->query;
        }

        $command = ['Skyscraper'];

        if ($this->romName) {
            $command[] = $this->romName;
        }

        foreach ($parts as $arg => $val) {
            $command[] = $arg;
            $command[] = $val;
        }

        return $command;
    }

    public function setCredentials(string $credentials): SkyscraperCommandBuilder
    {
        $this->credentials = $credentials;

        return $this;
    }

    public function setVerbosity(int $verbosity): SkyscraperCommandBuilder
    {
        $this->verbosity = $verbosity;

        return $this;
    }

    public function setScraper(string $scraper): SkyscraperCommandBuilder
    {
        $this->scraper = $scraper;

        return $this;
    }

    public function setInputPath(string $inputPath): SkyscraperCommandBuilder
    {
        $this->inputPath = $inputPath;

        return $this;
    }

    public function setPlatform(string $platform): SkyscraperCommandBuilder
    {
        $this->platform = $platform;

        return $this;
    }

    public function setOutputPath(string $outputPath): SkyscraperCommandBuilder
    {
        $this->outputPath = $outputPath;

        return $this;
    }

    public function setArtworkPath(string $artworkPath): SkyscraperCommandBuilder
    {
        $this->artworkPath = $artworkPath;

        return $this;
    }

    public function setGamelistPath(string $gamelistPath): SkyscraperCommandBuilder
    {
        $this->gamelistPath = $gamelistPath;

        return $this;
    }

    public function addFlag(string|array $flag): SkyscraperCommandBuilder
    {
        if (is_string($flag)) {
            $this->flags[] = $flag;

            return $this;
        }
        $this->flags = array_merge($this->flags ?? [], $flag);

        return $this;
    }

    public function setRomName(?string $romName): SkyscraperCommandBuilder
    {
        $this->romName = $romName;

        return $this;
    }

    public function setQuery(string $query): SkyscraperCommandBuilder
    {
        $this->query = $query;

        return $this;
    }
}
