local ecs = ...
local world = ecs.world
local w = world.w

local iterrain_road = ecs.import.interface "ant.terrain|iterrain_road"
local iroad = ecs.interface "iroad"

local road_tiles = {} -- = {[x] = {[y] = {info}, ...}, ...} -- info 为序列, 分别表示此'路块'在四个方向的'闭'/'开'状态
local road_types = {} -- = {[x] = {[y] = road_type, ...}, ...} -- 缓存每个路块的类型 O,C.. + 数字表示
local LEFT <const> = 4
local RIGHT <const> = 2
local TOP <const> = 3
local BOTTOM <const> = 1
local NEIGHBORS_END <const> = 4

for _, v in ipairs({'C', 'I', 'O', 'T', 'U', 'X'}) do
    iterrain_road.set_road_resource(v, ("/pkg/vaststars/res/road/%s_road.prefab"):format(v))
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

local function set_road(shape_terrain_entity, x, y, ...)
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

    if not shape_terrain_entity.scene then
        w:sync("scene:in", shape_terrain_entity)
    end
    iterrain_road.set_road(shape_terrain_entity, road_type, x, y)

    road_types[x] = road_types[x] or {}
    road_types[x][y] = road_type
end

local funcs = {}
funcs[LEFT] = function(shape_terrain_entity, sx, sy, dx, dy)
    set_road(shape_terrain_entity, sx, sy, LEFT)
    set_road(shape_terrain_entity, dx, dy, RIGHT)
end

funcs[RIGHT] = function(shape_terrain_entity, sx, sy, dx, dy)
    set_road(shape_terrain_entity, sx, sy, RIGHT)
    set_road(shape_terrain_entity, dx, dy, LEFT)
end

funcs[TOP] = function(shape_terrain_entity, sx, sy, dx, dy)
    set_road(shape_terrain_entity, sx, sy, BOTTOM)
    set_road(shape_terrain_entity, dx, dy, TOP)
end

funcs[BOTTOM] = function(shape_terrain_entity, sx, sy, dx, dy)
    set_road(shape_terrain_entity, sx, sy, TOP)
    set_road(shape_terrain_entity, dx, dy, BOTTOM)
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

    local shape_terrain_entity
    for e in w:select("shape_terrain:in") do
        shape_terrain_entity = e
    end

    -- 第一次创建路块
    if not sx and not sy then
        iterrain_road.set_road(shape_terrain_entity, road_type, dx, dy)
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
    func(shape_terrain_entity, sx, sy, dx, dy)
end

function iroad.get_road_type(tile_coord)
    if not road_types[tile_coord[1]] then
        return
    end

    return road_types[tile_coord[1]][tile_coord[2]]
end
