local ecs = ...
local world = ecs.world

local irmlui = ecs.import.interface "ant.rmlui|irmlui"

local json = import_package "ant.json"
local json_encode = json.encode
local json_decode = json.decode

local ui_receiver_mb = world:sub {"ui_receiver"}
local ui_receiver_open_mb = world:sub {"ui_receiver_open"}
local ui_receiver_close_mb = world:sub {"ui_receiver_close"}

local windows = {}

local function post_message(url, event, ...)
    local w = windows[url]
    if not w then
        error(("Can not found window (%s)"):format(url))
        return
    end

    local ud = {}
    ud.url = url
    ud.event = event
    ud.ud = {...}
    w.postMessage(json_encode(ud))
end

local function open(url)
    if not windows[url] then
        local w = irmlui.open(url)
        w.addEventListener("message", function(event)
            if not event.data then
                console.log("event data is null")
                return
            end

            local res, err = json_decode(event.data)
            if not res then
                error(("%s"):format(err))
                return
            end

            -- rmlui to world
            if res.event == "__open"then
                world:pub {"ui_receiver_open", res.url, "__open", table.unpack(res.ud)}
            elseif res.event == "__close" then
                world:pub {"ui_receiver_close", res.url, "__close", table.unpack(res.ud)}
            elseif res.event == "__set_data" then
                world:pub {"ui_receiver_datasource", res.url, "__set_data", table.unpack(res.ud)}
            else
                world:pub {"ui_receiver", res.url, res.event, table.unpack(res.ud)}
            end
        end)
        windows[url] = w
    end
    post_message(url, "__get_data")
end

local function close(url)
    local w = windows[url]
    if not w then
        return
    end

    w:close()
    windows[url] = nil
end

local ui_system = ecs.system 'ui_system'
function ui_system.data_changed()
    -- recv rmlui message
    for msg in ui_receiver_mb:each() do
        local url, event = msg[2], msg[3]
        world:pub {"ui", url, event, table.unpack(msg, 4, #msg)}
    end

    for _, url in ui_receiver_open_mb:unpack() do
        open(url)
    end

    for _, url in ui_receiver_close_mb:unpack() do
        close(url)
    end
end

local iui = ecs.interface "iui"
function iui.open(url, ...)
    open(url)
end

function iui.close(url)
    close(url)
end

function iui.post(url, event, ...)
    post_message(url, event, ...)
end
