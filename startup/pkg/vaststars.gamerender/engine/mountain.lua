local ecs   = ...
local world = ecs.world
local w     = world.w

local MOUNTAIN = import_package "vaststars.prototype".load("mountain")
local ism = ecs.import.interface "mod.stonemountain|istonemountain"

local function __logic_to_render(x, y, offset, width, height)
    x, y = x, height - y - 1
    x, y = x - offset, y - offset
    return {x, y}
end

local function __coords_to_positions(t, offset, width, height)
    local r = {}
    for _, v in ipairs(t) do
        local c = __logic_to_render(v[1], v[2], offset, width, height)
        table.insert(r, {x = c[1], z = c[2]})
    end
    return r
end

local function __rects_to_positions(t, offset, width, height)
    local r = {}
    for _, v in ipairs(t) do
        local c1 = __logic_to_render(v[1], v[2], offset, width, height)
        local c2 = __logic_to_render(v[3], v[4], offset, width, height)
        local w, h = math.abs(c2[1] - c1[1]), math.abs(c2[2] - c1[2])
        table.insert(r, {x = c1[1], z = c1[2], w = w, h = h})
    end
    return r
end

local M = {}

function M:create(width, height, offset, unit)
    self._offset = offset
    self._width = width
    self._height = height
    ism.create_sm_entity(MOUNTAIN.density, width, height, offset, unit, MOUNTAIN.scale, __coords_to_positions(MOUNTAIN.mountain_coords, offset, width, height), __rects_to_positions(MOUNTAIN.excluded_rects, offset, width, height))
end

function M:has_mountain(x, y)
    local c = __logic_to_render(x, y, self._offset, self._width, self._height)
    return ism.exist_sm({{x = c[1], z = c[2], w = 1, h = 1}})
end

return M