local ecs   = ...
local world = ecs.world
local w     = world.w

local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local COLOR_INVALID <const> = math3d.constant "null"
local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local MINERAL_WIDTH <const> = 7
local MINERAL_HEIGHT <const> = 7

-- three-dimensional axial
-- z
-- ▲
-- │
-- │
-- └──►x

-- two-dimensional axial
-- ┌──►x
-- │
-- │
-- ▼
-- y

local terrain = {}

local SURFACE_HEIGHT <const> = 0
local TILE_SIZE <const> = 10
local WIDTH <const> = 256 -- coordinate value range: [0, WIDTH - 1]
local HEIGHT <const> = 256
local GRID_WIDTH <const> = (10 + 5) * 4
local GRID_HEIGHT <const> = 52
assert(GRID_WIDTH % 2 == 0 and GRID_HEIGHT % 2 == 0)
local TERRAIN_MAX_GROUP_ID = 10000

local function _hash(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function _get_screen_group_id(self, x, y)
	local grid_x = x//GRID_WIDTH
	local grid_y = y//GRID_HEIGHT
	assert(self._group_id[_hash(grid_x, grid_y)])

    local result = {}
    local min_x, max_x = self._grid_bounds[1][1], self._grid_bounds[2][1]
    local min_y, max_y = self._grid_bounds[1][2], self._grid_bounds[2][2]
    local xb, xe
    if x % GRID_WIDTH + 1 <= GRID_WIDTH / 2 then
        xb = math.max(grid_x - 1, min_x)
        xe = grid_x
    else
        xb = grid_x
        xe = math.min(grid_x + 1, max_x)
    end
    local yb, ye
    if y % GRID_HEIGHT + 1 <= GRID_HEIGHT / 2 then
        yb = math.max(grid_y - 1, min_y)
        ye = grid_y
    else
        yb = grid_y
        ye = math.min(grid_y + 1, max_y)
    end

	for i = xb, xe do
		for j = yb, ye do
            local group_id = self._group_id[_hash(i, j)]
			result[group_id] = true
		end
	end
    return result
end

local function _get_coord_by_position(self, position)
    local boundary_3d = self._boundary_3d
    local posx, posz = math3d.index(position, 1, 3)

    if (posx < boundary_3d[1][1] or posx > boundary_3d[2][1]) or
        (posz < boundary_3d[1][3] or posz > boundary_3d[2][3]) then
        log.error(("out of bounds (%f, %f) : (%s) - (%s)"):format(posx, posz, table.concat(boundary_3d[1], ","), table.concat(boundary_3d[2], ",")))
        return
    end

    local origin = self._origin
    return {math.floor((posx - origin[1]) / TILE_SIZE), math.floor((origin[2] - posz) / TILE_SIZE)}
end

local function _get_grid_id(x, y)
    local grid_x = x//GRID_WIDTH
    local grid_y = y//GRID_HEIGHT
    return _hash(grid_x, grid_y)
end

function terrain:get_group_id(x, y)
	return self._group_id[_get_grid_id(x, y)]
end

function terrain:create(width, height)
    self.surface_height = SURFACE_HEIGHT
    self.tile_size = TILE_SIZE
    self.tile_width, self.tile_height = width or WIDTH, height or HEIGHT

    self._width, self._height = width or WIDTH, height or HEIGHT
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
        {math.ceil(self._width / GRID_WIDTH) - 1, math.ceil(self._height / GRID_HEIGHT) - 1},
    }

    local function gen_group_id()
        local group_id = 0
        local result = {}
        local min_x, max_x = self._grid_bounds[1][1], self._grid_bounds[2][1]
        local min_y, max_y = self._grid_bounds[1][2], self._grid_bounds[2][2]

        for x = min_x, max_x do
            for y = min_y, max_y do
                group_id = group_id + 1
                result[_hash(x, y)] = group_id
            end
        end
        assert(group_id < TERRAIN_MAX_GROUP_ID)
        return result
    end
    self._group_id = gen_group_id()
    self._enabled_group_id = {}

    self.init = true
end

function terrain:reset_mineral(map)
    --
    self.eids = self.eids or {}
    for _, eid in ipairs(self.eids) do
        eid:remove()
    end

    self.mineral_map = {}
    self.mineral_tiles = {}
    self.mineral_source = map

    for c, mineral in pairs(map) do
        local x, y = c:match("^(%d+),(%d+)$")
        x, y = tonumber(x), tonumber(y)
        self.mineral_map[_hash(x, y)] = mineral

        for i = 0, MINERAL_WIDTH - 1 do
            for j = 0, MINERAL_HEIGHT - 1 do
                self.mineral_tiles[_hash(x + i, y + j)] = mineral
            end
        end

        local errmsg <const> = "%s is defined as a type of mineral, but no corresponding mineral model is configured."
        local prefab = assert(assert(iprototype.queryByName(mineral)).mineral_model, errmsg:format(mineral))

        local srt = {r = ROTATORS[math.random(1, 4)], t = self:get_position_by_coord(x, y, MINERAL_WIDTH, MINERAL_HEIGHT)}
        self.eids[#self.eids+1] = igame_object.create {
            prefab = prefab,
            effect = nil,
            group_id = self:get_group_id(x, y),
            state = "opaque",
            color = COLOR_INVALID,
            srt = srt,
            parent = nil,
            slot = nil,
            render_layer = RENDER_LAYER.MINERAL
        }
    end
end

function terrain:get_mineral(x, y)
    return self.mineral_map[_hash(x, y)]
end

function terrain:get_mineral_tiles(x, y)
    return self.mineral_tiles[_hash(x, y)]
end

function terrain:enable_terrain(x, y)
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

    local new = _get_screen_group_id(self, x, y)
    local add, del = diff(self._enabled_group_id, new)
    self._enabled_group_id = new
    for _, group_id in ipairs(add) do
        print(("enable group id: %s"):format(group_id))
        ecs.group(group_id):enable "view_visible"
        ecs.group(group_id):enable "scene_update"
    end
    for _, group_id in ipairs(del) do
        print(("disable group id: %s"):format(group_id))
        ecs.group(group_id):disable "view_visible"
        ecs.group(group_id):disable "scene_update"
    end
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