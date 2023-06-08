local ecs = ...
local world = ecs.world

local lorry_manager = ecs.require "lorry_manager"
local gameplay_core = require "gameplay.core"
local lorry_sys = ecs.system "lorry_system"

function lorry_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()

    local x, y, z, w
    for lorry_id, classid, item_classid, item_amount, mc, progress, maxprogress in gameplay_world:roadnet_each_lorry() do
        x = mc & 0xFF
        y = (mc >> 8) & 0xFF
        z = (mc >> 16) & 0xF
        w = (mc >> 20) & 0xF
        lorry_manager.update(lorry_id, classid, item_classid, item_amount, x, y, w, z, progress, maxprogress)
    end
    return false
end

function lorry_sys:gameworld_clean()
    local lorry_manager = ecs.require "lorry_manager" -- init_system.lua require "lorry_manager" & "roadnet"
    lorry_manager.clear()
end