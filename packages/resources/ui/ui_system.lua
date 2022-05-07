local json = require "json"
local json_encode = json.encode
local json_decode = json.decode

local m = {}
function m:pub(msg)
    local ud = {}
    ud.event = "__PUB"
    ud.ud = msg
    window.extern.postMessage(json_encode(ud))
end

function m:open(url, ...)
    local ud = {}
    ud.event = "__OPEN"
    ud.ud = {url, ...}
    window.extern.postMessage(json_encode(ud))
end

function m:close()
    local ud = {}
    ud.event = "__CLOSE"
    window.extern.postMessage(json_encode(ud))
end

function m:addDataListener(event_type, callback, ...)
    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is nil")
            return
        end
        local res, err = json_decode(event.data)
        if res then
            if res.event == "__DATALISTENER" and res.ud[1] == event_type then
                callback(table.unpack(res.ud, 2))
            end
            return
        end
        error(('%s'):format(err))
    end)

    local ud = {}
    ud.event = "__DATALISTENER"
    ud.ud = {event_type, ...}
    window.extern.postMessage(json_encode(ud))
end

function m:addEventListener(event_funcs)
    window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is nil")
            return
        end
        local res, err = json_decode(event.data)
        if res then
            local func = event_funcs[res.event]
            if not func then
                return
            end
            func(table.unpack(res.ud))
            return
        end
        error(('%s'):format(err))
    end)
end

return m