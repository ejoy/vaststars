local ecs = ...
local world = ecs.world
local w = world.w

local lorry_manager = ecs.require "lorry_manager"

return function(gameplay_world)
    local mc, x, y, z
    for lorry_id, rc, tick in gameplay_world:roadnet_each_lorry() do
        mc = gameplay_world:roadnet_map_coord(rc)
        if not mc then
            print("can not found lorry_id(%s) rc(%s)", lorry_id, rc)
            goto continue
        end
        x, y, z = mc & 0xFF, (mc >> 8) & 0xFF, (mc >> 16) & 0xFF
        lorry_manager.update(lorry_id, x, y, z, tick)
        ::continue::
    end
end