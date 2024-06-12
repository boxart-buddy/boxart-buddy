<?php

namespace App\Tests\Util;

use App\Util\Path;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

class PathTest extends TestCase
{
    #[DataProvider('joinedPathsProvider')]
    public function testjoinWithBase(array $input, string $expected): void
    {
        $path = new Path('/home/username/boxart-buddy');
        $this->assertEquals($expected, $path->joinWithBase(...$input));
    }

    #[DataProvider('fileExtensionsProvider')]
    public function testRemoveExtension(string $input, string $expected): void
    {
        $path = new Path('/home/username/boxart-buddy');

        $this->assertEquals($expected, $path->removeExtension($input));
    }

    public static function joinedPathsProvider(): array
    {
        return [
            'single-complete-path' => [['my/uncool/path/'], '/home/username/boxart-buddy/my/uncool/path/'],
            'single-path' => [['your'], '/home/username/boxart-buddy/your'],
            'multi-path-leading-slash' => [['/my', '/dir'], '/home/username/boxart-buddy/my/dir'],
            'multi-path-mixed' => [['my', 'big/', 'path'], '/home/username/boxart-buddy/my/big/path'],
            'multi-path-single-path-combined' => [['my', 'small/path/'], '/home/username/boxart-buddy/my/small/path/'],
        ];
    }

    public static function fileExtensionsProvider(): array
    {
        return [
            'simple' => ['my_file.php', 'my_file'],
            'with-multiple-dots' => ['a.b.c.d.file.php', 'a.b.c.d.file'],
            'with-short-extension' => ['a.b.c.d.file.7z', 'a.b.c.d.file'],
            'with-long-extension' => ['readme.archive', 'readme'],
            'without-extension' => ['readme', 'readme'],
            'with-trailing-dot' => ['readme.', 'readme'],
        ];
    }
}
