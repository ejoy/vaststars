local ecs = ...
local world = ecs.world
local w = world.w

local iroad = ecs.require "engine.road"
local gameplay_core = require "gameplay.core"
local global = require "global"
local gameplay = import_package "vaststars.gameplay"
local iprototype = require "gameplay.interface.prototype"

local WIDTH <const> = 256 -- coordinate value range: [0, WIDTH - 1]
local HEIGHT <const> = 256 -- coordinate value range: [0, HEIGHT - 1]

local roadnet = {}

-- logic axis
-- ┌──►x
-- │
-- │
-- ▼
-- y

-- render axis
-- z
-- ▲
-- │
-- │
-- └──►x

local function __pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function __unpack(coord)
    return coord & 0xFF, coord >> 8
end
---------------------------------------------------------
local function _convert_coord(x, y)
    return x, HEIGHT - y - 1
end

local LAYER_NAMES <const> = {"road", "indicator"}
local SHAPE_TYPES <const> = {"valid", "invalid", "normal", "modify", "remove"}

function roadnet:create()
    iroad:create(WIDTH, HEIGHT, WIDTH//2, LAYER_NAMES, SHAPE_TYPES)
end

-- map = {coord = {x, y, shape_type, shape, dir}, ...}
function roadnet:init(map)
     self._layer_cache = {}
    for _, name in ipairs(LAYER_NAMES) do
        self._layer_cache[name] = {}
    end
    global.roadnet = {} -- = {[coord] = mask, ...}

    local layer_name = LAYER_NAMES[1]
    local res = {}
    for coord, v in pairs(map) do
        local x, y = __unpack(coord)
        self._layer_cache[layer_name][__pack(x, y)] = true

        local dx, dy = _convert_coord(x, y)
        res[#res + 1] = {dx, dy, v[3], v[4], v[5]}
    end
    iroad:init(layer_name, res)
end

function roadnet:clear(layer_name)
    self._layer_cache = self._layer_cache or {}
    for coord in pairs(self._layer_cache[layer_name] or {}) do
        local x, y = __unpack(coord)
        local dx, dy = _convert_coord(x, y)
        iroad:del(layer_name, dx, dy)
    end
    self._layer_cache[layer_name] = {}
end

function roadnet:update()
    iroad:flush()
end

function roadnet:editor_set(layer_name, shape_type, x, y, shape, dir)
    local dx, dy = _convert_coord(x, y)
    iroad:set(layer_name, shape_type, dx, dy, shape, dir)

    self._layer_cache[layer_name] = self._layer_cache[layer_name] or {}
    self._layer_cache[layer_name][__pack(x, y)] = true
end

function roadnet:editor_del(layer_name, x, y)
    local dx, dy = _convert_coord(x, y)
    iroad:del(layer_name, dx, dy)
end

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
    [0] = 'N',
    [1] = 'E',
    [2] = 'S',
    [3] = 'W',
}

function roadnet:editor_build()
    --
    local gameplay_world = gameplay_core.get_world()
    gameplay_world:roadnet_reset(global.roadnet)

    local iendpoint = gameplay.interface "endpoint"
    for e in gameplay_core.select "station:update building:in" do
        local pt = iprototype.queryById(e.building.prototype)
        e.station.endpoint = iendpoint.endpoint_id(gameplay_world, {x = e.building.x, y = e.building.y, dir = DIRECTION[e.building.direction]}, pt)
    end
    for e in gameplay_core.select "lorry_factory:update building:in" do
        local pt = iprototype.queryById(e.building.prototype)
        e.lorry_factory.endpoint = iendpoint.endpoint_id(gameplay_world, {x = e.building.x, y = e.building.y, dir = DIRECTION[e.building.direction]}, pt)
    end

    gameplay_world:build()

    -- TDDO: we should not clear all the lorries directly. We should place them in the corresponding positions of the roadnet as much as possible.
	local lorry_manager = ecs.require "lorry_manager" -- init_system.lua require "lorry_manager" & "roadnet"
    lorry_manager.clear()
end

return roadnet