local json = require "json"
local json_encode = json.encode
local json_decode = json.decode

local m = {}
function m.post(id, event, ...)
    local t = {}
    t.id = id
    t.event = event
    t.ud = {...}
    window.extern.postMessage(json_encode(t))
end

function m.add_event_listener(id, funcs)
    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is null")
            return
        end
        local res, err = json_decode(event.data)
        if res then
            if res.id ~= id then
                return
            end

            local func = funcs[res.event]
            if not func then
                console.log(string.format("can not found ui event(%s)", res.event))
                return
            end
            func(table.unpack(res.ud))
            return
        end
        error(('%s'):format(err))
    end)
end

return m