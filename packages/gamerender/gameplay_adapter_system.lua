local ecs = ...
local world = ecs.world
local w = world.w

local create_gameplay_world = import_package "vaststars.gameplay".createWorld
local set_road_mb = world:sub {"gameplay_adapter_system", "set_road"}
local gameplay_adapter_system = ecs.system "gameplay_adapter_system"
local igameplay_adapter = ecs.interface "igameplay_adapter"

local function packCoord(x, y)
    return x | (y<<8)
end

function gameplay_adapter_system:init_world()
    ecs.create_entity({
        policy = {
            "vaststars.gamerender|gameplay_adapter",
        },
        data = {
            gameplay_world = create_gameplay_world(),
            gameplay_road_entities = {},
        }
    })
end

function gameplay_adapter_system:data_changed()
    local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in")
    if not gameplay_adapter then
        return
    end

    gameplay_adapter.gameplay_world:update()
end

function gameplay_adapter_system:entity_ready()
    local gameplay_adapter = w:singleton("gameplay_world", "gameplay_world:in gameplay_road_entities:in")
    if not gameplay_adapter then
        return
    end

    local gameplay_ecs = gameplay_adapter.gameplay_world.ecs

    for _, _, coord, road_type in set_road_mb:unpack() do
        local e = gameplay_adapter.gameplay_road_entities[coord]
        if e then
            gameplay_ecs:remove(e)
        end

        local ref = {}
        gameplay_ecs:new {
            road = {
                coord = coord,
                road_type = road_type,
            },
            reference = ref,
        }
        gameplay_adapter.gameplay_road_entities[coord] = ref
    end
end

function igameplay_adapter.set_road(x, y, road_type)
    local t = {
        ['N'] = 0,
        ['E'] = 1,
        ['S'] = 2,
        ['W'] = 3,
    }

    local tr = {
        ['L'] = 0,
        ['I'] = 1,
        ['U'] = 2,
        ['T'] = 3,
        ['X'] = 4,
        ['O'] = 5,
    }

    local coord = packCoord(x, y)
    world:pub {"gameplay_adapter_system", "set_road", coord, tr[road_type:sub(1, 1)] << 8 | t[road_type:sub(2, 2)]}
end

function igameplay_adapter.create_entity(entity)
    local e = w:singleton("gameplay_world", "gameplay_world:in")
    if not e then
        log.error("failed to create entity")
        return
    end
    e.gameplay_world.ecs:new(entity)
end

function igameplay_adapter.world_caller(funcname, ...)
    local e = w:singleton("gameplay_world", "gameplay_world:in")
    if not e then
        log.error("failed to create entity")
        return
    end

    local world = e.gameplay_world
    return world[funcname](world, ...)
end

function igameplay_adapter.pack_coord(x, y)
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y << 8)
end