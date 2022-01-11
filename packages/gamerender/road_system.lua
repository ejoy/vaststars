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
           2:(y + 1)
1:(x - 1)             0:(x + 1)
           3:(y - 1)
--]]
local RIGHT  <const> = 0 -- x + 1  > -- North
local LEFT   <const> = 1 -- x - 1  < -- East
local TOP    <const> = 2 -- y + 1  v -- South
local BOTTOM <const> = 3 -- y - 1  ^ -- West

local type_to_passable_state, passable_state_to_type, set_passable_state ; do
    -- 'true' means that the direction is passable
    local passable = {}
    passable["U0"] = {[RIGHT] = false, [LEFT] = true,  [TOP] = false, [BOTTOM] = false}
    passable["U1"] = {[RIGHT] = false, [LEFT] = false, [TOP] = true,  [BOTTOM] = false}
    passable["U2"] = {[RIGHT] = true,  [LEFT] = false, [TOP] = false, [BOTTOM] = false}
    passable["U3"] = {[RIGHT] = false, [LEFT] = false, [TOP] = false, [BOTTOM] = true}

    passable["C0"] = {[RIGHT] = true,  [LEFT] = false, [TOP] = false, [BOTTOM] = true}
    passable["C1"] = {[RIGHT] = false, [LEFT] = true,  [TOP] = false, [BOTTOM] = true}
    passable["C2"] = {[RIGHT] = false, [LEFT] = true,  [TOP] = true,  [BOTTOM] = false}
    passable["C3"] = {[RIGHT] = true,  [LEFT] = false, [TOP] = true,  [BOTTOM] = false}

    passable["I0"] = {[RIGHT] = true,  [LEFT] = true,  [TOP] = false, [BOTTOM] = false}
    passable["I1"] = {[RIGHT] = false, [LEFT] = false, [TOP] = true,  [BOTTOM] = true}

    passable["T0"] = {[RIGHT] = true,  [LEFT] = true,  [TOP] = false, [BOTTOM] = true}
    passable["T1"] = {[RIGHT] = false, [LEFT] = true,  [TOP] = true,  [BOTTOM] = true}
    passable["T2"] = {[RIGHT] = true,  [LEFT] = true,  [TOP] = true,  [BOTTOM] = false}
    passable["T3"] = {[RIGHT] = true,  [LEFT] = false, [TOP] = true,  [BOTTOM] = true}

    passable["X0"] = {[RIGHT] = true,  [LEFT] = true,  [TOP] = true,  [BOTTOM] = true}

    passable["O0"] = {[RIGHT] = false, [LEFT] = false, [TOP] = false, [BOTTOM] = false}

    --
    local accel = {}
    for t, v in pairs(passable) do
        local r = 0
        for i = BOTTOM, RIGHT, -1 do
            r = r << 1
            if v[i] then
                r = r | 1
            else
                r = r | 0
            end
        end
        assert(accel[t] == nil)
        accel[t] = r
    end

    local accel_reversed = {}
    for k, v in pairs(accel) do
        if not accel_reversed[v] then
            accel_reversed[v] = k
        end
    end

    function type_to_passable_state(t)
        return accel[t]
    end

    function passable_state_to_type(passable_state)
        return accel_reversed[passable_state]
    end

    function set_passable_state(passable_state, dir)
        return (passable_state | (1 << dir))
    end
end

local prefab_names = {
    ['U'] = "/pkg/vaststars.resources/road/road_U.prefab",
    ['C'] = "/pkg/vaststars.resources/road/road_C.prefab",
    ['I'] = "/pkg/vaststars.resources/road/road_I.prefab",
    ['T'] = "/pkg/vaststars.resources/road/road_T.prefab",
    ['X'] = "/pkg/vaststars.resources/road/road_X.prefab",
    ['O'] = "/pkg/vaststars.resources/road/road_O.prefab",
}

local rotators <const> = {
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

local function create_entity(type_t, x, y)
    local tt = type_t:sub(1, 1)
    local rr = type_t:sub(2, 2)

    local prefab = ecs.create_instance(prefab_names[tt])
    iom.set_position(prefab.root, iterrain.get_position_by_coord({x, y}))
    iom.set_rotation(prefab.root, rotators[rr:byte() - ('0'):byte()])
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
        },
    })
end

local function set(types, x, y, dir)
    types[x] = types[x] or {}
    local passable_state = 0
    if not types[x][y] then
        passable_state = 0
    else
        passable_state = type_to_passable_state(types[x][y])
    end
    passable_state = set_passable_state(passable_state, dir)

    local type_t = passable_state_to_type(passable_state)
    if not type_t then
        assert(type_t)
        return
    end

    types[x][y] = type_t
end

local function flush(types, entities, x, y)
    entities[x] = entities[x] or {}

    local game_object = entities[x][y]
    if game_object then
        igame_object.get_prefab_object(game_object):remove()
    end
    entities[x][y] = create_entity(types[x][y], x, y)
end

local funcs = {}
funcs[LEFT] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, LEFT)
    set(types, dx, dy, RIGHT)
end

funcs[RIGHT] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, RIGHT)
    set(types, dx, dy, LEFT)
end

funcs[TOP] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, BOTTOM)
    set(types, dx, dy, TOP)
end

funcs[BOTTOM] = function(types, sx, sy, dx, dy)
    set(types, sx, sy, TOP)
    set(types, dx, dy, BOTTOM)
end

local get_dir ; do
    local accel = {
        [-1] = {
            [0] = LEFT,
        },
        [0] = {
            [-1] = TOP,
            [1] = BOTTOM,
        },
        [1] = {
            [0] = RIGHT,
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

-- road_type nil
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
        road_types[dx][dy] = "O0"
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

    -- todo hard coded -- TOP
    set(road_types, tile_coord[1], tile_coord[2] - 1, TOP)
    flush(road_types, road_entities, tile_coord[1], tile_coord[2] - 1)
    w:sync("road_types:out road_entities:out", e)
end
