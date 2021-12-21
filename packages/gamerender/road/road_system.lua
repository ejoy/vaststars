local ecs = ...
local world = ecs.world
local w = world.w

local iterrain_road = ecs.import.interface "ant.terrain|iterrain_road"
local iprefab_proxy = ecs.import.interface "vaststars.utility|iprefab_proxy"
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local road_path_cfg = import_package "vaststars.config".road_path
local packCoord = require "construct.gameplay_entity.packcoord"
local gameplay = import_package "vaststars.gameplay"

-- 0:> 1:< 2:v 3: ^
local translate_dir ; do
    local counterclockwise = {[2] = 1, [1] = 3, [3] = 0, [0] = 2}

    -- times 表示按顺时针旋转的次数
    local function f(dir, times)
        for i = 1, times do
            dir = counterclockwise[dir]
        end
        return dir
    end

    function translate_dir(in_dir, out_dir, times)
        return f(in_dir, times), f(out_dir, times)
    end
end

local function get_cfg(rode_type, in_dir, out_dir)
    local rt = rode_type:sub(1, 1)
    local times = tonumber(rode_type:sub(2, 2))

    local new_in_dir, new_out_dir = translate_dir(in_dir, out_dir, times)
    if not road_path_cfg[rt] then
        return
    end
    if not road_path_cfg[rt][new_in_dir] then
        return
    end
    return road_path_cfg[rt][new_in_dir][new_out_dir]
end

local function set_gameplay_road(x, y, road_type)
    print("set_gameplay_road", x, y, "rode_type", road_type) -- todo

    local position = packCoord(x, y)
    gameplay.set_road_type(position, road_type)
end

local terrain_road_create_mb = world:sub {"terrain_road", "road", "create"}
local terrain_road_remove_mb = world:sub {"terrain_road", "road", "remove"}

local road_sys = ecs.system "road_system"
local iroad = ecs.interface "iroad"

local road_binding_entity
local terrain_roads_instance_id = {} -- lazy deletion
local terrain_roads_prefab_proxy = {}

local road_tiles = {} -- = {[x] = {[y] = {info}, ...}, ...} -- info 为序列, 分别表示此'路块'在四个方向的'闭'/'开'状态
local road_types = {} -- = {[x] = {[y] = road_type, ...}, ...} -- 缓存每个路块的类型 O,C.. + 数字表示
local LEFT <const> = 4
local RIGHT <const> = 2
local TOP <const> = 3
local BOTTOM <const> = 1
local NEIGHBORS_END <const> = 4

for _, v in ipairs({'C', 'I', 'O', 'T', 'U', 'X'}) do
    iterrain_road.set_road_resource(v, ("/pkg/vaststars.resources/road/%s_road.prefab"):format(v))
end

function road_sys:init()
    road_binding_entity = ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "vaststars.gamerender|building",
        },
        data = {
            scene = {
                srt = {}
            },
            building = {
                building_type = "road",
            },
            reference = true,
        },
    }
end

function road_sys:data_changed()
    for _, _, _, instance_id, x, y, prefab_file_name, srt, parant_entity in terrain_road_create_mb:unpack() do
        local prefab_proxy = iprefab_proxy.create(ecs.create_instance(prefab_file_name),
            srt,
            {},
            {
                on_ready = function(_, prefab)
                    local e = prefab.root
                    iom.set_srt(e, srt.s, srt.r, srt.t)
                    ecs.method.set_parent(e, parant_entity)
                end,
                on_pickup_mapping = function(eid)
                    ipickup_mapping.mapping(eid, road_binding_entity)
                end
            }
        )

        terrain_roads_prefab_proxy[instance_id] = prefab_proxy

        terrain_roads_instance_id[x] = terrain_roads_instance_id[x] or {}
        terrain_roads_instance_id[x][y] = instance_id
    end

    for _, _, _, instance_id in terrain_road_remove_mb:unpack() do
        if terrain_roads_prefab_proxy[instance_id] then
            iprefab_proxy.remove(terrain_roads_prefab_proxy[instance_id])
            terrain_roads_prefab_proxy[instance_id] = nil
        end
    end
end

local get_direction ; do
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

    function get_direction(sx, sy, dx, dy)
        if not accel[dx - sx] then
            return
        end

        return accel[dx - sx][dy - sy]
    end
end

