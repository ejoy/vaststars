local ecs = ...
local world = ecs.world
local w = world.w

local icamera_controller = ecs.import.interface "vaststars.gamerender|icamera_controller"
local saveload = ecs.require "saveload"
local gameplay_core = require "gameplay.core"
local iguide = require "gameplay.interface.guide"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local iom = ecs.require "ant.objcontroller|obj_motion"
local iani = ecs.import.interface "ant.animation|ianimation"
local game_cover

local function init(prefab)
    icamera_controller.set_camera_from_prefab(prefab)
end

local function new_game(mode, game_template)
    if game_cover then
        game_cover:remove()
        game_cover = nil
    end
    icamera_controller.set_camera_from_prefab("camera_default.prefab")
    saveload:restart(mode, game_template)
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
end

local function continue_game()
    if not saveload:restore() then
        return
    end
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
    if game_cover then
        game_cover:remove()
        game_cover = nil
    end
end

local function load_game(index)
    if not saveload:restore(index) then
        return
    end
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
    if game_cover then
        game_cover:remove()
        game_cover = nil
    end
    return true
end

local function createPrefabInst(prefab)
    local p = ecs.create_instance(prefab)
    function p:on_ready()
        local root <close> = w:entity(self.tag['*'][1])
        iom.set_position(root, {0, 0, 0})

        for _, eid in ipairs(self.tag['*']) do
            local e <close> = w:entity(eid, "animation_birth?in")
            if e.animation_birth then
                iani.play(self, {name = e.animation_birth, loop = true, speed = 1.0, manual = false})
            end
        end
    end
    function p:on_message()
    end
    return world:create_object(p)
end

local function back_to_main_menu()
    icamera_controller.set_camera_from_prefab("camera_gamecover.prefab")
    if not game_cover then
        game_cover = createPrefabInst("/pkg/vaststars.resources/glb/game-cover.glb|mesh.prefab")
    end

    gameplay_core.world_update = false
    iui.close("ui/construct.rml")
    iui.open({"ui/login.rml"})
end

return {
    init = init,
    load_game = load_game,
    new_game = new_game,
    continue_game = continue_game,
    back_to_main_menu = back_to_main_menu,
}