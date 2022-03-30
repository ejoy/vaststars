local ecs = ...
local world = ecs.world
local w = world.w

local ientity = ecs.import.interface "ant.render|ientity"
local prototype = ecs.require "prototype"
local igame_object_block = ecs.interface "igame_object_block"

local gen_id do
    local id = 0
    function gen_id()
        id = id + 1
        return id
    end
end

function igame_object_block.create(color, area, position)
    local w, h = prototype.unpack_area(area)
    return ientity.create_prim_plane_entity(
		{t = position, s = {10.0 * w, 1.0, 10.0 * h}},
		"/pkg/vaststars.resources/materials/singlecolor.material",
		color,
		("plane_%d"):format(gen_id())
    )
end
