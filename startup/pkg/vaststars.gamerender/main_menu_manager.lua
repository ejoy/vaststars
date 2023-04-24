local ecs = ...
local world = ecs.world
local w = world.w

local prefab_parse = require("engine.prefab_parser").parse
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function __set_camera_from_prefab(prefab)
    local data = prefab_parse("/pkg/vaststars.resources/" .. prefab)
    if not data then
        return
    end
    assert(data[1] and data[1].data and data[1].data.camera)
    local c = data[1].data

    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref, "scene:update")
    e.scene.updir = mc.NULL -- TODO: use math3d.lookto() to reset updir

    iom.set_srt(e, c.scene.s or mc.ONE, c.scene.r, c.scene.t)
    -- Note: It will be inversed when the animation exceeds 90 degrees
    -- iom.set_view(e, iom.get_position(e), iom.get_direction(e), math3d.vector(data.scene.updir)) -- don't need to set updir, it will cause nan error
    ic.set_frustum(e, c.camera.frustum)
end

local function init()
    __set_camera_from_prefab("camera_default.prefab")
end

local function new_game()
    __set_camera_from_prefab("camera_default.prefab")
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