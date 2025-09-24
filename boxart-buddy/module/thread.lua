-- helper for threading
---@class Thread
local M = class({
    name = "Thread",
})

M.TASK_STATUS = {
    ok = "ok",
    fail = "fail",
}

function M:new(systemeventsubscriber, environment, logger)
    self.systemeventsubscriber = systemeventsubscriber
    self.logger = logger
    self.environment = environment
    self.threadStatusValue = {
        STARTED = 1,
        ACTIVE = 2,
        COMPLETE = 3,
        IDLE = 4,
        KILLING = 5,
        KILLED = 6,
    }
    -- comments indicate message direction from POV of main thread
    self.channelType = {
        BOOT = "boot", -- inbound
        INPUT = "input", -- outbound
        PROGRESS = "progress", -- inbound
        DEMANDED = "demanded", -- inbound
        DEMANDED_OUTBOUND = "demanded_outbound", -- outbound
        RESULT = "result", --inbound
        KILL_OUT = "kill_out", --outbound
        KILL_IN = "kill_in", --inbound
    }
    self.channels = {}
    self.threadPool = {}
    -- had to add this to debug thread not starting issues
    self.threadPoolPendingStarts = {}

    self.timers = {
        lastOrchestrationCheckInterval = 300,
        lastOrchestrationCheck = 0,
        lastCompleteCheckInterval = 800,
        lastCompleteCheck = 0,
    }

    -- when config changes push event to threads to inform them (they can decide if the want to nil out the config or not)
    self.systemeventsubscriber:subscribe("config_saved", function()
        self:informThreadsOfConfigChange()
    end)
end

function M:setThreadPoolTaskCount(threadKey, count)
    if not self.threadPool[threadKey] then
        self.logger:log("warn", "thread", "error setting task count for nil pool: " .. threadKey)
    end

    self.threadPool[threadKey].taskCount = count
end

function M:addThreadPoolTaskCount(threadKey, count)
    if not self.threadPool[threadKey] then
        self.logger:log("warn", "thread", "error setting task count for nil pool: " .. threadKey)
    end

    self.threadPool[threadKey].taskCount = self.threadPool[threadKey].taskCount + count
end

function M:getThreadPoolTaskCount(threadKey)
    if not self.threadPool[threadKey] then
        self.logger:log("warn", "thread", "error fetching task count for nil pool: " .. threadKey)
        return 0
    end

    return self.threadPool[threadKey].taskCount
end

function M:decrementThreadPoolTaskCount(threadKey)
    if not self.threadPool[threadKey] then
        self.logger:log("warn", "thread", "error decrementing task count for nil pool: " .. threadKey)
        return
    end
    -- when thread has been prematurely completed while tasks are still running (e.g cancelled)
    if
        self.threadPool[threadKey].status == self.threadStatusValue.COMPLETE
        or self.threadPool[threadKey].status == self.threadStatusValue.IDLE
        or self.threadPool[threadKey].status == self.threadStatusValue.KILLING
        or self.threadPool[threadKey].status == self.threadStatusValue.KILLED
    then
        return
    end
    if self.threadPool[threadKey].taskCount == 0 then
        error("cannot decrement task count in pool below 0: " .. threadKey)
        -- self.logger:log("warn", "thread", "cannot decrement task count in pool below 0: " .. threadKey)
        -- return
    end

    self.threadPool[threadKey].taskCount = self.threadPool[threadKey].taskCount - 1

    -- if task count is now 0 then mark as complete
    if
        self.threadPool[threadKey].taskCount == 0
        and self.threadPool[threadKey].status == self.threadStatusValue.ACTIVE
    then
        self:setThreadPoolStatus(threadKey, self.threadStatusValue.COMPLETE)
    end
end

function M:setThreadPoolStatus(threadKey, status)
    if not self.threadPool[threadKey] then
        self.logger:log("warn", "thread", "error setting status for nil pool: " .. threadKey)
        return
    end

    self.threadPool[threadKey].status = status
end

