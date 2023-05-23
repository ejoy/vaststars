local ecs = ...
local world = ecs.world
local w = world.w

local lorry_manager = ecs.require "lorry_manager"
local gameplay_core = require "gameplay.core"
local lorry_sys = ecs.system "lorry_system"

function lorry_sys:gameworld_update()
    local gameplay_world = gameplay_core.get_world()

    local mc, x, y, z
    for lorry_id, classid, item_classid, item_amount, rc, progress, maxprogress in gameplay_world:roadnet_each_lorry() do
        mc = gameplay_world:roadnet_map_coord(rc)
        if not mc then
            -- log.error(("failed to get map coord, lorry_id(%s) rc(%s)"):format(lorry_id, rc)) -- TODO
            goto continue
        end
        x, y, z = mc & 0xFF, (mc >> 8) & 0xFF, (mc >> 16) & 0xFF
        lorry_manager.update(lorry_id, classid, item_classid, item_amount, x, y, z, progress, maxprogress)
        ::continue::
    end
    return false
end