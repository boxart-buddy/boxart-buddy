---@class SqliteDB
---@field prepare fun(self: SqliteDB, sql: string): SqliteStmt|nil, string
---@field exec fun(self: SqliteDB, sql: string): boolean|nil, string
---@field errmsg fun(self: SqliteDB): string
---@field changes fun(self: SqliteDB): integer
---@field close fun(self: SqliteDB)
---@field trace fun(self: SqliteDB, callback: fun(sql: string): nil)

---@class SqliteStmt
---@field step fun(self: SqliteStmt): integer
---@field finalize fun(self: SqliteStmt)
---@field reset fun(self: SqliteStmt)
---@field bind_names fun(self: SqliteStmt, params: table): integer
---@field get_named_values fun(self: SqliteStmt): table
local lsqlite3 = require("lsqlite3complete")

local socket = require("socket")
local filesystem = require("lib.nativefs")
local stringUtil = require("util.string")

---@class Database
---@field returnCodes table
local M = class({
    name = "Database",
    defaults = {
        ["returnCodes"] = {
            ["OK"] = 0,
            ["ERROR"] = 1,
            ["INTERNAL"] = 2,
            ["PERM"] = 3,
            ["ABORT"] = 4,
            ["BUSY"] = 5,
            ["LOCKED"] = 6,
            ["NOMEM"] = 7,
            ["READONLY"] = 8,
            ["INTERRUPT"] = 9,
            ["IOERR"] = 10,
            ["CORRUPT"] = 11,
            ["NOTFOUND"] = 12,
            ["FULL"] = 13,
            ["CANTOPEN"] = 14,
            ["PROTOCOL"] = 15,
            ["EMPTY"] = 16,
            ["SCHEMA"] = 17,
            ["TOOBIG"] = 18,
            ["CONSTRAINT"] = 19,
            ["MISMATCH"] = 20,
            ["MISUSE"] = 21,
            ["NOLFS"] = 22,
            ["FORMAT"] = 24,
            ["RANGE"] = 25,
            ["NOTADB"] = 26,
            ["ROW"] = 100,
            ["DONE"] = 101,
        },
    },
})

---@private
---@param environment table
---@param logger table
---@param thread table
function M:new(environment, logger, thread)
    self.logger = logger
    self.environment = environment
    self.thread = thread

    self.dbpath = environment:getPath("db")
end

function M:isInitialized()
    ---- Check this 10 times at 100ms intervals
    local initializedPath = self.environment:getPath("initialized_db")
    for i = 1, 10 do
        if filesystem.getInfo(initializedPath) then
            return true
        end
        socket.sleep(0.1)
    end

    return false
end
function M:initialize()
    if self:isInitialized() then
        return
    end

    -- assume we are creating everything and blow up if anything is already created
    if filesystem.getInfo(self.environment:getPath("db")) then
        error("database already exists")
    end

    self:replaceDBFromFixture()

    filesystem.write(self.environment:getPath("initialized_db"), "")
end

--- Replaces the database file with a fresh copy from the fixture.
function M:replaceDBFromFixture()
    local dbPath = self.environment:getPath("db")
    local dbDirPath = self.environment:getPath("db_dir")
    local dbFixturePath = self.environment:getPath("db_initial")

    -- delete database if it exists
    if filesystem.getInfo(dbPath) ~= nil then
        self:close()
        filesystem.remove(dbPath)
        -- ensure WAL/SHM are gone before copying a fresh DB over
        local wal = dbPath .. "-wal"
        local shm = dbPath .. "-shm"
        if filesystem.getInfo(wal) then
            filesystem.remove(wal)
        end
        if filesystem.getInfo(shm) then
            filesystem.remove(shm)
        end
    end

    if filesystem.getInfo(dbPath) == nil then
        if not filesystem.getInfo(dbDirPath) then
            filesystem.createDirectory(dbDirPath)
        end

        local cmd = string.format("cp %s %s", stringUtil.shellQuote(dbFixturePath), stringUtil.shellQuote(dbPath))
        os.execute(cmd)
    end

    if filesystem.getInfo(dbPath) == nil then
        self.logger("error", "db", "could not create database at path: " .. dbPath)
        error("No DB Exists after attempted creation, something went wrong")
    end

    self.logger:log("info", "db", "Created blank database from fixture: " .. dbFixturePath)
end

