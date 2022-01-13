local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iconstruct_arrow = ecs.import.interface "vaststars.gamerender|iconstruct_arrow"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"

local ROAD_ARROW_YAXIS_DEFAULT <const> = import_package "vaststars.constant".ROAD_ARROW_YAXIS_DEFAULT
local road_sys = ecs.system "road_system"
local iroad = ecs.interface "iroad"
local pickup_show_set_road_arrow_mb = world:sub {"pickup_mapping", "pickup_show_set_road_arrow"}
local pickup_set_road_mb = world:sub {"pickup_mapping", "pickup_set_road"}
local pickup_mb = world:sub {"pickup"}
local construct_arrows_entity

--[[
                        North:(y + 1):(0, 1)
West:(x - 1):(-1, 0)                             East:(x + 1):(1, 0)
                        South:(y - 1):(0, -1)
--]]
local North <const> = 0
local East  <const> = 1
local South <const> = 2
local West  <const> = 3

local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

local typedir_to_passable_state, passable_state_to_typedir, set_passable_state ; do
    -- 'true' means that the direction is passable
    local passable = {
        ['U'] = {[North] = true,  [East] = false, [South] = false, [West] = false, },
        ['L'] = {[North] = true,  [East] = true,  [South] = false, [West] = false, },
        ['I'] = {[North] = true,  [East] = false, [South] = true , [West] = false, },
        ['T'] = {[North] = false, [East] = true,  [South] = true , [West] = true,  },
        ['X'] = {[North] = true,  [East] = true,  [South] = true , [West] = true,  },
        ['O'] = {[North] = false, [East] = false, [South] = false, [West] = false, },
    }

    local directions = {
        ['U'] = {'N', 'E', 'S', 'W'},
        ['L'] = {'N', 'E', 'S', 'W'},
        ['I'] = {'N', 'E'},
        ['T'] = {'N', 'E', 'S', 'W'},
        ['X'] = {'N'},
        ['O'] = {'N'},
    }

    --
    local accel = {}
    for type_t, v in pairs(passable) do
        for _, dir in ipairs(directions[type_t]) do
            local state = 0
            for b = West, North, -1 do
                state = state << 1
                if v[(b - DIRECTION[dir]) % 4] then
                    state = state | 1
                else
                    state = state | 0
                end
            end
            accel[type_t .. dir] = state
        end
    end

    local accel_reversed = {}
    for typedir, passable_state in pairs(accel) do
        assert(accel_reversed[passable_state] == nil)
        accel_reversed[passable_state] = typedir
    end

    function typedir_to_passable_state(typedir)
        return accel[typedir]
    end

    function passable_state_to_typedir(passable_state)
        return accel_reversed[passable_state]
    end

    function set_passable_state(passable_state, passable_dir)
        return (passable_state | (1 << passable_dir))
    end
end

local prefab_file_path <const> = "/pkg/vaststars.resources/road/road_%s.prefab"
local rotators <const> = {
    [North] = nil,
    [East]  = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    [South] = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    [West]  = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

local function create_entity(typedir, x, y)
    local t = typedir:sub(1, 1)
    local dir = typedir:sub(2, 2)
    local prefab = ecs.create_instance(prefab_file_path:format(t))
    iom.set_position(prefab.root, iterrain.get_position_by_coord({x, y}))
    iom.set_rotation(prefab.root, rotators[DIRECTION[dir]])
    return iprefab_object.create(prefab, {
        policy = {
            "ant.scene|scene_object",
            "vaststars.gamerender|building",
        },
        data = {
            building = {
                building_type = "road",
                tile_coord = {x, y},
                area = {1, 1},
            },
            pickup_show_set_road_arrow = true,
            dir = dir,
        },
    })
end

local function set(types, x, y, passable_dir)
    types[x] = types[x] or {}
    local passable_state = 0
    if not types[x][y] then
        passable_state = 0
    else
        passable_state = typedir_to_passable_state(types[x][y])
    end
    passable_state = set_passable_state(passable_state, passable_dir)

    local typedir = passable_state_to_typedir(passable_state)
    if not typedir then
        assert(false)
        return
    end

    types[x][y] = typedir
end

local function flush(types, entities, x, y)
    entities[x] = entities[x] or {}

    local game_object = entities[x][y]
    if game_object then
        igame_object.remove_prefab(game_object)
    end
    entities[x][y] = create_entity(types[x][y], x, y)
end

local funcs = {}
funcs[West] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, West)
    set(types, dx, dy, East)
