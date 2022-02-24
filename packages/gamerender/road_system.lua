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
local igameplay_adapter = ecs.import.interface "vaststars.gamerender|igameplay_adapter"
local iinput = ecs.import.interface "vaststars.input|iinput"
local vector2 = require "vector2"

local road_sys = ecs.system "road_system"
local iroad = ecs.interface "iroad"
local pickup_show_set_road_arrow_mb = world:sub {"pickup_mapping", "pickup_show_set_road_arrow"}
local ui_remove_message_mb = world:sub {"ui", "construct", "click_construct_remove"}
local pickup_mb = world:sub {"pickup"}
local pickup_mapping_canvas_mb = world:sub {"pickup_mapping", "canvas"}
local construct_arrows

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
                if v[(b - DIRECTION[dir]) % 4] then
                    state = state << 1 | 1
                else
                    state = state << 1 | 0
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

    function set_passable_state(passable_state, passable_dir, state)
        if state == 0 then
            return passable_state & ~(1 << passable_dir)
        else
            return passable_state |  (1 << passable_dir)
        end
    end
end

local prefab_file_path <const> = "/pkg/vaststars.resources/prefabs/road/road_%s.prefab"
local rotators <const> = {
    N = nil,
    E = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    S = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    W = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

local function create_game_object(typedir, x, y)
    local t = typedir:sub(1, 1)
    local dir = typedir:sub(2, 2)
    local prefab = ecs.create_instance(prefab_file_path:format(t))
    iom.set_position(prefab.root, iterrain.get_position_by_coord(x, y))
    iom.set_rotation(prefab.root, rotators[dir])
    return iprefab_object.create(prefab, {
        policy = {
            "ant.scene|scene_object",
        },
        data = {
            prototype = ("路1-%s型"):format(t),
            x = x,
            y = y,
            dir = dir,
            area = igameplay_adapter.pack_coord(1, 1),

            building_type = "road",
            pickup_show_set_road_arrow = true,
            pickup_show_remove = false,
        },
    })
end

local function set(typedirs, x, y, passable_dir)
    typedirs[x] = typedirs[x] or {}
    local passable_state = 0
    if not typedirs[x][y] then
        passable_state = 0
    else
        passable_state = typedir_to_passable_state(typedirs[x][y])
    end
    passable_state = set_passable_state(passable_state, passable_dir, 1)

    local typedir = passable_state_to_typedir(passable_state)
    if not typedir then
        assert(false)
        return
    end

    typedirs[x][y] = typedir
end

local function unset(typedirs, x, y, passable_dir)
    typedirs[x] = typedirs[x] or {}
    local passable_state = 0
    if not typedirs[x][y] then
        passable_state = 0
    else
        passable_state = typedir_to_passable_state(typedirs[x][y])
    end
    passable_state = set_passable_state(passable_state, passable_dir, 0)

    local typedir = passable_state_to_typedir(passable_state)
    if not typedir then
        assert(false)
        return
    end

    typedirs[x][y] = typedir
end

local function flush(typedirs, entities, x, y)
    entities[x] = entities[x] or {}

    local game_object = entities[x][y]
    if game_object then
        igame_object.remove_prefab(game_object)
    end
    entities[x][y] = create_game_object(typedirs[x][y], x, y)
    --
    igameplay_adapter.set_road(x, y, typedirs[x][y])
end

local funcs = {}
funcs[West] = function(typedirs, sx, sy, dx, dy)
    set(typedirs, sx, sy, West)
    set(typedirs, dx, dy, East)
end

funcs[East] = function(typedirs, sx, sy, dx, dy)
    set(typedirs, sx, sy, East)
    set(typedirs, dx, dy, West)
end

funcs[North] = function(typedirs, sx, sy, dx, dy)
    set(typedirs, sx, sy, North)
    set(typedirs, dx, dy, South)
end

funcs[South] = function(typedirs, sx, sy, dx, dy)
    set(typedirs, sx, sy, South)
    set(typedirs, dx, dy, North)
end

local get_dir, dir_to_coord ; do
    local dir_accel = {
        [North] = vector2.UP,
        [East] = vector2.RIGHT,
        [South] = vector2.DOWN,
        [West] = vector2.LEFT,
    }

    local accel = {}
    for dir, v in pairs(dir_accel) do
        accel[v[1]] = accel[v[1]] or {}
        accel[v[1]][v[2]] = dir
    end

    function get_dir(sx, sy, dx, dy)
        if not accel[dx - sx] then
            return
        end

        return accel[dx - sx][dy - sy]
    end

    function dir_to_coord(x, y, dir)
        local t = dir_accel[dir]
        return x + t[1], y + t[2]
    end
end

function road_sys:init_world()
    construct_arrows = ecs.create_entity({
        policy = {},
        data = {
            construct_arrows = {},
            reference = true,
        }
    })

    ecs.create_entity({
        policy = {
            "vaststars.gamerender|road_data",
        },
        data = {
            road_typedirs = {},
            road_entities = {},
        }
    })
end

function road_sys:after_pickup_mapping()
    if not construct_arrows then
        return
    end
    w:sync("construct_arrows:in", construct_arrows)

    local is_show_arrow
    for _, _, game_object in pickup_show_set_road_arrow_mb:unpack() do
        local prefab = igame_object.get_prefab_object(game_object)
        iconstruct_arrow.show(construct_arrows, math3d.tovalue(iom.get_position(prefab.root)))
        is_show_arrow = true
    end

    for _ in pickup_mapping_canvas_mb:unpack() do
        local pos = iinput.get_mouse_world_position()
        local coord = iterrain.get_coord_by_position(pos)
        local k = igameplay_adapter.pack_coord(coord[1], coord[2])
        local v = construct_arrows.construct_arrows[k]
        if v then
            iroad.construct(v.tile_coord, v.arrow_coord)
        end
    end

    for _ in pickup_mb:unpack() do
        if not is_show_arrow then
            iconstruct_arrow.hide(construct_arrows)
        end
        break
    end
end

function road_sys:ui_update()
    for _ in ui_remove_message_mb:unpack() do
        for game_object in w:select("pickup_show_remove:in pickup_show_set_road_arrow:in x:in y:in") do
            if game_object and game_object.pickup_show_remove then
                iroad.dismantle(game_object.x, game_object.y)
            end
        end
    end
end

function iroad.dismantle(x, y)
    local e = w:singleton("road_typedirs", "road_typedirs:in road_entities:in")
    local road_typedirs = e.road_typedirs
    local road_entities = e.road_entities

    assert(road_typedirs[x])
    assert(road_typedirs[x][y])

    local t = {}
    for _, dir in pairs(DIRECTION) do
        local dx, dy = dir_to_coord(x, y, dir)
        if road_typedirs[dx] and road_typedirs[dx][dy] then
            t[#t+1] = {dx, dy}
            unset(road_typedirs, dx, dy, (dir + 2) % 4 )
        end
    end

    for _, v in ipairs(t) do
        flush(road_typedirs, road_entities, v[1], v[2])
    end

    local game_object = road_entities[x][y]
    w:sync("area:in", game_object)
    iterrain.set_tile_building_type({x, y}, nil, game_object.area)
    igame_object.remove_prefab(game_object)
    igameplay_adapter.remove_entity(game_object.x, game_object.y)

    road_entities[x][y] = nil
    road_typedirs[x][y] = nil

    w:sync("road_typedirs:out road_entities:out", e)

    iconstruct_arrow.hide(construct_arrows)
end

function iroad.construct(coord_s, coord_d)
    local e = w:singleton("road_typedirs", "road_typedirs:in road_entities:in")
    local road_typedirs = e.road_typedirs
    local road_entities = e.road_entities

    local sx, sy
    if coord_s then
        sx = coord_s[1]
        sy = coord_s[2]
    end

    local dx, dy
    dx = coord_d[1]
    dy = coord_d[2]

    -- construct for the first time
    if not sx and not sy then
        road_typedirs[dx] = road_typedirs[dx] or {}
        road_typedirs[dx][dy] = 'ON'
        flush(road_typedirs, road_entities, dx, dy)
        w:sync("road_typedirs:out road_entities:out", e)
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

    func(road_typedirs, sx, sy, dx, dy)
    flush(road_typedirs, road_entities, sx, sy)
    flush(road_typedirs, road_entities, dx, dy)
    w:sync("road_typedirs:out road_entities:out", e)
end

function iroad.get_road_type(coord)
    local e = w:singleton("road_typedirs", "road_typedirs:in")
    local road_typedirs = e.road_typedirs

    if not road_typedirs[coord[1]] then
        return
    end

    return road_typedirs[coord[1]][coord[2]]
end

function iroad.set_building_entry(coord, dir)
    local e = w:singleton("road_typedirs", "road_typedirs:in road_entities:in")
    local road_typedirs = e.road_typedirs
    local road_entities = e.road_entities

    set(road_typedirs, coord[1], coord[2], DIRECTION[dir])
    flush(road_typedirs, road_entities, coord[1], coord[2])
    w:sync("road_typedirs:out road_entities:out", e)
end