--- Returns an open SQLite DB connection, opening it if necessary.
---@private
---@return SqliteDB
function M:_db()
    if self.db == nil then
        self.db = self:_open()
        self.db:exec("PRAGMA journal_mode=WAL")
        self.db:exec("PRAGMA wal_checkpoint(FULL)")
        self.db:exec("PRAGMA foreign_keys = ON")
        self.db:exec("PRAGMA auto_vacuum = FULL")
    end

    return self.db
end

--- Opens a new SQLite database connection.
---@private
---@return SqliteDB
function M:_open()
    local db, errorCode, errorMessage = lsqlite3.open(self.environment:getPath("db"))

    if db then
        -- Database opened successfully
        -- You can now interact with the database
        return db
    else
        -- Handle the error
        self.logger:log("error", "db", "Could not open database: ERROR CODE " .. errorCode)
        error(errorMessage)
    end
end

--- Sends an exec command to the DB thread.
---@param statement string
---@param parameters table|nil
function M:asyncExec(statement, parameters)
    self.thread:push("database", { type = "exec", statement = statement, parameters = parameters })
end

--- Sends an exec command to the DB thread and waits for the result.
---@param statement string
---@param parameters table|nil
---@param timeout number|nil
---@return any
function M:blockingExec(statement, parameters, timeout)
    return self.thread:demand("database", { type = "exec", statement = statement, parameters = parameters }, timeout)
end

--- Executes a non-SELECT SQL statement (e.g., INSERT, UPDATE, DELETE)
--- Should not be used directly, use "blockingExec" or "asyncExec" for threaded db access
--- @param statement string SQL statement string with optional named parameters
--- @param parameters? table table of named parameters to bind (optional)
--- @return integer #of rows affected
function M:exec(statement, parameters)
    -- if not self.environment.isThread() then
    --     error("Can only call exec statements via a thread")
    -- end

    if type(parameters) == "boolean" then
        error("invalid parameters, must be table or nil, boolean passed with statement " .. statement)
    end

    local db = self:_db()

    local prepared, err = db:prepare(statement)
    if not prepared then
        error(
            string.format(
                "Error preparing statement, code(%s): %s\nstatement:%s \nparams: %s \n",
                err,
                db:errmsg(),
                statement,
                pretty.string(parameters)
            )
        )
    end

    if parameters then
        local bindResult = prepared:bind_names(parameters)
        if bindResult ~= self.returnCodes.OK then
            self.logger:log(
                "error",
                "db",
                string.format("error `%s` binding parameters for `%s`", bindResult, statement)
            )
        end
    end

    if DEBUG_LEVEL > 1 then
        self.logger:log("debug", "db", string.format("executing: `%s`", pretty.string(parameters)))
    end

    local stepResult
    local attempts = 0
    local maxAttempts = 5

    repeat
        stepResult = prepared:step()

        if stepResult == self.returnCodes.BUSY then
            attempts = attempts + 1
            self.logger:log("warn", "db", string.format("Database is busy. Retry attempt %d", attempts))
            socket.sleep(0.05)
        else
            break
        end
    until attempts >= maxAttempts

    if stepResult == self.returnCodes.BUSY then
        self.logger:log("error", "db", "Max retry attempts reached; SQLite still busy.")
        prepared:reset()
        prepared:finalize()
        return 0
    end

    if stepResult == self.returnCodes.ERROR or stepResult == self.returnCodes.MISUSE then
        self.logger:log(
            "error",
            "db",
            string.format("Generic error `%s` executing statement `%s`", stepResult, statement)
        )
    end

    if stepResult == self.returnCodes.LOCKED then
        self.logger:log("error", "db", string.format("Database is locked. Statement: `%s`", statement))
    end

    if stepResult == self.returnCodes.NOMEM then
        self.logger:log("error", "db", string.format("Database is OOM. Statement: `%s`", statement))
    end

    if stepResult == self.returnCodes.CORRUPT or stepResult == self.returnCodes.NOTADB then
        self.logger:log("fatal", "db", string.format("Database is Corrupt. Statement: `%s`", statement))
    end

    if stepResult == self.returnCodes.FULL then
        self.logger:log("fatal", "db", "Database write failed. The disk is full")
    end

    if stepResult == self.returnCodes.READONLY then
        self.logger:log("fatal", "db", "Database is in read only mode. Check permissions!")
    end

    if stepResult == self.returnCodes.CONSTRAINT then
        local prettyParams = pretty.string(parameters or {}, { ["indent"] = "", ["per_line"] = 30 })
        self.logger:log("error", "db", string.format("Constraint error: `%s`, `%s`", prettyParams, db:errmsg()))
    end
    prepared:reset()
    prepared:finalize()

    return db:changes()
