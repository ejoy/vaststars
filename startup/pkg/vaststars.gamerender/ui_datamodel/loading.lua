local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local resources_loader = ecs.require "ui_datamodel.common.resources_loader"
local resources = require "resources"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local current
---------------
local M = {}
function M:create(load)
    current = 0

    if load == nil then
        load = true
    end

    return {
        closed = false, -- TODO: remove this?
        load = load,
        filename = resources[current] or "",
        progress = "0%",
    }
end

function M:stage_camera_usage(datamodel)
    if datamodel.closed == true then -- prevent call load_game() when window is closed
        return
    end
    if current + 1 > #resources then
        if datamodel.load then
            iui.open({"login.rml"})
        end
        world:pub {"rmlui_message_close", "loading.rml"}
        datamodel.closed = true
        return
    end

    local filename
    repeat
        current = current + 1
        filename = resources[current]
        if current + 1 > #resources then
            break
        end
    until resources_loader.load(filename)

    datamodel.filename = filename
    datamodel.progress = string.format("%d%%", math.floor(current / #resources * 100))
end

return M