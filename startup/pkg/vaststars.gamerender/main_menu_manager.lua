local ecs = ...
local world = ecs.world
local w = world.w

local icamera_controller = ecs.import.interface "vaststars.gamerender|icamera_controller"
local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function init(prefab)
    icamera_controller.set_camera_from_prefab(prefab)
end

local function new_game(mode)
    icamera_controller.set_camera_from_prefab("camera_default.prefab")
    saveload:restart(mode)
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

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local function createPrefabInst(prefab, position)
    local p = ecs.create_instance(prefab)
    function p:on_ready()
        local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
        local root <close> = w:entity(self.tag['*'][1])
        iom.set_position(root, position)
    end
    function p:on_message(name, method, ...)
        if name == "material" then
            local imaterial = ecs.import.interface "ant.asset|imaterial"
            for _, eid in ipairs(self.tag['*']) do
                local e <close> = w:entity(eid, "material?in")
                if e.material then
                    imaterial[method](e, ...)
                end
            end
        end
    end
    return world:create_object(p)
end

local function back_to_main_menu()
    icamera_controller.set_camera_from_prefab("camera_gamecover.prefab")
    gameplay_core.world_update = false
    iui.open({"login.rml"})
    -- createPrefabInst("/pkg/vaststars.resources/camera_gamecover.prefab", {0, 0, 0})
end

return {
    init = init,
    new_game = new_game,
    continue_game = continue_game,
    back_to_main_menu = back_to_main_menu,
}