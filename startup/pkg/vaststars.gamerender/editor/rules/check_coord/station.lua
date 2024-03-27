local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local ROAD_WIDTH_COUNT <const> = CONSTANT.ROAD_WIDTH_COUNT
local ROAD_HEIGHT_COUNT <const> = CONSTANT.ROAD_HEIGHT_COUNT
local DIRECTION <const> = CONSTANT.DIRECTION

local ibuilding = ecs.require "render_updates.building"
local iprototype = require "gameplay.interface.prototype"

local function _check_road_adjacent(x, y, from1, to1, step1, from2, to2, step2)
    for i = from1, to1, step1 do
        for j = from2, to2, step2 do
            if not ibuilding.get(x + i, y + j) then
                return false, "the station must be built next to a road"
            end
        end
    end
    return true
end

local funcs = {
    [DIRECTION.N] = function (x, y, w, h)
        return _check_road_adjacent(x, y,
            0, w, ROAD_WIDTH_COUNT,
            -ROAD_HEIGHT_COUNT, -ROAD_HEIGHT_COUNT, 1
        )
    end,
    [DIRECTION.S] = function (x, y, w, h)
        return _check_road_adjacent(x, y,
            0, w, ROAD_WIDTH_COUNT,
            ROAD_HEIGHT_COUNT, ROAD_HEIGHT_COUNT, 1
        )
    end,
    [DIRECTION.W] = function (x, y, w, h)
        return _check_road_adjacent(x, y,
            -ROAD_WIDTH_COUNT, -ROAD_WIDTH_COUNT, 1,
            0, h, ROAD_HEIGHT_COUNT
        )
    end,
    [DIRECTION.E] = function (x, y, w, h)
        return _check_road_adjacent(x, y,
            ROAD_WIDTH_COUNT, ROAD_WIDTH_COUNT, 1,
            0, h, ROAD_HEIGHT_COUNT
        )
    end,
}


return function (x, y, dir, typeobject, exclude_coords)
    assert(typeobject.road_adjacent_dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    local f = assert(funcs[DIRECTION[iprototype.rotate_dir(typeobject.road_adjacent_dir, dir)]])
    return f(x, y, w, h)
end