function M:ensureThreadsInPool(threadKey, quantity, options)
    options = options or {}
    if quantity == nil then
        quantity = 1
    end

    -- force state to active
    if self.threadPool[threadKey] then
        self.threadPool[threadKey].status = self.threadStatusValue.ACTIVE

        -- reset tags to silence/unsilence existing threads (ui sounds)
        if options.tags then
            self.threadPool[threadKey].tags = options.tags
        else
            self.threadPool[threadKey].tags = {}
        end
    end

    local existingThreadCount = self.threadPool[threadKey]
            and next(self.threadPool[threadKey].threads)
            and #table.keys(self.threadPool[threadKey].threads)
        or 0

    if existingThreadCount == quantity then
        return
    end

    local diff = quantity - existingThreadCount

    for i = 1, diff do
        self:addThreadToPool(threadKey, options)
    end
end

function M:addThreadToPool(threadKey, options)
    if self.environment:isThread() then
        error("cannot add threads to pool from another thread")
    end
    options = options or {}
    local worker = options.worker or "generic"
    local threadId = identifier.uuid4()

    self.logger:log("debug", "thread", string.format("Adding new thread to pool `%s` with ID: %s", threadKey, threadId))

    local thread = love.thread.newThread("worker/" .. worker .. ".lua")

    thread:start({ projectRoot = self.environment:getProjectRoot(), uuid = threadId, threadKey = threadKey })
    self.threadPoolPendingStarts[threadId] =
        { thread = thread, key = threadKey, t = love.timer and love.timer.getTime() or 0 }

    -- yield once after creating to create stagger (not really needed)
    if love.timer and love.timer.sleep then
        love.timer.sleep(0.05)
    end

    local err = thread:getError()
    if err then
        self.logger:log(
            "error",
            "thread",
            string.format("Thread '%s' (%s) immediate start error: %s", threadKey, threadId, err)
        )
    end

    if not self.threadPool[threadKey] then
        self.logger:log(
            "debug",
            "thread",
            string.format("Creating thread `%s`(%s) with options:\n%s", threadKey, threadId, pretty.string(options))
        )

        self.threadPool[threadKey] = {
            taskCount = options.taskCount or 0,
            status = self.threadStatusValue.ACTIVE,
            threads = {},
            permanent = options.permanent or false,
            sendResult = options.sendResult == nil and true or options.sendResult,
            sendProgress = options.sendProgress == nil and true or options.sendProgress,
            tags = options.tags or {},
            results = {
                fail = 0,
                ok = 0,
                error = 0,
            },
        }
    else
        self.logger:log(
            "debug",
            "thread",
            string.format(
                "Adding to existing thread pool `%s`(%s) with options:\n%s",
                threadKey,
                threadId,
                pretty.string(options)
            )
        )
        if options.taskCount then
            self.threadPool[threadKey].taskCount = self.threadPool[threadKey].taskCount + options.taskCount
        end
        if options.tags then
            self.threadPool[threadKey].tags = options.tags
        end
        self.threadPool[threadKey].status = self.threadStatusValue.ACTIVE
    end

    self.threadPool[threadKey].threads[threadId] = thread

    -- -- why is this here?
    -- if options and options.permanent then
    --     self.threadPool[threadKey].permanent = true
    -- end

    return true
end

-- Push a message into a channel
---@param threadKey string
---@param task table with a 'type' index and any other params
function M:push(threadKey, task)
    if not task.type then
        self.logger:log(
            "error",
            "thread",
            string.format("Every pushed message needs a 'type' by convention, supplied: %s", pretty.string(task))
        )
    end

    if threadKey == "orchestrator" and task.type ~= "ack" and task.type ~= "kill" then
        if task.threadKey == nil then
            error(string.format("orchestration messages need to be sent a `threadKey`. Sent: %s", pretty.string(task)))
        end
    end

    task.sendProgress = self:shouldSendProgress(threadKey)
    task.sendResult = self:shouldSendResult(threadKey)

    self:getChannel(threadKey, self.channelType.INPUT):push(task)
end