end

--- Sends a SELECT command to the DB thread.
---@param statement string
---@param parameters table|nil
function M:asyncSelect(statement, parameters)
    self.thread:push("database", { type = "select", statement = statement, parameters = parameters })
end

--- Sends a SELECT command to the DB thread and waits for the result.
---@param statement string
---@param parameters? table
---@param timeout? number
---@return table[]
function M:blockingSelect(statement, parameters, timeout)
    return self.thread:demand("database", { type = "select", statement = statement, parameters = parameters }, timeout)
end

--- Executes a SELECT statement directly on the DB thread.
---@param statement string
---@param parameters? table
---@return table[]
function M:select(statement, parameters)
    if not self.environment.isThread() then
        error("Can only call exec statements via a thread")
    end
    local db = self:_db()
    local prepared, err = db:prepare(statement)
    if not prepared then
        error(
            string.format(
                "Error preparing statement, code(%s): %s\nstatement:%s \nparams: %s \n",
                err,
                db:errmsg(),
                statement,
                pretty.string(parameters)
            )
        )
    end

    if parameters then
        local bindResult = prepared:bind_names(parameters)
        if bindResult ~= self.returnCodes.OK then
            self.logger:log("error", "db", string.format("Failed to bind parameters: %s", bindResult))
        end
    end

    local results = {}
    local attempts = 0
    local maxAttempts = 5

    while true do
        local stepResult = prepared:step()

        if stepResult == self.returnCodes.ROW then
            local row = {}
            for k, v in pairs(prepared:get_named_values()) do
                row[k] = v
            end
            table.insert(results, row)
        elseif stepResult == self.returnCodes.DONE then
            break
        elseif stepResult == self.returnCodes.BUSY then
            attempts = attempts + 1
            self.logger:log("warn", "db", string.format("Database is busy. Retry attempt %d", attempts))
            if attempts >= maxAttempts then
                self.logger:log("error", "db", "Too many retries; giving up on SELECT")
                break
            end
            socket.sleep(0.05)
        else
            if stepResult == self.returnCodes.ERROR or stepResult == self.returnCodes.MISUSE then
                self.logger:log(
                    "error",
                    "db",
                    string.format("Generic error `%s` executing statement `%s`", stepResult, statement)
                )
            elseif stepResult == self.returnCodes.LOCKED then
                self.logger:log("error", "db", string.format("Database is locked. Statement: `%s`", statement))
            elseif stepResult == self.returnCodes.NOMEM then
                self.logger:log("error", "db", string.format("Database is OOM. Statement: `%s`", statement))
            elseif stepResult == self.returnCodes.CORRUPT or stepResult == self.returnCodes.NOTADB then
                self.logger:log("fatal", "db", string.format("Database is Corrupt. Statement: `%s`", statement))
            elseif stepResult == self.returnCodes.FULL then
                self.logger:log("fatal", "db", "Database read failed. The disk is full")
            elseif stepResult == self.returnCodes.READONLY then
                self.logger:log("fatal", "db", "Database is in read-only mode. Check permissions!")
            end
            break
        end
    end

    prepared:finalize()
    return results
end

function M:beginTransaction()
    self:exec("BEGIN")
end

function M:commitTransaction()
    self:exec("COMMIT")
end

function M:close()
    local db = self.db
    if not db then
        return
    end

    -- Flush WAL, then switch to DELETE so SQLite can drop -wal/-shm
    pcall(function()
        db:exec("PRAGMA wal_checkpoint(TRUNCATE)")
    end)
    pcall(function()
        db:exec("PRAGMA journal_mode=DELETE")
    end)

    db:close()
    self.db = nil

    -- Clean up any lingering sidecar files from WAL mode
    local dbPath = self.environment:getPath("db")
    local wal = dbPath .. "-wal"
    local shm = dbPath .. "-shm"
    if filesystem.getInfo(wal) then
        filesystem.remove(wal)
    end
    if filesystem.getInfo(shm) then
        filesystem.remove(shm)
    end
end

return M
