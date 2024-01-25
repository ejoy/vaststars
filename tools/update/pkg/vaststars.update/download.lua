local ltask = require "ltask"
local httpc = require "httpc"
local session = httpc.session "ephemeral"

local Tasks = {}

ltask.fork(function ()
    while true do
        for _, msg in ipairs(httpc.select(session)) do
            if msg.type == "completion" then
                local task = Tasks[msg.id]
                print("`" .. task.url .. "` completion. code="..msg.code..".")
                Tasks[msg.id] = nil
                ltask.wakeup(task, msg.code, msg.content)
            elseif msg.type == "progress" then
                local task = Tasks[msg.id]
                if msg.total then
                    print(("`%s` %d/%d."):format(task.url, msg.n, msg.total))
                else
                    print(("`%s` %d."):format(task.url, msg.n))
                end
            elseif msg.type == "response" then
                local task = Tasks[msg.id]
                print(("`%s` response: %s."):format(task.url, msg.data))
            elseif msg.type == "error" then
                local task = Tasks[msg.id]
                print(("`%s` error: %s."):format(task.url, msg.errmsg))
                ltask.wakeup(task)
            end
        end
        ltask.sleep(10)
    end
end)

return function (url, file)
    print(("`%s` start."):format(url))
    local id = httpc.download(session, url, file)
    local task = {
        type = "download",
        url = url,
        file = file,
    }
    Tasks[id] = task
    return ltask.wait(task)
end