---Sends a message to the specified thread and blocks until a result is received or timeout is reached.
---@param threadKey string The identifier for the thread.
---@param task table The task to send
---@param options any uuid will demand the response on a unique channel, timeout sets a timeout after which failure will be assumed
---@return unknown
function M:demand(threadKey, task, options)
    task.demanded = true
    -- Generate a uuid if not supplied
    local uuid = options and options.uuid or identifier.uuid4()
    task.uuid = uuid

    task.sendProgress = self:shouldSendProgress(threadKey)
    task.sendResult = self:shouldSendResult(threadKey)

    self:push(threadKey, task)

    local timeout
    if options and options.timeout and type(options.timeout) == "number" then
        timeout = options.timeout
    end

    local response = self:getChannel(threadKey, self.channelType.DEMANDED, uuid):demand(timeout)
    if response and response.error then
        self.logger:log(
            "error",
            threadKey,
            string.format("Thread error during demand: %s", pretty.string(response.error))
        )
    end

    return response and response.result or nil
end

--- Send multiple demand tasks and collect all results (preserving order!)
--- NOTE: that if calling this method directly then the thread to process these tasks
--- must be set up and killed manually outside this process (_on the main thread_), or be permanent
---@param threadKey string
---@param tasks table[] Array of task tables
---@param options table? Options table (timeout applies to each demand)
---@return table[] Array of { result = ..., error = ... } for each input task
function M:demandAll(threadKey, tasks, options)
    options = options or {}
    local uuids = {}
    local timeout = options.timeout or nil
    -- Prepare each task
    for i, task in ipairs(tasks) do
        task.demanded = true
        if not task.uuid then
            task.uuid = identifier.uuid4()
        end
        uuids[i] = task.uuid
        self:push(threadKey, task)
    end
    local results = {}
    for i, uuid in ipairs(uuids) do
        local response = self:getChannel(threadKey, self.channelType.DEMANDED, uuid):demand(timeout)
        if response == nil then
            results[i] = { error = "timeout" }
        else
            results[i] = { result = response.result, error = response.error }
        end
    end
    return results
end

function M:informThreadsOfConfigChange()
    for threadKey, v in pairs(self.threadPool) do
        local task = { type = "reload_config" }
        self:getChannel(threadKey, self.channelType.INPUT):push(task)
    end
end

---Gets a channel using a consistent format
---@param threadKey any key of the thread pool
---@param type string channel constant name
---@param uuid? string
---@return unknown
function M:getChannel(threadKey, typ, uuid)
    local key = threadKey .. "_" .. typ

    if uuid then
        -- dont memoize these lookups
        return love.thread.getChannel(key .. "_" .. uuid)
    end

    -- -- memoize this lookup as it's used frequently
    -- if self.channels[key] then
    --     return self.channels[key]
    -- end

    self.channels[key] = love.thread.getChannel(key)
    return self.channels[key]
end

function M:clearChannel(threadKey, typ)
    local key = threadKey .. "_" .. typ
    love.thread.getChannel(key):clear()
end

function M:kill(threadKey, uuid, timeout)
    timeout = timeout or 1
    if not uuid or not threadKey then
        error(string.format("Missing threadkey:%s or uuid: %s", threadKey, uuid))
    end

    self.threadPool[threadKey].status = self.threadStatusValue.KILLING
    local task = { type = "kill", uuid = uuid }

    self.logger:log(
        "debug",
        "thread",
        string.format("sending thread kill instruction `%s` with task uuid: %s", threadKey, uuid)
    )

    self:getChannel(threadKey, self.channelType.KILL_OUT, uuid):push(task)

    -- local response = self:getChannel(threadKey, self.channelType.KILL_IN, uuid):demand(timeout)

    -- if not response then
    --     self.logger:log(
    --         "error",
    --         threadKey,
    --         string.format("Thread timeout after kill demand from mainthread : %s", threadKey)
    --     )
    --     return nil
    -- end
    -- if response.error then
    --     self.logger:log(
    --         "error",
    --         threadKey,
    --         string.format("Thread error during demand: %s", pretty.string(response.error))
    --     )
    -- end

    -- return response.result
end

function M:killAll()
    for threadKey, v in pairs(self.threadPool) do
        self:killThreadPool(threadKey)
    end
end

