local ecs   = ...
local world = ecs.world
local w     = world.w

local iprototype = require "gameplay.interface.prototype"

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

local SURFACE_HEIGHT <const> = 4
local TILE_SIZE <const> = 10
local WIDTH <const> = 256
local HEIGHT <const> = 256
local GROUND_WIDTH <const> = 4
local GROUND_HEIGHT <const> = 4
local GRID_WIDTH <const> = (10 + 5) * GROUND_WIDTH
local GRID_HEIGHT <const> = ((5 + 3) * GROUND_HEIGHT)
assert(GRID_WIDTH % 2 == 0 and GRID_HEIGHT % 2 == 0)

local function _pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function _get_group_id(self, x, y)
	local grid_x = x//GRID_WIDTH
	local grid_y = y//GRID_HEIGHT
	return self._group_id[_pack(grid_x, grid_y)]
end

local function _get_screen_group_id(self, x, y)
	local grid_x = x//GRID_WIDTH
	local grid_y = y//GRID_HEIGHT
	assert(self._group_id[_pack(grid_x, grid_y)])

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
            local group_id = self._group_id[_pack(i, j)]
			result[group_id] = true
		end
	end
    return result
end

local function _get_coord_by_begin_position(self, position)
    local boundary_3d = self._boundary_3d
    local origin = self._origin

    if position[1] < boundary_3d[1][1] or position[1] > boundary_3d[2][1] then
        log.error(("out of bounds (%s) : (%s) - (%s)"):format(table.concat(position, ","), table.concat(boundary_3d[1], ","), table.concat(boundary_3d[2], ",")))
        return
    end

    if position[3] < boundary_3d[1][3] or position[3] > boundary_3d[2][3] then
        log.error(("out of bounds (%s) : (%s) - (%s)"):format(table.concat(position, ","), table.concat(boundary_3d[1], ","), table.concat(boundary_3d[2], ",")))
        return
    end

    return {math.ceil((position[1] - origin[1]) / TILE_SIZE), math.ceil((origin[2] - position[3]) / TILE_SIZE)}
end

function terrain:create(width, height)
    self.ground_width, self.ground_height = GROUND_WIDTH, GROUND_HEIGHT
    self.surface_height = SURFACE_HEIGHT
    self.tile_size = TILE_SIZE

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
                result[_pack(x, y)] = group_id
            end
        end
        return result
    end
    self._group_id = gen_group_id()
    self._enabled_group_id = {}

    local e = w:singleton("shape_terrain", "shape_terrain:in scene:in id:in")
    if e then
       world:remove_entity(e.id)
    end

    local function generate_mesh_shape(self, width, height)
        local ms = {
            meshes = {
                "/pkg/vaststars.resources/prefabs/terrain/ground_01.prefab",
                "/pkg/vaststars.resources/prefabs/terrain/ground_02.prefab",
                "/pkg/vaststars.resources/prefabs/terrain/ground_03.prefab",
                "/pkg/vaststars.resources/prefabs/terrain/ground_04.prefab",
            },
        }

        assert(width % GROUND_WIDTH == 0 and height % GROUND_HEIGHT == 0)
        local w, h = width // GROUND_WIDTH, height // GROUND_HEIGHT
        for y = 0, h - 1 do
            for x = 0, w - 1 do
                local _x, _y = x * GROUND_WIDTH, y * GROUND_HEIGHT
                ms[#ms+1] = {
                    mash_idx = math.random(1, 4),
                    group_id = _get_group_id(self, _x, _y),
                    pos = self:get_position_by_coord(_x, _y, GROUND_WIDTH, GROUND_HEIGHT),
                }
            end
        end

        return ms
    end
    ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.general|name",
        },
        data = {
            name = "shape_terrain",
            scene = {
                srt = { t = offset_3d },
            },
            shape_terrain = {
                width = self._width,
                height = self._height,
                unit = TILE_SIZE,
                mesh_shape = generate_mesh_shape(self, self._width, self._height)
            },
        }
    }
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
        ecs.group(group_id):enable "scene_changed"
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
    y = math.max(x, self._coord_bounds[1][2])
    y = math.min(x, self._coord_bounds[2][2])
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
    return {origin[1] + (x * TILE_SIZE), 0, origin[2] - (y * TILE_SIZE)}
end

-- 返回建筑的中心位置
function terrain:get_position_by_coord(x, y, w, h)
    local begining = self:get_begin_position_by_coord(x, y)
    if not begining then
        return
    end

    return {begining[1] + (w / 2 * TILE_SIZE), begining[2], begining[3] - (h / 2 * TILE_SIZE)}
end

-- position 为建筑的中心位置
function terrain:adjust_position(position, w, h)
    local begin_position = {position[1] - (w / 2 * TILE_SIZE), position[2], position[3] + (h / 2 * TILE_SIZE)}
    local coord = _get_coord_by_begin_position(self, begin_position)
    if not coord then
        return
    end

    local begining = self:get_begin_position_by_coord(coord[1], coord[2])
    if not begining then
        return
    end

    return coord, {begining[1] + (w / 2 * TILE_SIZE), position[2], begining[3] - (h / 2 * TILE_SIZE)}
end

function terrain:can_place(x, y)
    return true
end

return terrain