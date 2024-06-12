<?php

namespace App\Util;

use Symfony\Component\Filesystem\Filesystem;

class DateTimeFile
{
    public static function readDatetimeValueFromFile(string $folder, string $filename): ?\DateTimeImmutable
    {
        $datetimeFile = Path::join($folder, $filename);
        $filesystem = new Filesystem();
        if (!$filesystem->exists($datetimeFile)) {
            return null;
        }

        return \DateTimeImmutable::createFromFormat(
            \DateTimeInterface::ATOM,
            $filesystem->readFile($datetimeFile)
        ) ?: null;
    }

    public static function writeDatetimeValueToFile(string $folder, string $filename, ?\DateTimeInterface $datetime = null): void
    {
        $datetimeFile = Path::join($folder, $filename);
        $filesystem = new Filesystem();
        if ($filesystem->exists($datetimeFile)) {
            $filesystem->remove($datetimeFile);
        }
        if (null === $datetime) {
            $datetime = new \DateTimeImmutable();
        }
        $filesystem->appendToFile(
            $datetimeFile,
            $datetime->format(\DateTimeInterface::ATOM)
        );
    }
}
