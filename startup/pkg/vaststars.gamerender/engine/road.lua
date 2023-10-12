local ecs   = ...
local world = ecs.world
local w     = world.w

local iterrain  = ecs.require "ant.landform|terrain_system"
local CONST<const> = require "gameplay.interface.constant"
local UNIT <const> = CONST.TILE_SIZE

local iroad = ecs.require "ant.landform|road"

local ROAD_SIZE<const> = 2
local ROAD_WIDTH, ROAD_HEIGHT = ROAD_SIZE * UNIT, ROAD_SIZE * UNIT
local terrain  = ecs.require "terrain"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

--x, y base 0
local function __pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function convertTileToWorld(x, y)
    local pos = terrain:get_begin_position_by_coord(x, y, 1, 1)
    return pos[1], pos[3] - ROAD_HEIGHT
end

local road = {}

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
-- map = {{x, y, shape, dir}, ...}
function road:create(width, height, offset, layer_names, shape_states)
    iroad.set_args(ROAD_WIDTH, ROAD_HEIGHT)

    assert(width == height)
    self._offset = {offset, offset}
    self._update_cache = {}
    self.layer_names = {}
    for _, layer_name in ipairs(layer_names) do
        self.layer_names[layer_name] = true
    end
    self.shape_states = {}
    for _, state in ipairs(shape_states) do
        self.shape_states[state] = true
    end
    iterrain.gen_terrain_field(width, height, offset, TILE_SIZE, RENDER_LAYER.TERRAIN)
end

function road:get_offset()
    return self._offset[1], self._offset[2]
end

local INNER_SHAPE_STATES<const> = {
    ["invalid"] = "1",
    ["valid"] = "2",

    ["normal"] = "1",
    ["remove"] = "2",
    ["modify"] = "3",
}

-- map = {{x, y, shape_type, shape, dir}, ...}
function road:init(layer_name, map)
    assert(self._offset)
    assert(self.layer_names[layer_name])
    self.cache = {}

    local t = {}
    for _, v in ipairs(map) do
        local x, y, state, shape, dir = v[1], v[2], v[3], v[4], v[5]
        local posx, posy = convertTileToWorld(x, y)
        local v = {
            x = posx,
            y = posy,
            layers = {
                [layer_name] = {
                    state   = assert(INNER_SHAPE_STATES[state]),
                    shape   = shape,
                    dir     = dir,
                },
            }
        }

        self.cache[iprototype.packcoord(x, y)] = v
        t[#t+1] = v
    end
    iroad.update_roadnet_group(0, t, RENDER_LAYER.ROAD)
end

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
function road:set(layer_name, shape_state, x, y, shape, dir)
    assert(self._offset)
    assert(self.layer_names[layer_name])
    assert(self.shape_states[shape_state])

    local v = self.cache[iprototype.packcoord(x, y)]
    if not v then
        local posx, posy = convertTileToWorld(x, y)
        self.cache[iprototype.packcoord(x, y)] = {
            x = posx,
            y = posy,
            layers = {
                [INNER_LAYER_NAMES[layer_name]] = {
                    type = INNER_SHAPE_STATES[shape_state],
                    shape = shape,
                    dir = assert(dir),
                },
            }
        }
    else
        v.layers[INNER_LAYER_NAMES[layer_name]] = {
            type = INNER_SHAPE_STATES[shape_type],
            shape = shape,
            dir = assert(dir),
        }
    end

    self._update_cache[iprototype.packcoord(x, y)] = true
end

function road:del(layer_name, x, y)
    assert(self._offset)
    assert(self.layer_names[layer_name])

    local v = assert(self.cache[iprototype.packcoord(x, y)])
    if v then
        v.layers[INNER_LAYER_NAMES[layer_name]] = nil
        self._update_cache[__pack(x, y)] = true
    end
end

function road:flush()
    if not self._update_cache then
        return
    end
    if next(self._update_cache) then
        for coord in pairs(self._update_cache) do
            if not self.cache[coord] or next(self.cache[coord].layers) == nil then
                self.cache[coord] = nil
            end
        end
        self._update_cache = {}

        local t = {}
        for _, v in pairs(self.cache) do
            t[#t+1] = v
        end
        iroad.update_roadnet_group(0, t, RENDER_LAYER.ROAD)
    end
end

return road