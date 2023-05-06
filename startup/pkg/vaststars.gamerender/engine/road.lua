local ecs   = ...
local world = ecs.world
local w     = world.w

local iterrain  = ecs.import.interface "mod.terrain|iterrain"
local ism = ecs.import.interface "mod.stonemountain|istonemountain"
local UNIT <const> = 10
local MOUNTAIN = import_package "vaststars.prototype".load("mountain")

local function __pack(x, y)
    assert(x & 0xFF == x and y & 0xFF == y)
    return x | (y<<8)
end

local function __unpack(coord)
    return coord & 0xFF, coord >> 8
end

local road = {}

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
-- map = {{x, y, shape, dir}, ...}
function road:create(width, height, offset, layer_names, shape_types)
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

    --
    ism.create_sm_entity(MOUNTAIN.density, width, height, offset, UNIT, MOUNTAIN.scale, MOUNTAIN.mountain_coords, MOUNTAIN.excluded_rects)
end

function road:get_offset()
    return self._offset[1], self._offset[2]
end

local inner_layer_names = {
    ["road"] = "road",
    ["indicator"] = "mark",
}

local inner_shape = {
    ["valid"] = "2",
    ["invalid"] = "1",

    ["normal"] = "1",
    ["modify"] = "2",
    ["remove"] = "3",
}

-- map = {{x, y, shape_type, shape, dir}, ...}
function road:init(layer_name, map)
    assert(self._offset)
    assert(self.layer_names[layer_name])
    local offset_x, offset_y = self._offset[1], self._offset[2]
    self.cache = {}

    local t = {}
    for _, v in ipairs(map) do
        local x, y, shape_type, shape, dir = v[1], v[2], v[3], v[4], v[5]
        local v = {
            x = x - offset_x,
            y = y - offset_y,
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
    iterrain.create_roadnet_entity(t)
end

-- shape = "I" / "U" / "L" / "T" / "O"
-- dir = "N" / "E" / "S" / "W"
function road:set(layer_name, shape_type, x, y, shape, dir)
    assert(self._offset)
    assert(self.layer_names[layer_name])
    assert(self.shape_types[shape_type])
    local offset_x, offset_y = self._offset[1], self._offset[2]

    local v = self.cache[__pack(x, y)]
    if not v then
        self.cache[__pack(x, y)] = {
            x = x - offset_x,
            y = y - offset_y,
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
    if next(self._update_cache) then
        local update = {}
        local delete = {}
        for coord in pairs(self._update_cache) do
            if next(self.cache[coord].layers) == nil then
                self.cache[coord] = nil
                local x, y = __unpack(coord)
                local dx, dy = x - self._offset[1], y - self._offset[2]
                delete[#delete+1] = {x = dx, y = dy}
            else
                update[#update+1] = self.cache[coord]
            end
        end
        if next(update) then
            iterrain.update_roadnet_entity(update)
        end
        if next(delete) then
            iterrain.delete_roadnet_entity(delete)
        end
        self._update_cache = {}
    end
end

return road