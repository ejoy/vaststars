local ecs   = ...
local world = ecs.world
local w     = world.w

local iterrain  = ecs.import.interface "mod.terrain|iterrain"
local UNIT <const> = 10
local iroad = ecs.import.interface "mod.road|iroad"
local ROAD_WIDTH, ROAD_HEIGHT = 20, 20
local terrain  = ecs.require "terrain"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

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
function road:create(width, height, offset, layer_names, shape_types)
    iroad.set_args(ROAD_WIDTH, ROAD_HEIGHT)

    assert(width == height)
    self._offset = {offset, offset}
    self._update_cache = {}
    self.layer_names = {}
    for _, layer_name in ipairs(layer_names) do
        self.layer_names[layer_name] = true
    end
    self.shape_types = {}
    for _, state in ipairs(shape_types) do
        self.shape_types[state] = true
    end
    iterrain.gen_terrain_field(width, height, offset, UNIT)
end

function road:get_offset()
    return self._offset[1], self._offset[2]
end

local inner_layer_names = {
    ["road"] = "road",
    ["indicator"] = "mark",
}

local inner_shape = {
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
        local x, y, shape_type, shape, dir = v[1], v[2], v[3], v[4], v[5]
        local posx, posy = convertTileToWorld(x, y)
        local v = {
            x = posx,
            y = posy,
            layers = {
                [inner_layer_names[layer_name]] = {
                    type = assert(inner_shape[shape_type]),
                    shape = shape,
                    dir = dir,
                },
            }
        }

        self.cache[__pack(x, y)] = v
        t[#t+1] = v
    end
    iroad.update_roadnet_group(0, t, RENDER_LAYER.ROAD)
end

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
function road:set(layer_name, shape_type, x, y, shape, dir)
    assert(self._offset)
    assert(self.layer_names[layer_name])
    assert(self.shape_types[shape_type])

    local v = self.cache[__pack(x, y)]
    if not v then
        local posx, posy = convertTileToWorld(x, y)
        self.cache[__pack(x, y)] = {
            x = posx,
            y = posy,
            layers = {
                [inner_layer_names[layer_name]] = {
                    type = inner_shape[shape_type],
                    shape = shape,
                    dir = dir,
                },
            }
        }
    else
        v.layers[inner_layer_names[layer_name]] = {
            type = inner_shape[shape_type],
            shape = shape,
            dir = dir,
        }
    end

    self._update_cache[__pack(x, y)] = true
end

function road:del(layer_name, x, y)
    assert(self._offset)
    assert(self.layer_names[layer_name])

    local v = assert(self.cache[__pack(x, y)])
    if v then
        v.layers[inner_layer_names[layer_name]] = nil
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
        iroad.update_roadnet_group(0, t)
    end
end

return road