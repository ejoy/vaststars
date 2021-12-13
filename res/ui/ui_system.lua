local json = require "json"
local json_encode = json.encode
local json_decode = json.decode

local m = {}
function m.post(id, event, ...)
    local internal
    if id:sub(1, 1) == "@" then
        internal = true
        id = id:sub(2)
    else
        internal = false
    end

    local t = {}
    t.id = id
    t.event = event
    t.ud = {...}

    if internal then
        window.postMessage(json_encode(t))
    else
        window.extern.postMessage(json_encode(t))
    end
end

do
    local event_funcs = {} -- = {[event][id] = func, ...}
    function m.add_event_listener(id, funcs)
        for event, func in pairs(funcs) do
            event_funcs[event] = event_funcs[event] or {}
            event_funcs[event][id] = func
        end
    end

    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is null")
            return
        end
        local res, err = json_decode(event.data)
        if res then
            if not event_funcs[res.event] then
                return
            end

            local func = event_funcs[res.event][res.id]
            if not func then
                console.log(("can not found func | event(%s) id(%s)"):format(res.event, res.id))
                return
            end
            func(table.unpack(res.ud))
            return
        end
        error(('%s'):format(err))
    end)
end

return m