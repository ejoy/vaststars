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
    function m.addEventListener(data_model, bind_data, event_funcs)
        local t = {}
        for _, v in ipairs(bind_data) do
            t[v] = true
        end

        assert(event_funcs["SET_DATA"] == nil)
        event_funcs["SET_DATA"] = function(data)
            for k, v in pairs(data) do
                if t[k] then
                    data_model[k] = v
                    data_model(k)
                end
            end
        end

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