function M:killThreadPool(threadKey)
    if not self.threadPool[threadKey] then
        self.logger:log("warn", "thread", "cannot kill threads in nil pool: " .. threadKey)
    end

    for _, threadId in ipairs(table.keys(self.threadPool[threadKey].threads)) do
        self:kill(threadKey, threadId)
        self.threadPool[threadKey].threads[threadId] = nil
    end

    -- all threads have been killed
    self.logger:log("debug", "thread", "killed thread pool: " .. threadKey)
    self.threadPool[threadKey].status = self.threadStatusValue.KILLED
    self.threadPool[threadKey].taskCount = 0
end

---Increment counters on thread pool of fails and OK status returned from results
---@param threadKey string
---@param type string
function M:addResultToPool(threadKey, type)
    if type ~= "error" and type ~= self.TASK_STATUS.ok and type ~= self.TASK_STATUS.fail then
        error("type must be error/ok/fail")
    end

    if not self.threadPool[threadKey] then
        self.logger:log("warn", "thread", "cannot add result to nil pool: " .. threadKey)
    end

    self.threadPool[threadKey].results[type] = self.threadPool[threadKey].results[type] + 1
end

---Runs on every tick, processes updates from incoming threads
---@param dt any
function M:update(dt)
    --- DEBUG HUNG THREADS
    do
        if next(self.threadPoolPendingStarts) then
            local now = love.timer and love.timer.getTime() or 0

            local bootedIds = {}
            for id, p in pairs(self.threadPoolPendingStarts) do
                local boot = self:getChannel(p.key, self.channelType.BOOT):pop()
                if boot and boot.result and boot.result.threadUuid then
                    table.insert(bootedIds, boot.result.threadUuid)
                end
            end
            -- nil out all the found ids
            for _, id in ipairs(bootedIds) do
                -- thread returned a message to say it had booted
                self.threadPoolPendingStarts[id] = nil
            end

            for id, p in pairs(self.threadPoolPendingStarts) do
                if now - p.t > 3.0 then
                    self.logger:log(
                        "warn",
                        "thread",
                        string.format(
                            "thread '%s' (%s) has not ACKED starting after 3s, possibly hung on startup",
                            p.key,
                            id
                        )
                    )

                    -- leave it in the table to keep watching, or nil it if you only want a single warning
                    self.threadPoolPendingStarts[id] = nil
                end
            end
        end
    end
    --- END DEBUG HUNG THREADS

    self.timers.lastOrchestrationCheck = self.timers.lastOrchestrationCheck + (dt * 1000)
    self.timers.lastCompleteCheck = self.timers.lastCompleteCheck + (dt * 1000)

    for threadKey, v in pairs(self.threadPool) do
        if
            threadKey == "orchestrator"
            and not self.environment:isThread()
            and self.timers.lastOrchestrationCheck > self.timers.lastOrchestrationCheckInterval
        then
            self.timers.lastOrchestrationCheck = 0
            self:updateOrchestration()
        end

        if threadKey ~= "orchestrator" then
            self:updateOne(threadKey)
        end
    end
end

