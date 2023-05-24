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
local layout_name<const>    = declmgr.correct_layout "p3|t20|t21"
local layout                = declmgr.get(layout_name)
local width, height, offset, unit = 256, 256, 128, 10
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local road_material
local group_table = {}
local road_default_group = 30001
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

local function parse_layer(t, s, d)
    local pt, ps, pd
    local u_table = {["1"] = 0, ["2"]= 270, ["3"] = 180, ["4"] = 90}
    local i_table = {["1"] = 270, ["2"]= 0, ["3"] = 90, ["4"] = 180}
    local l_table = {["1"] = 180, ["2"]= 90, ["3"] = 0, ["4"] = 270}
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

local function get_road_info(road)
    local t = {(road.x - offset) * unit, 0, (road.y - offset) * unit, 0}
    local road_direction = road.road_direction or 0
    local mark_direction = road.mark_direction or 0
    local road_info = {
        [1] = t,
        [2] = {road_direction, mark_direction, 0, 0},
        [3] = {road.road_type, road.road_shape, road.mark_type, road.mark_shape},
    }
    return road_info
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
    local road_info = get_road_info(road)
    return road_info
end

function init_system:init_world()
    road_material = "/pkg/mod.road/assets/road.material"
end

local function create_road_instance_info(create_list)
    local indirect_info = {}
    for ii = 1, #create_list do
        local cl = create_list[ii]
        local x, y = cl.x + offset, cl.y + offset
        local layers = cl.layers
        local road_layer, mark_layer
        if layers and layers.road then road_layer = parse_terrain_type_dir(layers, "road") end
        if layers and layers.mark then mark_layer = parse_terrain_type_dir(layers, "mark") end
        local road = {
            layers = {
                [1] = road_layer,
                [2] = mark_layer
            },
            x = x, y = y
        }
        indirect_info[#indirect_info+1] = create_road(road)
    end
    return indirect_info
end

local function to_mesh_buffer(vb, ib_handle)
    local vbbin = table.concat(vb, "")
    local numv = #vbbin // layout.stride
    local numi = (numv // NUM_QUAD_VERTICES) * 6 --6 for one quad 2 triangles and 1 triangle for 3 indices

    return {
        bounding = nil,
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

local function build_mesh()
    local packfmt<const> = "fffffff"
    local ox, oz = 0, 0
    local nx, nz = unit, unit
    local vb = {
        packfmt:pack(ox, 0, oz, 0, 1, 0, 1),
        packfmt:pack(ox, 0, nz, 0, 0, 0, 0),
        packfmt:pack(nx, 0, nz, 1, 0, 1, 0),
        packfmt:pack(nx, 0, oz, 1, 1, 1, 1),        
    }
    local ib_handle = build_ib(1)
    return to_mesh_buffer(vb, ib_handle)
end

function iroad.set_args(ww, hh, off, un)
    if ww then width = ww end
    if hh then height = hh end
    if off then offset = off end
    if un then unit = un end
end

local road_group = {}

local function get_indirect(gid, update_list)
    local indirect_info = create_road_instance_info(update_list)
    local indirect = {
        group = gid,
        indirect_info = indirect_info,
        type = "ROAD"
    }
    return indirect 
end

local function create_road_group(gid, update_list)
    local indirect = get_indirect(gid, update_list)
    local road_mesh = build_mesh()
    local g = ecs.group(gid)
    ecs.group(gid):enable "view_visible"
    ecs.group(gid):enable "scene_update"
    g:create_entity{
        policy = {
            "ant.scene|scene_object",
            "ant.render|simplerender",
            "ant.render|indirect"
        },
        data = {
            scene = {},
            simplemesh  = road_mesh,
            material    = road_material,
            visible_state = "main_view",
            indirect = indirect,
            indirect_update = true,
            road = true,
        },
    }  
end

local function update_road_group(gid, update_list)
    local indirect = get_indirect(gid, update_list)
    ecs.group(gid):enable "view_visible"
    ecs.group(gid):enable "scene_update"
    local select_tag = "road view_visible:in scene_update:in indirect:update indirect_update?update"
    ecs.group_flush()
    for e in w:select(select_tag) do
        e.indirect = indirect
        if e.indirect.group == gid then
            e.indirect_update = true
        end
    end
end

function iroad.update_roadnet_group(gid, update_list)
    if not gid then
        gid = 30001
    end
    if road_group[gid] then
        update_road_group(gid, update_list)
    else
        create_road_group(gid, update_list)
        road_group[gid] = true
    end

end
