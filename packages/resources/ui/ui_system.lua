local json = require "json"
local json_encode = json.encode
local json_decode = json.decode

local m = {}
function m.pub(...)
    local ud = {}
    ud.event = "__PUB"
    ud.ud = {...}
    window.extern.postMessage(json_encode(ud))
end

function m.open(url, ...)
    local ud = {}
    ud.event = "__OPEN"
    ud.ud = {url, ...}
    window.extern.postMessage(json_encode(ud))
end

function m.close()
    local ud = {}
    ud.event = "__CLOSE"
    window.extern.postMessage(json_encode(ud))
end

do
    function m.addEventListener(event_funcs)
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
end

return m