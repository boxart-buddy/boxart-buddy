-- Setup & Boot Container
local args = ...
local THREAD = {
    key = args.threadKey,
    uuid = args.uuid,
}

local bootstrap = require("bootstrap")({ ["projectRoot"] = args.projectRoot, ["thread"] = true })
local DIC = bootstrap:getDIC()
local thread = DIC.thread

-- ack boot to main thread
thread:getChannel(THREAD.key, thread.channelType.BOOT):push({ result = { threadUuid = THREAD.uuid } })

while true do
    local handler = require("worker.handler." .. THREAD.key)(DIC)
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
        handler:postKill()
        break
    end

    local task = thread:getChannel(THREAD.key, thread.channelType.INPUT):demand(0.1)

    if task then
        if task.type == "reload_config" then
            -- nulling config forces reload from disk on next attempted 'get'
            DIC.configManager.config = nil
        else
            if THREAD.key ~= "database" and THREAD.key ~= "file_logger" then
                DIC.logger:log(
                    "debug",
                    "worker",
                    string.format(
                        "handling task (%s, %s):\n%s",
                        THREAD.key,
                        THREAD.uuid,
                        pretty.string(task, { depth = 4 })
                    )
                )
            end
            local status, result = handler:handle(task)

            local err
            if status == false then
                err = result
                result = "ERROR"
            end

            if THREAD.key ~= "database" and THREAD.key ~= "file_logger" then
                DIC.logger:log(
                    "debug",
                    "worker",
                    string.format(
                        "sending result for task (%s, %s):\nresult: %s,\nerr: %s",
                        THREAD.key,
                        THREAD.uuid,
                        pretty.string(result, { depth = 4 }),
                        err
                    )
                )
            end

            thread:sendResponse(THREAD.key, task, result, err)
        end
    end

    DIC.logger:update()
end
