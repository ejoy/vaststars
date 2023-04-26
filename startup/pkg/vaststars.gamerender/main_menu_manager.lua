local ecs = ...
local world = ecs.world
local w = world.w

local icamera_controller = ecs.import.interface "vaststars.gamerender|icamera_controller"
local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function init()
    icamera_controller.set_camera_from_prefab("camera_default.prefab")
end

local function new_game()
    icamera_controller.set_camera_from_prefab("camera_default.prefab")
    if not saveload:restart() then
        return
    end
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
end

local function continue_game()
    if not saveload:restore() then
        return
    end
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
end

return {
    init = init,
    new_game = new_game,
    continue_game = continue_game,
}