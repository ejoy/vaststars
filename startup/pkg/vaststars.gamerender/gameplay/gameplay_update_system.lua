local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"

local m = ecs.system "gameplay_update_system"
local gameworld_prebuild
local gameworld_build
local gameworld

function m:init()
    gameworld_prebuild = world:pipeline_func "gameworld_prebuild"
    gameworld_build = world:pipeline_func "gameworld_build"
    gameworld = world:pipeline_func "gameworld"
end

function m:gameworld_end()
    local gameplay_ecs = gameplay_core.get_world().ecs
    gameplay_ecs:clear("building_new")
end

function m:frame_update()
    local gameplay_world = gameplay_core.get_world()
    if gameplay_core.system_changed_flags ~= 0 then
        print("build world")
        gameplay_core.system_changed_flags = 0
        gameworld_prebuild()
        gameplay_world:update()
        gameworld_build()
    else
        if gameplay_core.world_update then
            gameplay_world:update()
            gameworld()
        end
    end
end