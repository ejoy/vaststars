local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local iconstruct_arrow = ecs.import.interface "vaststars.gamerender|iconstruct_arrow"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local mathpkg=import_package "ant.math"
local mc    = mathpkg.constant

local pipe_sys = ecs.system "pipe_system"
local ipipe = ecs.interface "ipipe"
local pickup_show_set_pipe_arrow_mb = world:sub {"pickup_mapping", "pickup_show_set_pipe_arrow"}
local pickup_set_pipe_mb = world:sub {"pickup_mapping", "pickup_set_pipe"}
local pickup_mb = world:sub {"pickup"}
local pipe_construct_arrows_entity

--[[
           2:(y + 1)
1:(x - 1)             0:(x + 1)
           3:(y - 1)
--------------------------------
--]]
local RIGHT  <const> = 0 -- x + 1  > -- North
local LEFT   <const> = 1 -- x - 1  < -- East
local TOP    <const> = 2 -- y + 1  v -- South
local BOTTOM <const> = 3 -- y - 1  ^ -- West

local rotators <const> = {
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

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

    passable["E0"] = {[RIGHT] = true,  [LEFT] = true,  [TOP] = false, [BOTTOM] = false}
    passable["E1"] = {[RIGHT] = false, [LEFT] = false, [TOP] = true,  [BOTTOM] = true}

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
    ['U'] = "/pkg/vaststars.resources/pipe/pipe_U.prefab",
    ['C'] = "/pkg/vaststars.resources/pipe/pipe_C.prefab",
    ['I'] = "/pkg/vaststars.resources/pipe/pipe_I.prefab",
    ['T'] = "/pkg/vaststars.resources/pipe/pipe_T.prefab",
    ['X'] = "/pkg/vaststars.resources/pipe/pipe_X.prefab",
    ['O'] = "/pkg/vaststars.resources/pipe/pipe_O.prefab",
    ['E'] = "/pkg/vaststars.resources/pipe/pipe_E.prefab",
}

local function create_entity(pipe_type, x, y)
    local tt = pipe_type:sub(1, 1)
    local rr = pipe_type:sub(2, 2)

    local prefab = ecs.create_instance(prefab_names[tt])
    iom.set_position(prefab.root, iterrain.get_position_by_coord({x, y}))
    iom.set_rotation(prefab.root, rotators[rr:byte() - ('0'):byte()])
    return iprefab_object.create(prefab, {
        policy = {
            "ant.scene|scene_object",
            "vaststars.gamerender|building",
        },
        data = {
            scene = {
                srt = {}
            },
            building = {
                building_type = "pipe",
                tile_coord = {x, y},
                size = {1, 1},
            },
            reference = true,
            pickup_show_set_pipe_arrow = true,
        },
    })
end

local function flush(pipe_types, pipe_entities, x, y)
    pipe_entities[x] = pipe_entities[x] or {}

    local game_object = pipe_entities[x][y]
    if game_object then
        igame_object.get_prefab_object(game_object):remove()
    end
    pipe_entities[x][y] = create_entity(pipe_types[x][y], x, y)
end

local function set(pipe_types, x, y, ...)
    pipe_types[x] = pipe_types[x] or {}
    local conn_state = 0
    if not pipe_types[x][y] then
        conn_state = 0
    else
        conn_state = type_to_passable_state(pipe_types[x][y])
    end

    for _, dir in ipairs({...}) do
        conn_state = set_passable_state(conn_state, dir)
    end

    local pipe_type = passable_state_to_type(conn_state)
    if not pipe_type then
        assert(pipe_type)
        return
    end

    pipe_types[x][y] = pipe_type
end

local funcs = {}
funcs[LEFT] = function(pipe_types, sx, sy, dx, dy)
    set(pipe_types, sx, sy, LEFT)
    set(pipe_types, dx, dy, RIGHT)
end

funcs[RIGHT] = function(pipe_types, sx, sy, dx, dy)
    set(pipe_types, sx, sy, RIGHT)
    set(pipe_types, dx, dy, LEFT)
end

funcs[TOP] = function(pipe_types, sx, sy, dx, dy)
    set(pipe_types, sx, sy, BOTTOM)
    set(pipe_types, dx, dy, TOP)
end

funcs[BOTTOM] = function(pipe_types, sx, sy, dx, dy)
    set(pipe_types, sx, sy, TOP)
    set(pipe_types, dx, dy, BOTTOM)
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

local check_neighbors ; do
    local accel = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
    function check_neighbors(pipe_types, sx, sy)
        local dx, dy
        for _, v in ipairs(accel) do
            dx, dy = sx + v[1], sy + v[2]
            if pipe_types[dx] and pipe_types[dx][dy] then
                if pipe_types[dx][dy]:sub(1, 1) == 'E' then
                    return false
                end
            end
        end
        return true
    end
end

function ipipe.construct(coord_s, coord_d)
    local e = w:singleton("pipe_types", "pipe_types:in pipe_entities:in")
    local pipe_entities = e.pipe_entities
    local pipe_types = e.pipe_types

    local sx, sy
    if coord_s then
        sx = coord_s[1]
        sy = coord_s[2]
    end

    local dx, dy
    dx = coord_d[1]
    dy = coord_d[2]

    -- construct pipe for the first time
    if not sx and not sy then
        pipe_types[dx] = pipe_types[dx] or {}
        pipe_types[dx][dy] = "O0"
        flush(pipe_types, pipe_entities, dx, dy)
        w:sync("pipe_types:out pipe_entities:out", e)
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

    func(pipe_types, sx, sy, dx, dy)

    --
    local pt1 = pipe_types[sx][sy]
    if pt1:sub(1, 1) == 'I' and check_neighbors(pipe_types, sx, sy) then
        pipe_types[sx][sy] = ('E%s'):format(pt1:sub(2, 2))
    end

    flush(pipe_types, pipe_entities, sx, sy)
    flush(pipe_types, pipe_entities, dx, dy)
    w:sync("pipe_types:out pipe_entities:out", e)
end

function pipe_sys:init_world()
    pipe_construct_arrows_entity = ecs.create_entity({
        policy = {
            "vaststars.gamerender|construct_arrows",
        },
        data = {
            construct_arrows = {},
            construct_arrows_building_type = "pipe",
            reference = true,
        }
    })

    ecs.create_entity({
        policy = {
            "vaststars.gamerender|pipe_data",
        },
        data = {
            pipe_types = {},
            pipe_entities = {},
            reference = true,
        }
    })
end

function pipe_sys:after_pickup_mapping()
    local is_show_arrow
    for _, _, game_object in pickup_show_set_pipe_arrow_mb:unpack() do
        local prefab = igame_object.get_prefab_object(game_object)
        iconstruct_arrow.show(pipe_construct_arrows_entity, "pickup_set_pipe", math3d.tovalue(iom.get_position(prefab.root)))
        is_show_arrow = true
    end

    for _ in pickup_mb:unpack() do
        if not is_show_arrow then
            iconstruct_arrow.hide(pipe_construct_arrows_entity)
            break
        end
    end

    for _, _, game_object in pickup_set_pipe_mb:unpack() do
        w:sync("pickup_set_pipe:in", game_object)
        ipipe.construct(game_object.pickup_set_pipe.tile_coord, game_object.pickup_set_pipe.arrow_tile_coord) -- add gameplay entity in system
    end
end
