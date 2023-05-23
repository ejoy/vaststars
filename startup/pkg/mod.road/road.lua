local ecs   = ...
local world = ecs.world
local w     = world.w
local iroad  = ecs.interface "iroad"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local fs        = require "filesystem"
local datalist  = require "datalist"
local init_system = ecs.system "init_system"
local renderpkg = import_package "ant.render"
local declmgr   = renderpkg.declmgr
local bgfx      = require "bgfx"
local math3d    = require "math3d"
local layout_name<const>    = declmgr.correct_layout "p3|t20|t21|t22|t23"
local layout                = declmgr.get(layout_name)
local width, height, offset, unit = 256, 256, 128, 10
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local road_material
local road_table = {}

local TERRAIN_TYPES<const> = {
    road1 = "1",
    road2 = "2",
    road3 = "3",
    mark1 = "4",
    mark2 = "5",
    mark3 = "6"
}

local TERRAIN_DIRECTIONS<const> = {
    N = "1",
    E = "2",
    S = "3",
    W = "4",
}

local function parse_terrain_type_dir(layers, tname)
    local type, shape, dir = tname..layers[tname].type, layers[tname].shape, layers[tname].dir
    local t<const> = assert(TERRAIN_TYPES[type])
    local s<const> = shape or "D"
    local d<const> = assert(TERRAIN_DIRECTIONS[dir])
    return ("%s%s%s"):format(t, s, d)
end

local function calc_tf_idx(ix, iy)
    return iy * width + ix + 1
end

local function parse_layer(t, s, d)
    local pt, ps, pd
    local u_table = {["1"] = 0, ["2"]= 90, ["3"] = 180, ["4"] = 270}
    local i_table = {["1"] = 90, ["2"]= 0, ["3"] = 270, ["4"] = 180}
    local l_table = {["1"] = 180, ["2"]= 270, ["3"] = 0, ["4"] = 90}
    if s == "U" then
        ps, pd = 0, u_table[d]
    elseif s == "I" then
        ps, pd = 1, i_table[d]
    elseif s == "L" then
        ps, pd = 2, l_table[d]
    elseif s == "T" then
        ps, pd = 3, u_table[d]
    elseif s == "X" then
        ps, pd = 4, 0
    elseif s == 'O' then    
        ps, pd = 5, 0
    else
        ps, pd = 6, 0
    end
    pt = t
    return pt, ps, pd                          
end

local direction_table ={
    [0]   = {0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0},
    [90]  = {1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0},
    [180] = {1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0},
    [270] = {0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0}
}

local function get_road_mark_coord(rd, rd_idx, md, md_idx)
    local t1x, t1y, t7x, t7y
    if rd == nil then
        t1x, t1y = direction_table[0][rd_idx * 2 + 1], direction_table[0][rd_idx * 2 + 2]
    else
        t1x, t1y = direction_table[rd][rd_idx * 2 + 1], direction_table[rd][rd_idx * 2 + 2]
    end
    if md == nil then
        t7x, t7y = direction_table[0][md_idx * 2 + 1], direction_table[0][md_idx * 2 + 2]
    else
        t7x, t7y = direction_table[md][md_idx * 2 + 1], direction_table[md][md_idx * 2 + 2]
    end
    return t1x, t1y, t7x, t7y
end

local NUM_QUAD_VERTICES<const> = 4

