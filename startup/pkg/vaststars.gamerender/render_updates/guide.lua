local ecs = ...
local world = ecs.world
local w = world.w

local global = require "global"
local iui = ecs.require "engine.system.ui_system"
local iguide = require "gameplay.interface.guide"
local guide_sys = ecs.system "guide_system"
local gameplay_core = require "gameplay.core"

function guide_sys:gameworld_update()
    local world = gameplay_core.get_world()
    local science = global.science
    if not iguide.is_running() or iguide.is_in_guide() or science.current_tech then
        return
    end
    local guide = iguide.get_guide()
    if not guide then
        return
    end
    local prerequisites = guide.prerequisites
    local run_guide = true
    if prerequisites then
        for _, value in ipairs(prerequisites) do
            if not world:is_researched(value) then
                run_guide = false
            end
        end
    end
    if run_guide then
        -- hide pop ui
        iui.leave()
        iui.broadcast("/pkg/vaststars.resources/ui/guide_on_going")

        -- pop guide ui
        iui.open({rml = "/pkg/vaststars.resources/ui/guide_pop.rml"}, guide)
        iguide.set_is_in_guide(true)
    end
end