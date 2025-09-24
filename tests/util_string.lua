-- tests/test_string.lua
local luaunit = require("tests.lib.luaunit")
local stringUtil = require("boxart-buddy.util.string")

-- Fake font object for testing
local function makeMockFont(charWidth)
    return {
        getWidth = function(_, str)
            return #str * charWidth
        end,
    }
end

TestTruncateString = {}

function TestTruncateString:testShortString()
    local font = makeMockFont(10)
    local result = stringUtil.truncateStringAfterWidth("Hello", 100, font)
    luaunit.assertEquals(result, "Hello") -- fits, no ellipsis
end

function TestTruncateString:testTruncated()
    local font = makeMockFont(10)
    local result = stringUtil.truncateStringAfterWidth("HelloWorld", 50, font)
    luaunit.assertEquals(result, "He…") -- truncated to fit, including ellipsis
end

function TestTruncateString:testExactFit()
    local font = makeMockFont(10)
    local result = stringUtil.truncateStringAfterWidth("Hello", 50, font)
    luaunit.assertEquals(result, "Hello") -- exactly fits
end

os.exit(luaunit.LuaUnit.run())
