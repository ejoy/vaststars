local ecs = ...
local world = ecs.world

local irmlui = ecs.import.interface "ant.rmlui|irmlui"
local json = import_package "ant.json"
local json_encode = json.encode
local json_decode = json.decode

local rmlui_message_mb = world:sub {"rmlui_message"}
local rmlui_message_close_mb = world:sub {"rmlui_message_close"}
local ui_message_mb = world:sub {"ui_message"}
local windows = {} -- = {[url] = { w = xx, data_listener = {}, }, ...}

local function open(url, ...)
    local wd = windows[url]
    if wd then
        local init = {...}
        if #init > 0 then
            local ud = {}
            ud.event = "INIT"
            ud.ud = init
            wd.w.postMessage(json_encode(ud))
        end
        return
    end

    assert(type(url) == "string")
    wd = {data_listener = {}}
    wd.w = irmlui.open(url)
    wd.w.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is null")
            return
        end

        local res, err = json_decode(event.data)
        if not res then
            error(("%s"):format(err))
            return
        end

        if res.event == "__CLOSE" then
            world:pub {"rmlui_message_close", url}
        elseif res.event == "__OPEN" then
            world:pub {"rmlui_message", res.event, table.unpack(res.ud)}
        elseif res.event == "__DATALISTENER" then
            assert(res.ud[1])
            wd.data_listener[res.ud[1]] = {table.unpack(res.ud, 2)}
        else
            world:pub {"rmlui_message", res.event, res.ud}
        end
    end)

    local init = {...}
    if #init > 0 then
        local ud = {}
        ud.event = "INIT"
        ud.ud = init
        wd.w.postMessage(json_encode(ud))
    end
    windows[url] = wd
end

local function pub(msg)
    world:pub(msg)
end

local function close(url)
    local w = windows[url]
    if not w then
        return
    end
    w:close()
    windows[url] = nil
end

local ui_events = {
    __OPEN = open,
    __PUB = pub,
    -- __CLOSE = close,
}

local ui_system = ecs.system 'ui_system'
function ui_system.ui_update()
    local event, func

    for _, url in rmlui_message_close_mb:unpack() do
        local wd = windows[url]
        if not wd then
            log.warn(("can not found window `%s`"):format(url))
        else
            wd.w:close()
            windows[url] = nil
        end
    end

    -- rmlui to world
    for msg in rmlui_message_mb:each() do
        event = msg[2]
        func = assert(ui_events[event], ("Can not found event `%s`"):format(event))
        func(table.unpack(msg, 3, #msg))
    end

    -- world to rmlui
    for msg in ui_message_mb:each() do
        for _, wd in pairs(windows) do
            local ud = {}
            ud.event = msg[2]
            ud.ud = {table.unpack(msg, 3, #msg)}
            wd.w.postMessage(json_encode(ud))
        end
    end
end

local iui = ecs.interface "iui"
function iui.open(url, ...)
    world:pub {"rmlui_message", "__OPEN", url, ...}
end

function iui.close(url)
    world:pub {"rmlui_message", "__CLOSE", url}
end

function iui.on_data_changed(event, ...)
    for _, wd in pairs(windows) do
        for ev, param in pairs(wd.data_listener) do -- TODO
            if ev == event then
                local ud = {}
                ud.event = "__DATALISTENER"
                ud.ud = {event, ...}
                wd.w.postMessage(json_encode(ud))
            end
        end
    end
end