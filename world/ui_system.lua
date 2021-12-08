local ecs = ...
local world = ecs.world

local irmlui = ecs.import.interface "ant.rmlui|irmlui"

local json = import_package "ant.json"
local json_encode = json.encode
local json_decode = json.decode

local ui_receiver_mb = world:sub {"ui_receiver"}
local windows = {} -- todo assuming there is only one window

local ui_system = ecs.system 'ui_system'
function ui_system.data_changed()
    for _, window, ud in ui_receiver_mb:unpack() do
        window.postMessage(json_encode(ud))
    end
end

local iui = ecs.interface "iui"
function iui.open(id, url)
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

        world:pub {"ui", res.id, res.event, table.unpack(res.ud)}
    end)

    windows[id] = w
end

function iui.close(id)
    local window = windows[id]
    if not window then
        error("Can not found window")
    end

    window:close()
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
    world:pub {"ui_receiver", window, ud}
end