end

funcs[East] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, East)
    set(types, dx, dy, West)
end

funcs[North] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, South)
    set(types, dx, dy, North)
end

funcs[South] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, North)
    set(types, dx, dy, South)
end

local get_dir ; do
    local accel = {
        [-1] = {
            [0] = West,
        },
        [0] = {
            [-1] = North,
            [1] = South,
        },
        [1] = {
            [0] = East,
        },
    }

    function get_dir(sx, sy, dx, dy)
        if not accel[dx - sx] then
            return
        end

        return accel[dx - sx][dy - sy]
    end
end

function road_sys:init_world()
    construct_arrows_entity = ecs.create_entity({
        policy = {
            "vaststars.gamerender|construct_arrows",
        },
        data = {
            construct_arrows = {},
            construct_arrows_building_type = "road",
            reference = true,
        }
    })

    ecs.create_entity({
        policy = {
            "vaststars.gamerender|road_data",
        },
        data = {
            road_types = {},
            road_entities = {},
        }
    })
end

function road_sys:after_pickup_mapping()
    local is_show_arrow
    for _, _, game_object in pickup_show_set_road_arrow_mb:unpack() do
        local prefab = igame_object.get_prefab_object(game_object)
        iconstruct_arrow.show(construct_arrows_entity, ROAD_ARROW_YAXIS_DEFAULT, "pickup_set_road", math3d.tovalue(iom.get_position(prefab.root)))
        is_show_arrow = true
    end

    for _ in pickup_mb:unpack() do
        if not is_show_arrow then
            iconstruct_arrow.hide(construct_arrows_entity)
            break
        end
    end

    for _, _, game_object in pickup_set_road_mb:unpack() do
        w:sync("pickup_set_road:in", game_object)
        iroad.construct(game_object.pickup_set_road.tile_coord, game_object.pickup_set_road.arrow_tile_coord)
    end
end

function iroad.construct(tile_coord_s, tile_coord_d)
    local e = w:singleton("road_types", "road_types:in road_entities:in")
    local road_types = e.road_types
    local road_entities = e.road_entities

    local sx, sy
    if tile_coord_s then
        sx = tile_coord_s[1]
        sy = tile_coord_s[2]
    end

    local dx, dy
    dx = tile_coord_d[1]
    dy = tile_coord_d[2]

    -- construct for the first time
    if not sx and not sy then
        road_types[dx] = road_types[dx] or {}
        road_types[dx][dy] = 'ON'
        flush(road_types, road_entities, dx, dy)
        w:sync("road_types:out road_entities:out", e)
        return
    end

    local dir = get_dir(sx, sy, dx, dy)
    if not dir then
        assert(dir)
        return
    end

    local func = funcs[dir]
    if not func then
        assert(func)
        return
    end

    func(road_types, sx, sy, dx, dy)
    flush(road_types, road_entities, sx, sy)
    flush(road_types, road_entities, dx, dy)
    w:sync("road_types:out road_entities:out", e)
end

function iroad.get_road_type(tile_coord)
    local e = w:singleton("road_types", "road_types:in")
    local road_types = e.road_types

    if not road_types[tile_coord[1]] then
        return
    end

    return road_types[tile_coord[1]][tile_coord[2]]
end

function iroad.set_building_entry(tile_coord)
    local e = w:singleton("road_types", "road_types:in road_entities:in")
    local road_types = e.road_types
    local road_entities = e.road_entities

    -- todo hard coded -- North
    set(road_types, tile_coord[1], tile_coord[2] - 1, North)
    flush(road_types, road_entities, tile_coord[1], tile_coord[2] - 1)
    w:sync("road_types:out road_entities:out", e)
end
