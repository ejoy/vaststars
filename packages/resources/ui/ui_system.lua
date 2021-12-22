local json = require "json"
local json_encode = json.encode
local json_decode = json.decode

local m = {}
function m.postMessage(url, event, ...)
    local ud = {}
    ud.url = url
    ud.event = event
    ud.ud = {...}

    if url:sub(1, 1) == "@" then -- todo 貌似没有内部发消息的需求??
        ud.url = url:sub(2)
        window.postMessage(json_encode(ud))
    else
        window.extern.postMessage(json_encode(ud))
    end
end

function m.pub(...)
    local ud = {}
    ud.url = ""
    ud.event = "__pub"
    ud.ud = {...}
    window.extern.postMessage(json_encode(ud))
end

function m.open(url)
    local ud = {}
    ud.url = url
    ud.event = "__open"
    ud.ud = {}
    window.extern.postMessage(json_encode(ud))
    m.postMessage(url, "__get_data")
end

function m.close(url)
    local ud = {}
    ud.url = url
    ud.event = "__close"
    ud.ud = {}

    window.extern.postMessage(json_encode(ud))
end

do
    local event_funcs = {} -- = {[event][url] = func, ...}
    function m.addEventListener(url, funcs)
        for event, func in pairs(funcs) do
            event_funcs[event] = event_funcs[event] or {}
            event_funcs[event][url] = func
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
                -- console.log(("can not found event(%s)"):format(res.event))
                return
            end

            local func = event_funcs[res.event][res.url]
            if not func then
                console.log(("can not found func | event(%s) url(%s)"):format(res.event, res.url))
                return
            end
            func(table.unpack(res.ud))
            return
        end
        error(('%s'):format(err))
    end)
end

return m