-- Setup & Boot Container
local args = ...
local THREAD = {
    key = args.threadKey,
    uuid = args.uuid,
}
local bootstrap = require("bootstrap")({ ["projectRoot"] = args.projectRoot, ["thread"] = true })
local DIC = bootstrap:getDIC()
local thread = DIC.thread
local orchestrator = require("module.orchestrator")(DIC)

-- ack boot to main thread
thread:getChannel(THREAD.key, thread.channelType.BOOT):push({ result = { threadUuid = THREAD.uuid } })

-- 1) Block until we receive our task instructions (yields until something’s pushed)
while true do
    local killTask = thread:getChannel(THREAD.key, thread.channelType.KILL_OUT, THREAD.uuid):pop()
    if killTask then
        DIC.logger:log(
            "debug",
            "worker",
            string.format(
                "handling kill task (threadKey: %s, threadUuid: %s):\n%s",
                THREAD.key,
                THREAD.uuid,
                pretty.string(killTask, { depth = 4 })
            )
        )
        DIC.logger:update()
        thread
            :getChannel(THREAD.key, thread.channelType.KILL_IN, THREAD.uuid)
            :supply({ result = { threadUuid = THREAD.uuid } })
        break
    end

    local task = thread:getChannel("orchestrator", thread.channelType.INPUT):demand(0.1)
    if task then
        task.parameters = task.parameters or {}

        if task.type == "reload_config" then
            -- nulling config forces reload from disk on next attempted 'get'
            DIC.configManager.config = nil
        elseif task.type == nil or task.threadKey == nil then
            error(
                string.format(
                    "task send to orchestrator needs `type` and `threadKey`. Was sent: %s",
                    pretty.string(task)
                )
            )
        else
            DIC.logger:log(
                "debug",
                "worker",
                string.format(
                    "handling orchestration task (%s, %s):\n%s",
                    THREAD.key,
                    THREAD.uuid,
                    pretty.string(task, { depth = 4 })
                )
            )
            DIC.logger:update()
            local status, result = pcall(function()
                return orchestrator:orchestrate(task.type, task.parameters)
            end)

            local err
            if status == false then
                err = result
            end

            if err == nil then
                -- validate response has required fields from orchestration
                if result.tasks == nil then
                    error(
                        string.format(
                            "Orchestrator must return a table of tasks (result.tasks): %s",
                            pretty.string(result)
                        )
                    )
                end
            end
            thread:sendOrchestrationResponse(task, result, err)
        end
    end
    DIC.logger:update()
end
