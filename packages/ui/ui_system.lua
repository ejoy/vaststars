local ecs = ...
local world = ecs.world

local irmlui = ecs.import.interface "ant.rmlui|irmlui"

local json = import_package "ant.json"
local json_encode = json.encode
local json_decode = json.decode

local ui_system_open_mb = world:sub {"ui_system", "open"}
local ui_system_close_mb = world:sub {"ui_system", "close"}

local ui_receiver_mb = world:sub {"ui_receiver"}
local windows = {}

local ui_system = ecs.system 'ui_system'
function ui_system.data_changed()
    for _, window, ud in ui_receiver_mb:unpack() do
        window.postMessage(json_encode(ud))
    end

    for msg in ui_system_open_mb:each() do
        local id, url = msg[3], msg[4]
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

            if res.id:sub(1, 1) == "#" then
                res.id = res.id:sub(2)
                local w = windows[res.id]
                if not w then
                    error(("can nof found id(%s)"):format(res.id))
                end

                w.postMessage(json_encode(res))
            else
                -- rmlui -> world
                world:pub {"ui", res.id, res.event, table.unpack(res.ud)}
            end
        end)

        windows[id] = w

        if msg[5] then
            local ud = {}
            ud.id = id
            ud.event = "init"
            ud.ud = {table.unpack(msg, 5, #msg)}
            world:pub {"ui_receiver", w, ud} -- world -> rmlui
        end
    end

    for _, _, id in ui_system_close_mb:unpack() do
        local window = windows[id]
        if not window then
            error("Can not found window")
        end

        window:close()
    end
end

local iui = ecs.interface "iui"
function iui.open(id, url, ...)
    world:pub {"ui_system", "open", id, url, ...}
end

function iui.close(id)
    world:pub {"ui_system", "close", id}
end

function iui.post(id, event, ...)
    local window = windows[id]
    if not window then
        error("Can not found window")
    end

    local ud = {}
    ud.id = id
    ud.event = event
    ud.ud = {...}
    world:pub {"ui_receiver", window, ud} -- world -> rmlui
end
