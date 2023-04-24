local ecs = ...
local world = ecs.world

local iprototype = require "gameplay.interface.prototype"
local global = require "global"
local iroadnet_converter = require "roadnet_converter"
local coord_system = ecs.require "terrain"

local MASK_ENDPOINT <const> = 0x10
local MASK_ROADNET_ONLY <const> = 0x20

local function __calc_offset(position, direction, area)
    local w, h = iprototype.unpackarea(area)
    local x, y = position[1], position[2]
    w, h = w - 1, h - 1
    if direction == 'N' then
        return x, y
    elseif direction == 'E' then
        return h - y, x
    elseif direction == 'S' then
        return w - x, h - y
    elseif direction == 'W' then
        return y, w - x
    end
end

local MAPPING <const> = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local function gen_endpoint_mask(object)
    local res = {}
    local typeobject = iprototype.queryByName(object.prototype_name)
    for _, tile in pairs(typeobject.endpoint) do
        local offset_x, offset_y = __calc_offset(tile.position, object.dir, typeobject.area)
        local x, y = object.x + offset_x, object.y + offset_y
        do
            local coord = iprototype.packcoord(x, y)
            local dir = iprototype.rotate_dir(tile.dir, object.dir)
            assert(global.roadnet[coord] == nil)
            global.roadnet[coord] = iroadnet_converter.prototype_name_dir_to_mask(tile.prototype, dir) | MASK_ROADNET_ONLY
            if tile.type == "endpoint" then
                global.roadnet[coord] = global.roadnet[coord] | MASK_ENDPOINT
            end
        end
        if tile.entrance_dir then
            local entrance_dir = iprototype.rotate_dir(tile.entrance_dir, object.dir)
            local succ, dx, dy = coord_system:move_coord(x, y, entrance_dir, 1)
            assert(succ)
            local coord = iprototype.packcoord(dx, dy)
            assert(global.roadnet[coord])
            global.roadnet[coord] = global.roadnet[coord] | (1 << MAPPING[iprototype.reverse_dir(entrance_dir)])

            res[#res + 1] = coord
        end
    end
    return res
end

local function is_roadnet_only(mask)
    return (mask & MASK_ROADNET_ONLY) == MASK_ROADNET_ONLY
end

return {
    gen_endpoint_mask = gen_endpoint_mask,
    is_roadnet_only = is_roadnet_only,

}