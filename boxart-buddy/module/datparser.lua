---@class DatParser
local M = class({
    name = "DatParser",
})

function M:new(logger)
    self.logger = logger
end

-- Lexer: turns string into a stream of tokens
function M:_datLexer(content)
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local lineNo = 1
    return function()
        while lineNo <= #lines do
            local line = lines[lineNo]:match("^%s*(.*)") -- trim leading space
            if line == "" then
                lineNo = lineNo + 1
            else
                local tok
                if line:match("^%(") or line:match("^%)") then
                    tok = line:sub(1, 1)
                    lines[lineNo] = line:sub(2)
                elseif line:match('^"') then
                    tok = line:match('^"([^"]*)"')
                    lines[lineNo] = line:sub(#tok + 3) -- remove quotes
                else
                    tok = line:match("^(%S+)")
                    lines[lineNo] = line:sub(#tok + 1)
                end
                --self.logger:log("debug", "datparser", string.format("Lexer line %d token: [%s]", lineNo, tok))
                return tok
            end
        end
        return nil
    end
end

-- Parses a table block like: key ( ... )
function M:_parseTable(lexer)
    local res, state, key = {}, "key", nil
    for tok in lexer do
        if state == "key" then
            if tok == ")" then
                return res
            end
            if tok == "(" then
                error("Unexpected '(' instead of key")
            end
            key = tok
            state = "value"
        else
            if tok == "(" then
                res[key] = self:_parseTable(lexer)
            elseif tok == ")" then
                error("Unexpected ')' instead of value")
            else
                res[key] = tok
            end
            state = "key"
        end
    end
    error("Missing ')' for '('")
end

-- Parses top-level structure: game (...) game (...)
function M:_parseDat(lexer)
    local res, state, skip = {}, "key", true
    for tok in lexer do
        if state == "key" then
            skip = tok ~= "game"
            state = "value"
        else
            if tok == "(" then
                local v = M:_parseTable(lexer)
                if not skip then
                    table.insert(res, v)
                    skip = true
                end
            else
                error("Expected '(', found " .. tok)
            end
            state = "key"
        end
    end
    return res
end

-- Main parser entry point
function M:parse(datString)
    local games = {}
    local rawGames = self:_parseDat(self:_datLexer(datString))
    for _, g in ipairs(rawGames) do
        local game = {
            id = g.id,
            name = g.name,
            description = g.description,
            year = g.year,
            manufacturer = g.manufacturer,
            genre = g.genre,
            serial = g.serial,
            rom = g.rom and {
                name = g.rom.name,
                size = tonumber(g.rom.size),
                crc = g.rom.crc,
                md5 = g.rom.md5,
                sha1 = g.rom.sha1,
                serial = g.rom.serial,
            } or nil,
        }
        table.insert(games, game)
    end
    return games
end

return M
