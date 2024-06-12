<?php

namespace App\Tests\Util;

use App\Util\TokenUtility;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

class TokenUtilityTest extends TestCase
{
    #[DataProvider('tokensProvider')]
    public function testRemoveExtension(string $input, array $expected): void
    {
        $this->assertEquals($expected, TokenUtility::parseRuntimeTokens($input));
    }

    public static function tokensProvider(): array
    {
        return [
            'one-simple' => ['background:blue.png', ['background' => 'blue.png']],
            'two-simple' => ['background:blue.png|header:magic.png', ['background' => 'blue.png', 'header' => 'magic.png']],
            'one-json' => ['{"background":"blue.jpg"}', ['background' => 'blue.jpg']],
            'two-json' => ['{"background":"blue.jpg", "header":"red.jpg"}', ['background' => 'blue.jpg', 'header' => 'red.jpg']],
            'duplicate-makes-array' => ['background:blue.png|background:red.jpg', ['background' => ['blue.png', 'red.jpg']]],
        ];
    }
}