function M:updateOne(threadKey)
    -- set threads that have started but are not active yet to active when they have > 1 message in the channel
    if (not self.environment:isThread()) and self.threadPool[threadKey].status ~= self.threadStatusValue.ACTIVE then
        if self:getChannel(threadKey, self.channelType.INPUT):getCount() > 0 then
            self.threadPool[threadKey].status = self.threadStatusValue.ACTIVE
        end
    end

    local progress = self:getChannel(threadKey, self.channelType.PROGRESS):pop()

    if progress then
        self:decrementThreadPoolTaskCount(threadKey)
        self.systemeventsubscriber:publish("action_progress", { ["key"] = threadKey })
    end

    local result = self:getChannel(threadKey, self.channelType.RESULT):pop()

    if result then
        if result.error then
            self.logger:log("error", "thread", string.format("Thread [%s] / Error: %s", threadKey, result.error))
            self.systemeventsubscriber:publish("task_error", { threadKey = threadKey, error = result.error })
            self:addResultToPool(threadKey, "error")
        end
        -- thread results published to allow side effects like sound
        if result.result and result.result.status then
            self:addResultToPool(threadKey, result.result.status)
            self.systemeventsubscriber:publish("task_result", { threadKey = threadKey, result = result.result })
        end
        -- results can send logs, only used to allow console logging
        -- any other logging should be done in the thread directly
        if result.result and result.result.logs then
            for _, l in ipairs(result.result.logs) do
                self.logger:logToHandler(l.level, l.channel, l.message, "console")
            end
        end
    end

    -- if all processed then tear down thread and emit event to indicate complete
    if
        self.timers.lastCompleteCheck > self.timers.lastCompleteCheckInterval
        and (not self.environment:isThread())
        and self.threadPool[threadKey].status == self.threadStatusValue.COMPLETE
        -- and not self.threadPool[threadKey].permanent
    then
        self.timers.lastCompleteCheck = 0

        if self:getChannel(threadKey, self.channelType.INPUT):getCount() ~= 0 then
            error("Thread Count and Channel count mismatch. Both should be 0 but channel still has messages:")
        end

        --- look at results to determine success
        local success = true
        if self.threadPool[threadKey].results.fail > 0 or self.threadPool[threadKey].results.error > 0 then
            success = false
        end

        local threadTags = table.shallow_copy(self.threadPool[threadKey].tags)

        -- kill all in the pool
        -- self:killThreadPool(threadKey)

        self.logger:log("debug", "thread", "Thread work complete: " .. threadKey)

        self.systemeventsubscriber:publish(
            "action_complete_async",
            { ["key"] = threadKey, ["success"] = success, ["tags"] = threadTags }
        )
        self.systemeventsubscriber:publish(threadKey .. "_complete")

        --reset failure and error counts
        self.threadPool[threadKey].results.fail = 0
        self.threadPool[threadKey].results.error = 0

        -- FORCE THREAD TO IDLE, THE REPLACEMENT FOR KILLING THREADS
        self.threadPool[threadKey].status = self.threadStatusValue.IDLE
    end

    -- big hack to allow database init/replace function to trigger progress completion
    if result and result.result and result.result.forceComplete then
        local threadTags = table.shallow_copy(self.threadPool[threadKey].tags)
        self.systemeventsubscriber:publish(
            "action_complete_async",
            { ["key"] = threadKey, ["success"] = true, ["tags"] = threadTags }
        )
        self.systemeventsubscriber:publish(threadKey .. "_complete")
    end
end

