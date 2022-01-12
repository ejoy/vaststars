local ecs = ...
local world = ecs.world
local w = world.w

local create_gameplay_world = import_package "vaststars.gameplay".createWorld
local gameplay_adapter_system = ecs.system "gameplay_adapter_system"
local igameplay_adapter = ecs.interface "igameplay_adapter"

local function packCoord(x, y)
    return x | (y<<8)
end
local function unpackCoord(v)
    return v >> 8, v & 0xFF
end

function gameplay_adapter_system:init_world()
    ecs.create_entity({
        policy = {
            "vaststars.gamerender|gameplay_adapter",
        },
        data = {
            gameplay_world = create_gameplay_world(),
            gameplay_road_entitys = {},
        }
    })
end

function gameplay_adapter_system:data_changed()
    local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in")
    if gameplay_adapter then
        gameplay_adapter.gameplay_world:update()
    end
end

function igameplay_adapter.set_road(x, y, road_type)
    local position = packCoord(x, y)

    local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in gameplay_road_entitys:in")
    local e = gameplay_adapter.gameplay_road_entitys[position]
    if e then
        w:remove(e)
    end

    local ref = {}
    w:new {
        road = {
            position = position,
            road_type = packCoord(road_type:sub(1, 1), tonumber(road_type:sub(2, 2))),
        },
        reference = ref,
    }
    gameplay_adapter.gameplay_road_entitys[position] = ref
end
