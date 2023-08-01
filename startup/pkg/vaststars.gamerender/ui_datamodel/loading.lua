local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local iui = ecs.import.interface "vaststars.gamerender|iui"

local resources_loader = ecs.require "ui_datamodel.common.resources_loader"
local resources = require "resources"

local WorkerNum <const> = 4

---------------
local M = {}

local function worker(index, status)
    while true do
        status.current = status.current + 1
        local filename = resources[status.current]
        if status.current + 1 > #resources then
            break
        end
        status[index] = filename
        resources_loader.load(filename)
    end
end

local status

function M:create(load)
    if load == nil then
        load = true
    end

    status = { current = 0 }
    local ltask = require "ltask"
    for i = 1, WorkerNum do
        status[i] = ""
        ltask.fork(worker, i, status)
    end

    return {
        current = 0,
        closed = false, -- TODO: remove this?
        load = load,
        status = status,
        progress = "0%",
    }
end

function M:stage_camera_usage(datamodel)
    if datamodel.closed == true then -- prevent call load_game() when window is closed
        return
    end
    if status.current + 1 > #resources then
        iui.close("ui/loading.rml")
        datamodel.closed = true
        return
    end
    for i, v in ipairs(status) do
        datamodel.status[i] = v
    end
    datamodel.progress = string.format("%d%%", math.floor(status.current / #resources * 100))
end

return M