local translate_road_type ; do
    local accel = {}
    local function init(t, dimension)
        if dimension == NEIGHBORS_END then
            return
        end

        for i = 0, 1 do
            t[i] = {}
            init(t[i], dimension + 1)
        end
    end
    init(accel, 1)

    accel[0][0][0][1] = "U0"
    accel[0][0][1][0] = "U1"
    accel[0][0][1][1] = "C2"
    accel[0][1][0][0] = "U2"
    accel[0][1][0][1] = "I0"
    accel[0][1][1][0] = "C3"
    accel[0][1][1][1] = "T2"
    accel[1][0][0][0] = "U3"
    accel[1][0][0][1] = "C1"
    accel[1][0][1][0] = "I1"
    accel[1][0][1][1] = "T1"
    accel[1][1][0][0] = "C0"
    accel[1][1][0][1] = "T0"
    accel[1][1][1][0] = "T3"
    accel[1][1][1][1] = "X0"

    function translate_road_type(road_tile)
        local t = accel
        for i = 1, #road_tile do
            t = t[road_tile[i]]

            if not t then
                return
            end
        end
        return t
    end
end

-- todo 不同类型的'路块'不能相连
local function can_construct(x, y, road_type)
    return true
end

function iroad.reset()
    road_tiles = {}
end

local function __flush_road(shape_terrain_entity, x, y)
    local road_type = road_types[x][y]
    iterrain_road.set_road(shape_terrain_entity, road_type, x, y)
    set_gameplay_road(x, y, road_type)
end

local function __set_road(x, y, ...)
    road_tiles[x] = road_tiles[x] or {}
    road_tiles[x][y] = road_tiles[x][y] or {0, 0, 0, 0}

    for _, direction in ipairs({...}) do
        road_tiles[x][y][direction] = 1
    end

    local road_type = translate_road_type(road_tiles[x][y])
    if not road_type then
        assert(road_type)
        return
    end

    road_types[x] = road_types[x] or {}
    road_types[x][y] = road_type
end

local funcs = {}
funcs[LEFT] = function(sx, sy, dx, dy)
    __set_road(sx, sy, LEFT)
    __set_road(dx, dy, RIGHT)
end

funcs[RIGHT] = function(sx, sy, dx, dy)
    __set_road(sx, sy, RIGHT)
    __set_road(dx, dy, LEFT)
end

funcs[TOP] = function(sx, sy, dx, dy)
    __set_road(sx, sy, BOTTOM)
    __set_road(dx, dy, TOP)
end

funcs[BOTTOM] = function(sx, sy, dx, dy)
    __set_road(sx, sy, TOP)
    __set_road(dx, dy, BOTTOM)
end

function iroad.construct(tile_coord_s, tile_coord_d, road_type)
    local sx, sy
    if tile_coord_s then
        sx = tile_coord_s[1]
        sy = tile_coord_s[2]
    end

    local dx, dy
    dx = tile_coord_d[1]
    dy = tile_coord_d[2]

    if not can_construct(dx, dy, road_type) then
        return
    end

    local shape_terrain_entity = w:singleton("shape_terrain", "shape_terrain:in")
    if not shape_terrain_entity then
        print("Can not found shape_terrain_entity")
        return
    end

    -- 第一次创建路块
    if not sx and not sy then
        road_types[dx] = road_types[dx] or {}
        road_types[dx][dy] = road_type
        iterrain_road.set_road(shape_terrain_entity, road_type, dx, dy)
        set_gameplay_road(dx, dy, road_type)
        return
    end

    local direction = get_direction(sx, sy, dx, dy)
    if not direction then
        -- direction 为 nil 时, 有可能在已有的路块点击箭头
        if sx ~= dx or sy ~= dy then
            print(("x(%s) y(%s)"):format(dx - sy, dy - sy))
            print(("sx(%s) sy(%s) dx(%s) dy(%s)"):format(sx, sy, dx, dy))
        end
        return
    end

    local func = funcs[direction]
    if not func then
        assert(func)
        return
    end

    local shape_terrain_entity
    for e in w:select("shape_terrain:in") do
        shape_terrain_entity = e
    end
    if not shape_terrain_entity then
        assert(shape_terrain_entity)
        return
    end
    func(sx, sy, dx, dy)
    __flush_road(shape_terrain_entity, sx, sy)
    __flush_road(shape_terrain_entity, dx, dy)


end