local function build_ib(max_plane)
    do
        local planeib = {}
        planeib = {
            0, 1, 2,
            2, 3, 0,
        }
        local fmt<const> = ('I'):rep(#planeib)
        local s = #fmt * 4


        local m = bgfx.memory_buffer(s * max_plane)
        for i=1, max_plane do
            local mo = s * (i - 1) + 1
            m[mo] = fmt:pack(table.unpack(planeib))
            for ii = 1, #planeib do
                planeib[ii]  = planeib[ii] + NUM_QUAD_VERTICES
            end
        end
        return bgfx.create_index_buffer(m, "d")
    end
end

local function to_mesh_buffer(vb, ib_handle, aabb)
    local vbbin = table.concat(vb, "")
    local numv = #vbbin // layout.stride
    local numi = (numv // NUM_QUAD_VERTICES) * 6 --6 for one quad 2 triangles and 1 triangle for 3 indices

    return {
        bounding = {aabb = aabb and math3d.ref(aabb) or nil},
        vb = {
            start = 0,
            num = numv,
            handle = bgfx.create_vertex_buffer(bgfx.memory_buffer(vbbin), layout.handle),
        },
        ib = {
            start = 0,
            num = numi,
            handle = ib_handle,
        }
    }
end

local function build_mesh(road)
    local packfmt<const> = "fffffffffff"
    local t0x0, t0y0, t1x0, t1y0 = get_road_mark_coord(road.road_direction, 0, road.mark_direction, 0)
    local t0x1, t0y1, t1x1, t1y1 = get_road_mark_coord(road.road_direction, 1, road.mark_direction, 1)
    local t0x2, t0y2, t1x2, t1y2 = get_road_mark_coord(road.road_direction, 2, road.mark_direction, 2)
    local t0x3, t0y3, t1x3, t1y3 = get_road_mark_coord(road.road_direction, 3, road.mark_direction, 3)
    local x, y = road.x, road.y
    local ox, oz = x * unit, y * unit
    local nx, nz = ox + unit, oz + unit
    local vb = {
        packfmt:pack(ox, 0, oz, t0x0, t0y0, t1x0, t1y0, road.road_type, road.road_shape, road.mark_type, road.mark_shape),
        packfmt:pack(ox, 0, nz, t0x1, t0y1, t1x1, t1y1, road.road_type, road.road_shape, road.mark_type, road.mark_shape),
        packfmt:pack(nx, 0, nz, t0x2, t0y2, t1x2, t1y2, road.road_type, road.road_shape, road.mark_type, road.mark_shape),
        packfmt:pack(nx, 0, oz, t0x3, t0y3, t1x3, t1y3, road.road_type, road.road_shape, road.mark_type, road.mark_shape),        
    }
    local ib_handle = build_ib(1)
    local aabb_min, aabb_max = math3d.vector(ox, 0, oz), math3d.vector(nx, 0, nz)
    local aabb = math3d.aabb(aabb_min, aabb_max)
    return to_mesh_buffer(vb, ib_handle, aabb)
end


local function create_road(road)
    local layers = road.layers
    if not layers[1] then road.road_type, road.road_shape = 0, 0 end -- 0 not road 1 road 2 stop 3 building
    if not layers[2] then road.mark_type, road.mark_shape = 0, 0 end -- 0 not mark 1 red 2 white
    for i, layer in pairs(layers) do
        local t, s, d
        t = string.sub(layer, 1, 1)
        s = string.sub(layer, 2, 2)
        d = string.sub(layer, 3, 3)
        local pt, ps, pd = parse_layer(t, s, d)
        if i == 1 then
            road.road_type = pt - 0
            road.road_direction = pd
            road.road_shape = ps
        elseif i == 2 then
            road.mark_type = pt - 3
            road.mark_direction = pd
            road.mark_shape = ps
        end
    end
    local road_mesh = build_mesh(road)
    local eid = ecs.create_entity{
        policy = {
            "ant.scene|scene_object",
            "ant.render|simplerender",
        },
        data = {
            scene = {
                t = math3d.mark(math3d.vector(-offset * unit, 0, -offset * unit))
            },
            simplemesh  = road_mesh,
            material    = road_material,
            visible_state = "main_view",
        },
    }
    return eid
end

function iroad.create_roadnet_entity(create_list)
    for ii = 1, #create_list do
        local cl = create_list[ii]
        local x, y = cl.x + offset, cl.y + offset
        local layers = cl.layers
        local idx = calc_tf_idx(x, y)
        local road_layer, mark_layer
        if layers and layers.road then
            road_layer = parse_terrain_type_dir(layers, "road")
        end
        if layers and layers.mark then
            mark_layer = parse_terrain_type_dir(layers, "mark")
        end
        road_table[idx] = {
            layers = {
                [1] = road_layer,
                [2] = mark_layer
            },
            x = x,
            y = y
        }
        local eid = create_road(road_table[idx])
        road_table[idx].eid = eid
    end
end

function iroad.delete_roadnet_entity(delete_list)
    for ii = 1, #delete_list do
        local dl = delete_list[ii]
        local x, y = dl.x + offset, dl.y + offset
        local idx = calc_tf_idx(x, y)
        if road_table[idx] and road_table[idx].eid then
            w:remove(road_table[idx].eid)
            road_table[idx] = nil
        end
    end    
end


function iroad.update_roadnet_entity(update_list)
    iroad.delete_roadnet_entity(update_list)
    iroad.create_roadnet_entity(update_list)
end

function iroad.set_args(ww, hh, off, un)
    if ww then width = ww end
    if hh then height = hh end
    if off then offset = off end
    if un then unit = un end
end
function init_system:init_world()
    road_material = "/pkg/mod.road/assets/road.material"
end