local ecs   = ...
local world = ecs.world
local w     = world.w

local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"
local igame_object = ecs.require "engine.game_object"
local ig = ecs.require "ant.group|group"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

-- world coordinate system
-- z   y
-- ▲  7 
-- | /
-- └──►x

-- logical coordinate system
-- range: [0, WIDTH - 1], determined by gameplay
-- ┌──►x
-- │
-- ▼
-- y

local terrain = {}

local SURFACE_HEIGHT <const> = 0
local TILE_SIZE <const> = 10
local WIDTH <const> = 256
local HEIGHT <const> = 256
local GRID_WIDTH <const> = 16
local GRID_HEIGHT <const> = 16
local MAX_BUILDING_WIDTH <const> = 6
local MAX_BUILDING_HEIGHT <const> = 6
assert(GRID_WIDTH % 2 == 0 and GRID_HEIGHT % 2 == 0)
assert(WIDTH % GRID_WIDTH == 0 and HEIGHT % GRID_HEIGHT == 0)

local function _hash(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function _get_gridxy(x, y)
    return math.floor(x / GRID_WIDTH) + 1, math.floor(y / GRID_HEIGHT) + 1
end

local function _get_coord_by_position(self, position)
    local boundary_3d = self._boundary_3d
    local posx, posz = math3d.index(position, 1, 3)

    if (posx < boundary_3d[1][1] or posx > boundary_3d[2][1]) or
        (posz < boundary_3d[1][3] or posz > boundary_3d[2][3]) then
        -- log.error(("out of bounds (%f, %f) : (%s) - (%s)"):format(posx, posz, table.concat(boundary_3d[1], ","), table.concat(boundary_3d[2], ",")))
        return
    end

    local origin = self._origin
    return {math.floor((posx - origin[1]) / TILE_SIZE), math.floor((origin[2] - posz) / TILE_SIZE)}
end

local function _get_grid_id(x, y)
    return _hash(_get_gridxy(x, y))
end

function terrain:get_group_id(x, y)
	return self._group_id[_get_grid_id(x, y)]
end

function terrain:create()
    self.lock_group = false
    self.surface_height = SURFACE_HEIGHT
    self.tile_size = TILE_SIZE
    self._width, self._height = WIDTH, HEIGHT
    local offset_3d = {-(self._width * TILE_SIZE)/2, 0.0, -(self._height * TILE_SIZE)/2}
    local boundary_3d = {
        offset_3d,
        {offset_3d[1] + self._width * TILE_SIZE, offset_3d[2], offset_3d[3] + self._height * TILE_SIZE}
    }

    self._boundary_3d = boundary_3d
    self._origin = {offset_3d[1], boundary_3d[2][3]} -- origin in logical coordinates
    self._coord_bounds = {
        {0, 0},
        {self._width - 1, self._height - 1},
    }
    self._grid_bounds = {
        {0, 0},
        {_get_gridxy(self._coord_bounds[2][1], self._coord_bounds[2][2])},
    }

    local function gen_group_id()
        return setmetatable({}, {
            __index = function (tt, k)
                if not rawget(tt, k) then
                    local o = "TERRAIN_GROUP_" .. k
                    local gid = ig.register(o)
                    tt[k] = gid
                end
                return tt[k]
        end})
    end

    self._group_id = gen_group_id()
    self._enabled_group_id = {}
end

function terrain:reset_mineral(map)
    --
    for _, eid in ipairs(self.eids or {}) do
        eid:remove()
    end
    self.eids = {}

    self.mineral = {}
    self.mineral_cache = {}
    self.mineral_source = map

    for c, mineral in pairs(map) do
        local x, y = c:match("^(%d+),(%d+)$")
        x, y = tonumber(x), tonumber(y)

        local typeobject = iprototype.queryByName(mineral)
        local errmsg <const> = "%s is defined as a type of mineral, but no corresponding mineral model is configured."
        local mineral_model = assert(assert(typeobject).mineral_model, errmsg:format(mineral))

        local w, h = typeobject.mineral_area:match("^(%d+)x(%d+)$")
        w, h = tonumber(w), tonumber(h)

        local hash = _hash(x, y)
        self.mineral[hash] = {x = x, y = y, w = w, h = h, mineral = mineral}

        for i = 0, w - 1 do
            for j = 0, h - 1 do
                self.mineral_cache[_hash(x + i, y + j)] = hash
            end
        end

        local srt = {r = ROTATORS[math.random(1, 4)], t = self:get_position_by_coord(x, y, w, h)}
        self.eids[#self.eids+1] = igame_object.create {
            prefab = mineral_model,
            group_id = self:get_group_id(x, y),
            srt = srt,
            render_layer = RENDER_LAYER.MINERAL
        }
    end
end

function terrain:get_mineral(x, y)
    local hash = self.mineral_cache[_hash(x, y)]
    if not hash then
        return
    end
    local m = assert(self.mineral[hash])
    return m, hash
end

function terrain:can_place_on_mineral(x, y, w, h)
    local mid_x, mid_y = x + w // 2, y + h // 2
    local hash = self.mineral_cache[_hash(mid_x, mid_y)]
    local m = self.mineral[hash]
    if not m then
        return false
    end
    if mid_x ~= m.x + m.w // 2 or mid_y ~= m.y + m.h // 2 then
        return false
    end
    return true, m.mineral
end

function terrain:enable_terrain(lefttop, rightbottom)
    if self.lock_group == true then
        return
    end
    local function diff(t1, t2)
        local add, del = {}, {}
        for group_id in pairs(t1) do
            if t2[group_id] == nil then
                del[#del+1] = group_id
            end
        end
        for group_id in pairs(t2) do
            if t1[group_id] == nil then
                add[#add+1] = group_id
            end
        end
        return add, del
    end

    -- because the group id of the buildings is calculated based on the coordinates of the top-left corner, so we need to expand the range
    lefttop = math3d.add(lefttop, {-(MAX_BUILDING_WIDTH * TILE_SIZE), 0, MAX_BUILDING_HEIGHT * TILE_SIZE})
    rightbottom = math3d.add(rightbottom, {MAX_BUILDING_WIDTH * TILE_SIZE, 0, -(MAX_BUILDING_HEIGHT * TILE_SIZE)})

    local ltCoord = self:get_coord_by_position(lefttop) or {0, 0}
    local rbCoord = self:get_coord_by_position(rightbottom) or {self._coord_bounds[2][1], self._coord_bounds[2][2]}

    local ltGridCoord = {_get_gridxy(ltCoord[1], ltCoord[2])}
    local rbGridCoord = {_get_gridxy(rbCoord[1], rbCoord[2])}

    local new = {}
    for x = ltGridCoord[1], rbGridCoord[1] do
        for y = ltGridCoord[2], rbGridCoord[2] do
            local group_id = assert(self._group_id[_hash(x, y)])
            new[group_id] = true
        end
    end

    local add, del = diff(self._enabled_group_id, new)
    self._enabled_group_id = new
    local go = ig.obj "view_visible"
    for _, group_id in ipairs(add) do
        print(("enable group id: %s"):format(group_id))
        go:enable(group_id, true)
    end
    for _, group_id in ipairs(del) do
        print(("disable group id: %s"):format(group_id))
        go:enable(group_id, false)
    end

    go:flush()
    go:filter("render_object_visible", "render_object")
    go:filter("hitch_visible", "hitch")
    go:filter("efk_visible", "efk")
end

function terrain:verify_coord(x, y)
    local coord_bounds = self._coord_bounds
    if x < coord_bounds[1][1] or x > coord_bounds[2][1] then
        return false
    end
    if y < coord_bounds[1][2] or y > coord_bounds[2][2] then
        return false
    end
    return true
end

function terrain:bound_coord(x, y)
    x = math.max(x, self._coord_bounds[1][1])
    x = math.min(x, self._coord_bounds[2][1])
    y = math.max(y, self._coord_bounds[1][2])
    y = math.min(y, self._coord_bounds[2][2])
    return x, y
end

function terrain:move_coord(x, y, dir, dx, dy)
    local _x, _y = iprototype.move_coord(x, y, dir, dx, dy)
    if not self:verify_coord(_x, _y) then
        return false, self:bound_coord(_x, _y)
    end
    return true, _x, _y
end

function terrain:get_begin_position_by_coord(x, y)
    local coord_bounds = self._coord_bounds
    local origin = self._origin

    if not self:verify_coord(x, y) then
        log.error(("out of bounds (%s,%s) : (%s) - (%s)"):format(x, y, table.concat(coord_bounds[1], ","), table.concat(coord_bounds[2], ",")))
        return
    end
    return {origin[1] + (x * TILE_SIZE), SURFACE_HEIGHT, origin[2] - (y * TILE_SIZE)}
end

-- return the position of the center of the entity
function terrain:get_position_by_coord(x, y, w, h)
    local begining = self:get_begin_position_by_coord(x, y)
    if not begining then
        return
    end

    return {begining[1] + (w / 2 * TILE_SIZE), begining[2], begining[3] - (h / 2 * TILE_SIZE)}
end

-- position is the center of the entity
function terrain:align(position, w, h)
    -- equivalent to: math3d.vector {math3d.index(position, 1) - (w / 2 * TILE_SIZE), math3d.index(position, 2), math3d.index(position, 3) + (h / 2 * TILE_SIZE)}
    local begin_position = math3d.muladd(1/2*TILE_SIZE, math3d.vector(-w, 0.0, h), position)
    local coord = _get_coord_by_position(self, begin_position)
    if not coord then
        return
    end

    local begining = self:get_begin_position_by_coord(coord[1], coord[2])
    if not begining then
        return
    end

    return coord, {begining[1] + (w / 2 * TILE_SIZE), math3d.index(position, 2), begining[3] - (h / 2 * TILE_SIZE)}
end

function terrain:get_coord_by_position(position)
    return _get_coord_by_position(self, position)
end

return terrain