function iroad.get_road_type(tile_coord)
    if not road_types[tile_coord[1]] then
        return
    end

    return road_types[tile_coord[1]][tile_coord[2]]
end

function iroad.set_building_entry(tile_coord)
    local shape_terrain_entity = w:singleton("shape_terrain", "shape_terrain:in")
    if not shape_terrain_entity then
        print("Can not found shape_terrain_entity")
        return
    end

    -- todo hard coded -- TOP
    __set_road(tile_coord[1], tile_coord[2] - 1, TOP)
    __flush_road(shape_terrain_entity, tile_coord[1], tile_coord[2] - 1)
end

local ltask = require "ltask"
local route_prefabs = {}
local route_idx
local last_route_update = 0

function road_sys:ui_update()
    if not route_idx then
        return
    end
    local _, now = ltask.now()
    if now - last_route_update > 30 then
        last_route_update = now

        if route_idx > 0 then
            local prefab = route_prefabs[route_idx]
            prefab:send("hide")
        end
        route_idx = route_idx + 1
        if route_idx > #route_prefabs then
            route_idx = 1
        end
        local prefab = route_prefabs[route_idx]
        prefab:send("show")
    end
end

local function __show_dir_arrow(tile_coord, in_dir, out_dir)
    local x = tile_coord[1]
    local y = tile_coord[2]

    if not terrain_roads_instance_id[x] then
        return
    end
    local instance_id = terrain_roads_instance_id[x][y]

    if not instance_id then
        return
    end

    local proxy = terrain_roads_prefab_proxy[instance_id]
    if not proxy then
        return
    end

    local road_type = iroad.get_road_type(tile_coord)
    assert(road_type)

    local c = get_cfg(road_type, in_dir, out_dir)
    if not c then
        print("__show_dir_arrow", road_type, in_dir, out_dir)
        return
    end

    local prefab = ecs.create_instance("/pkg/vaststars.resources/" .. c.prefab) -- todo 此处需要缓存 prefab 后续删除
    prefab.on_ready = function(prefab)
        local ifs 		= ecs.import.interface "ant.scene|ifilter_state"
        for _, e in ipairs(prefab.tag['*']) do
            ifs.set_state(e, "main_view", false)
        end
    end
    prefab.on_message = function(prefab, cmd)
        if cmd == "hide" then
            local ifs 		= ecs.import.interface "ant.scene|ifilter_state"
            for _, e in ipairs(prefab.tag['*']) do
                ifs.set_state(e, "main_view", false)
            end
        elseif cmd == "show" then
            local ifs 		= ecs.import.interface "ant.scene|ifilter_state"
            for _, e in ipairs(prefab.tag['*']) do
                ifs.set_state(e, "main_view", true)
            end
        elseif cmd == "remove" then
            prefab:remove()
        end
    end
    route_prefabs[#route_prefabs + 1] = world:create_object(prefab)

    iprefab_proxy.set_slot(proxy, c.slot, prefab.root)
end

-- todo
-- dir : 0: x + 1; 1: x - 1; 2: y + 1; 3: y -1;
local __trans_coord ; do
    local t  = {}
    t[0] = function(coord)
        coord[1] = coord[1] + 1
        return coord
    end
    t[1] = function(coord)
        coord[1] = coord[1] - 1
        return coord
    end
    t[2] = function(coord)
        coord[2] = coord[2] + 1
        return coord
    end
    t[3] = function(coord)
        coord[2] = coord[2] - 1
        return coord
    end
    function __trans_coord(coord, dir)
        local f = assert(t[dir])
        return f(coord)
    end
end

-- starting & ending : coord
-- path : sequence
function iroad.show_route(starting, path)
    local in_2_out = {[1] = 0, [0] = 1, [2] = 3, [3] = 2} -- todo
    local coord = {starting[1], starting[2]}
    local in_dir, out_dir

    route_prefabs = {}
    route_idx = 0
    for _, dir in ipairs(path) do
        if not in_dir then
            in_dir = 2
            out_dir = in_2_out[dir]
        else
            in_dir = in_2_out[in_dir]
            out_dir = in_2_out[dir]
        end
        __show_dir_arrow(coord, in_dir, out_dir)
        coord = __trans_coord(coord, dir)
        in_dir = dir
    end
    __show_dir_arrow(coord, in_2_out[in_dir], in_2_out[2]) -- todo 需要根据建筑物的出口方向来设置参数
end
