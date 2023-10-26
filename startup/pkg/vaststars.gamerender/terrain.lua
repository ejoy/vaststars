local ecs   = ...
local world = ecs.world
local w     = world.w

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

local CONSTANT <const> = require("gameplay.interface.constant")
local SURFACE_HEIGHT <const> = 0
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local WIDTH <const> = CONSTANT.MAP_WIDTH
local HEIGHT <const> = CONSTANT.MAP_HEIGHT
local ROTATORS <const> = CONSTANT.ROTATORS
local GRID_WIDTH <const> = 16
local GRID_HEIGHT <const> = 16
local MAX_BUILDING_WIDTH <const> = 6
local MAX_BUILDING_HEIGHT <const> = 6
assert(GRID_WIDTH % 2 == 0 and GRID_HEIGHT % 2 == 0)
assert(WIDTH % GRID_WIDTH == 0 and HEIGHT % GRID_HEIGHT == 0)
local OFFSET_3D <const> = {-(WIDTH * TILE_SIZE)/2, 0.0, -(HEIGHT * TILE_SIZE)/2}
local BOUNDARY_3D <const> = {
    OFFSET_3D,
    {OFFSET_3D[1] + WIDTH * TILE_SIZE, OFFSET_3D[2], OFFSET_3D[3] + HEIGHT * TILE_SIZE}
}
local ORIGIN <const> = {OFFSET_3D[1], BOUNDARY_3D[2][3]} -- the world position corresponding to the logical origin (0, 0)
local COORD_BOUNDARY <const> = {
    {0, 0},
    {WIDTH - 1, HEIGHT - 1},
}
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iprototype = require "gameplay.interface.prototype"
local math3d = require "math3d"
local igame_object = ecs.require "engine.game_object"
local ig = ecs.require "ant.group|group"

local function _get_gridxy(x, y)
    return (x // GRID_WIDTH) + 1, (y // GRID_HEIGHT) + 1
end

local function _get_coord_by_position(position)
    local posx, posz = math3d.index(position, 1, 3)

    if (posx < BOUNDARY_3D[1][1] or posx > BOUNDARY_3D[2][1]) or
        (posz < BOUNDARY_3D[1][3] or posz > BOUNDARY_3D[2][3]) then
        -- log.error(("out of bounds (%f, %f) : (%s) - (%s)"):format(posx, posz, table.concat(BOUNDARY_3D[1], ","), table.concat(BOUNDARY_3D[2], ",")))
        return
    end

    return {math.floor((posx - ORIGIN[1]) // TILE_SIZE), math.floor((ORIGIN[2] - posz) // TILE_SIZE)}
end

local function _get_grid_id(x, y)
    return iprototype.packcoord(_get_gridxy(x, y))
end

local terrain = {}

function terrain:get_group_id(x, y)
	return self._group_id[_get_grid_id(x, y)]
end

function terrain:create()
    self.lock_group = false
    self.surface_height = SURFACE_HEIGHT
    self.tile_size = TILE_SIZE
    self._width, self._height = WIDTH, HEIGHT

    local function gen_group_id()
        return setmetatable({}, {
            __index = function (tt, k)
                local o = "TERRAIN_GROUP_" .. k
                local gid = ig.register(o)
                tt[k] = gid
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
        local mineral_model = assert(typeobject).mineral_model or error(errmsg:format(mineral))

        local w, h = typeobject.mineral_area:match("^(%d+)x(%d+)$")
        w, h = tonumber(w), tonumber(h)

        local hash = iprototype.packcoord(x, y)
        self.mineral[hash] = {x = x, y = y, w = w, h = h, mineral = mineral}

        for i = 0, w - 1 do
            for j = 0, h - 1 do
                self.mineral_cache[iprototype.packcoord(x + i, y + j)] = hash
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
    local hash = self.mineral_cache[iprototype.packcoord(x, y)]
    if not hash then
        return
    end
    local m = assert(self.mineral[hash])
    return m, hash
end

function terrain:can_place_on_mineral(x, y, w, h)
    local mid_x, mid_y = x + w // 2, y + h // 2
    local hash = self.mineral_cache[iprototype.packcoord(mid_x, mid_y)]
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
    local rbCoord = self:get_coord_by_position(rightbottom) or {COORD_BOUNDARY[2][1], COORD_BOUNDARY[2][2]}

    local ltGridCoord = {_get_gridxy(ltCoord[1], ltCoord[2])}
    local rbGridCoord = {_get_gridxy(rbCoord[1], rbCoord[2])}

    local new = {}
    for x = ltGridCoord[1], rbGridCoord[1] do
        for y = ltGridCoord[2], rbGridCoord[2] do
            local group_id = assert(self._group_id[iprototype.packcoord(x, y)])
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
    if x < COORD_BOUNDARY[1][1] or x > COORD_BOUNDARY[2][1] then
        return false
    end
    if y < COORD_BOUNDARY[1][2] or y > COORD_BOUNDARY[2][2] then
        return false
    end
    return true
end

function terrain:bound_coord(x, y)
    x = math.max(x, COORD_BOUNDARY[1][1])
    x = math.min(x, COORD_BOUNDARY[2][1])
    y = math.max(y, COORD_BOUNDARY[1][2])
    y = math.min(y, COORD_BOUNDARY[2][2])
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
    if not self:verify_coord(x, y) then
        log.error(("out of bounds (%s,%s) : (%s) - (%s)"):format(x, y, table.concat(COORD_BOUNDARY[1], ","), table.concat(COORD_BOUNDARY[2], ",")))
        return
    end
    return {ORIGIN[1] + (x * TILE_SIZE), SURFACE_HEIGHT, ORIGIN[2] - (y * TILE_SIZE)}
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
    local coord = _get_coord_by_position(begin_position)
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
    return _get_coord_by_position(position)
end

function terrain:group_indices(gid)
    local gx0, gy0 = gid // GRID_WIDTH, gid % GRID_HEIGHT
    local indices = {}

    local offset0 = (gy0 * GRID_HEIGHT) * WIDTH + gx0 * GRID_WIDTH
    for ih=1, GRID_HEIGHT do
        local y = (ih-1) * WIDTH
        for iw=1, GRID_WIDTH do
            indices[#indices+1] = offset0 + y + (iw-1)   --base0
        end
    end
    return indices
end

function terrain:grid_size()
    return GRID_WIDTH, GRID_HEIGHT
end

--base 0
function terrain:idx2coord(idx)
    return (idx % WIDTH), (idx // WIDTH)
end

--base 0
function terrain:coord2idx(x, y)
    return y * WIDTH + x
end

--base 1
function terrain:idx2coord1(idx)
    assert(idx > 0, "Invalid idx, it's base 1")
    local idxbase0 = idx - 1
    local x0, y0 = terrain:idx2coord(idxbase0)
    return x0+1, y0+1
end

-- base 1
function terrain:coord2idx1(x, y)
    assert(x > 0 and y > 0, "Invalid x or y, it's base 1")

    return terrain:coord2idx(x-1, y-1)
end

local DEBUG_COORD_IDX<const> = false
if DEBUG_COORD_IDX then
    local function coord_idx_test(idx, checkx, checky)
        local x, y = terrain.idx2coord1(idx)
        assert(x == checkx and y == checky)

        local idx1 = terrain.coord2idx1(x, y)
        assert(idx1 == idx)
    end

    coord_idx_test(1, 1, 1)
    coord_idx_test(256, 256, 1)
    coord_idx_test(257, 1, 2)
end

return terrain