-- Allows immediate dispatching of tasks to a worker (without orchestration)
function M:dispatchTasks(threadKey, tasks, options)
    options = options or {}
    local threadTags = {}
    if options.silentThread then
        threadTags.silent = true
    end
    self:ensureThreadsInPool(threadKey, 1, { tags = threadTags })
    self:addThreadPoolTaskCount(threadKey, #tasks)

    self.systemeventsubscriber:publish("tasks_dispatched", {
        threadKey = threadKey,
        steps = #tasks,
        tags = { style = options.progressStyle or "modal" },
        text = options.progressText or "processing",
    })

    for _, task in ipairs(tasks) do
        task.sendProgress = self:shouldSendProgress(threadKey)
        task.sendResult = self:shouldSendResult(threadKey)
        self:push(threadKey, task)
    end
end

-- called on the main thread side
function M:updateOrchestration()
    local result = self:getChannel("orchestrator", self.channelType.RESULT):pop()

    if result then
        self.systemeventsubscriber:publish("orchestration_result_received", result)
    end

    if result and result.error == nil and result.taskCount > 0 then
        local threadSpawnQuantity = result.threads or 1
        self:ensureThreadsInPool(result.threadKey, threadSpawnQuantity)

        self.systemeventsubscriber:publish("tasks_dispatched", {
            threadKey = result.threadKey,
            steps = result.steps or result.taskCount,
            tags = { style = "modal" },
            text = result.text or "Processing Tasks",
        })

        -- set the 'count' of jobs that this thread is going to be working on
        self:setThreadPoolTaskCount(result.threadKey, result.taskCount)

        -- send ack to the worker
        self:getChannel("orchestrator", self.channelType.DEMANDED_OUTBOUND)
            :supply({ threadCreated = true, type = "ack" })
    end

    if result and result.error then
        self.logger:log(
            "error",
            "thread",
            "Orchestrator sent an error instead of orchestrating tasks: " .. result.error
        )
        self.systemeventsubscriber:publish("orchestrator_error_received", { success = false })
    end

    local progress = self:getChannel("orchestrator", self.channelType.PROGRESS):pop()

    if progress then
        self.systemeventsubscriber:publish("action_progress", { ["key"] = "orchestrator" })
    end
end

function M:shouldSendProgress(threadKey)
    if self.threadPool[threadKey] and self.threadPool[threadKey].sendProgress == false then
        return false
    end
    -- hack, this code sucks
    if threadKey == "database" or threadKey == "file_logger" or threadKey == "scraper_download" then
        return false
    end

    return true
end

function M:shouldSendResult(threadKey)
    if self.threadPool[threadKey] and self.threadPool[threadKey].sendResult == false then
        return false
    end
    -- hack, this code sucks
    if threadKey == "database" or threadKey == "file_logger" then
        return false
    end

    return true
end

function M:shouldKillThreadWhenEmpty(threadKey)
    if self.threadPool[threadKey] and not self.threadPool[threadKey].permanent then
        return true
    end

    return false
end

---Common response handling from worker threads should go through this function to ensure consistency
---@param threadKey string
---@param task table
---@param result any
---@param err any
function M:sendResponse(threadKey, task, result, err)
    if task.sendProgress then
        self:getChannel(threadKey, self.channelType.PROGRESS):push({ ["progress"] = true })
    end
    local response = {
        result = result,
        error = err,
    }

    if task.demanded and task.uuid then
        self:getChannel(threadKey, self.channelType.DEMANDED, task.uuid):supply(response)
    end

    -- prevent clogging result channels for threads that should only send errors
    if task.sendResult or response.error then
        self:getChannel(threadKey, self.channelType.RESULT):push(response)
    end
end

---comment
---@param task table
---@param result table
---@param err any
function M:sendOrchestrationResponse(task, result, err)
    if err then
        self:getChannel("orchestrator", self.channelType.RESULT):supply({ error = err })
        return
    end

    local taskCount = #result.tasks
    if taskCount < 1 then
        -- in this case it might be OK just to return early rather than error?!
        -- error(string.format("taskCount from Orchestrator must be > 0: %s", pretty.string(result)))
    end

    local response = {
        result = "OK", -- dont send the result object as it contains loads of tasks objects
        steps = result.steps, -- this is optional but can be used to set text of progress steps (text)
        threadKey = task.threadKey,
        taskCount = taskCount, --- number of tasks
        text = result.text, -- optionally provide a name for what has been orchestrated. used in progress
        threads = result.threads or 1,
    }

    -- should I add a timeout? it should never be needed.....
    self:getChannel("orchestrator", self.channelType.RESULT):supply(response)

    -- send a progress message to allow any modal to close
    self:getChannel("orchestrator", self.channelType.PROGRESS):push({ ["progress"] = true })

    if taskCount > 0 then -- important to know that logic for taskCount < 0 needs to match on the other side of the thread
        -- waits for main thread to ack that the worker has been set up
        local ack = self:getChannel("orchestrator", self.channelType.DEMANDED_OUTBOUND):demand()

        -- sends tasks into the queue
        for i, t in ipairs(result.tasks) do
            self:push(task.threadKey, t)
        end
    end
end

---Gets the counts of all channels with > 0 messages for debug purposes
---NOTE this won't show any counts for messages sent to uuid namespaced channels
---At the time of writing this comment these are only used for killing threads
---@return table
function M:getCounts()
    local counts = {}

    for threadKey, t in pairs(self.threadPool) do
        for k2, channelType in pairs(self.channelType) do
            local count = self:getChannel(threadKey, channelType):getCount()
            if count > 0 then
                counts[threadKey .. ":" .. k2:lower()] = count
            end
        end
    end

    return counts
end

-- for debug in the console
function M:getThreadPoolsDebug()
    local pools = {}

    for threadKey, t in pairs(self.threadPool) do
        pools[threadKey] = string.format(
            "status: %s, threadCount: %s, tasks: %i, perm: %s , fail: %i, ok: %i, err: %i",
            table.key_of(self.threadStatusValue, t.status),
            type(t.threads) == "table" and #table.keys(t.threads) or 0,
            t.taskCount,
            t.permanent and "true" or "false",
            t.results.fail,
            t.results.ok,
            t.results.error
        )
    end

    return pools
end

return M
