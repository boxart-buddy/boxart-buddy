local socket = require("socket")

-- Setup & Boot Container
local args = ...
local THREAD = {
    key = args.threadKey,
    uuid = args.uuid,
}
local bootstrap = require("bootstrap")({ ["projectRoot"] = args.projectRoot, ["thread"] = true })
local DIC = bootstrap:getDIC()
local thread = DIC.thread

local database = DIC.database

-- ack boot to main thread
thread:getChannel(THREAD.key, thread.channelType.BOOT):push({ result = { threadUuid = THREAD.uuid } })

local commitSize = 5000
local commitInterval = 500
local executed = 0
local lastCommitTime = 0
local commitCooldown = 2000 -- commits if nothing sent/processed in this amount of time

-- 1) Block until we receive our task instructions (yields until something’s pushed)
while true do
    local now = socket.gettime() * 1000

    if lastCommitTime == 0 then
        lastCommitTime = now
    end

    local killTask = thread:getChannel(THREAD.key, thread.channelType.KILL_OUT, THREAD.uuid):pop()
    if killTask then
        thread
            :getChannel(THREAD.key, thread.channelType.KILL_IN, THREAD.uuid)
            :supply({ result = { threadUuid = THREAD.uuid } })
        database:commitTransaction() -- If one is open
        database:close()
        break
    end

    local task = thread:getChannel("database", thread.channelType.INPUT):demand(0.1)

    if task then
        task.parameters = task.parameters or {}

        if task.type == "exec" and executed == 0 then
            database:beginTransaction()
        end

        if task.type == "reload_config" then
            -- nulling config forces reload from disk on next attempted 'get'
            DIC.configManager.config = nil
        end

        -- INIT/REPLACE DB
        if task.type == "initialize" or task.type == "replace" then
            task.sendProgress = true
            task.sendResult = true

            local status, result = pcall(function()
                if task.type == "initialize" then
                    return database:initialize()
                end

                if task.type == "replace" then
                    database:replaceDBFromFixture()
                end
            end)

            local err
            if status == false then
                err = result
                result = "ERROR"
            end

            thread:sendResponse("database", task, result, err)
        end

        -- EXEC / SELECT
        if task.type == "exec" or task.type == "select" then
            local status, result = pcall(function()
                if task.type == "exec" then
                    return database:exec(task.statement, task.parameters)
                else
                    return database:select(task.statement, task.parameters)
                end
            end)

            if task.type == "exec" then
                executed = executed + 1
            end

            if task.type == "exec" and (executed >= commitSize or ((now - lastCommitTime) >= commitInterval)) then
                database:commitTransaction()
                executed = 0
                lastCommitTime = now
            end

            local err
            if status == false then
                err = result
                result = "ERROR"
            end

            thread:sendResponse("database", task, result, err)
        end
    else
        if executed > 0 and ((now - lastCommitTime) >= commitCooldown) then
            database:commitTransaction()
            executed = 0
            lastCommitTime = now
        end
    end

    DIC.logger:update()
end
