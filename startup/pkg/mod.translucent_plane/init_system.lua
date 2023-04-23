local ecs       = ...
local world     = ecs.world
local w         = world.w
local renderpkg = import_package "ant.render"
local declmgr   = renderpkg.declmgr
local math3d    = require "math3d"
local mathpkg = import_package "ant.math"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local timer 	= ecs.import.interface "ant.timer|itimer"
local layout_name<const>    = declmgr.correct_layout "p3"
local layout                = declmgr.get(layout_name)
local init_sys = ecs.system 'init_system'
local mc    = mathpkg.constant
local bgfx      = require "bgfx"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iplane_terrain  = ecs.import.interface "mod.terrain|iplane_terrain"
local itp = ecs.interface "itranslucent_plane"
local assetmgr  = import_package "ant.asset"
local translucent_plane_material
local rgba_table = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}

local NUM_QUAD_VERTICES<const> = 4

--build ib
local function build_ib(max_plane)
    do
        local planeib = {}
        planeib = {
            0, 1, 2,
            2, 3, 0,
        }
        local fmt<const> = ('I'):rep(#planeib)
        local offset<const> = NUM_QUAD_VERTICES
        local s = #fmt * 4


        local m = bgfx.memory_buffer(s * max_plane)
        for i=1, max_plane do
            local mo = s * (i - 1) + 1
            m[mo] = fmt:pack(table.unpack(planeib))
            for ii = 1, #planeib do
                planeib[ii]  = planeib[ii] + offset
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

local function build_mesh(grids, unit, offset, aabb)
    local packfmt<const> = "fff"
    local vb = {}
    local grid_num = 0
    for grid, _ in pairs(grids) do
       local cx, cz = grid >> 8, grid & 0xff
       local ox, oz = cx * unit, cz * unit
       local nx, nz = ox + unit, oz + unit
       local v = {
            packfmt:pack(ox, 0, oz),
            packfmt:pack(ox, 0, nz),
            packfmt:pack(nx, 0, nz),
            packfmt:pack(nx, 0, oz),        
        }  
        vb[#vb+1] = table.concat(v, "")
        grid_num = grid_num + 1
    end
    if grid_num == 0 then
        return nil
    end
    local ib_handle = build_ib(grid_num)
    return to_mesh_buffer(vb, ib_handle, aabb)
end

local function get_aabb(grids, width, height, unit, offset)
    local minx, minz = width + 1, height + 1
    local maxx, maxz = -1, -1
    for grid,  _ in pairs(grids) do
        local cx, cz = grid >> 8, grid & 0xff
        if cx > maxx then
            maxx = cx
        end
        if cx < minx then
            minx = cx
        end
        if cz > maxz then
            maxz = cz
        end
        if cz < minz then
            minz = cz
        end
    end
    local aabb_min = math3d.vector(minx * unit, 0, minz * unit)
    local aabb_max = math3d.vector(minx * unit + unit, 0, minz * unit + unit)
    return math3d.aabb(aabb_min, aabb_max)
end

function init_sys:init_world()
    translucent_plane_material = "/pkg/mod.translucent_plane/assets/translucent_plane.material"
end

local function create_translucent_plane_entity(grids_table, color, render_layer)
    local width, height, unit, offset = iplane_terrain.get_wh()
    local aabb = get_aabb(grids_table, width, height, unit, offset)
    local plane_mesh = build_mesh(grids_table, unit, offset, aabb)
    local eid
    if plane_mesh then
        eid = ecs.create_entity{
            policy = {
                "ant.scene|scene_object",
                "ant.render|simplerender",
                "mod.translucent_plane|translucent_plane",
            },
            data = {
                scene = {
                    t = math3d.vector(-offset * unit, 0, -offset * unit)
                },
                simplemesh  = plane_mesh,
                material    = translucent_plane_material,
                on_ready = function (e)
                    imaterial.set_property(e, "u_colorTable", math3d.vector(color))
                end,
                visible_state = "main_view",
                --render_layer = "translucent",
                render_layer = render_layer
            },
        }
    end
    return eid
end 

local function create_grids_table(rect_table, offset)
    local grids_table = {}
    -- create all rect' grids
    for idx = 1, #rect_table do
        local rect = rect_table[idx]
        local x, z, ww, hh = rect.x + offset, rect.z + offset, rect.w, rect.h
        local grids = {}
        for ih = 0, hh - 1 do
            for iw = 0, ww - 1 do
                local xx, zz = x + iw, z - ih
                local compress_coord = (xx << 8) + zz
                grids[compress_coord] = true
            end
        end
        grids_table[idx] = grids
    end
    return grids_table
end

local function create_aabb_table(rect_table, offset)
    local aabb_table = {}
    -- create all rect' aabb
    for idx = 1, #rect_table do
        local rect = rect_table[idx]
        local x, z, ww, hh = rect.x + offset, rect.z + offset, rect.w, rect.h
        local aabb = math3d.aabb(math3d.vector(x, 0, z - (hh - 1)), math3d.vector(x + ww - 1, 0, z))
        aabb_table[idx] = aabb
    end
    return aabb_table
end

local function update_grids_table(grids_table, aabb_table)
    if #grids_table <= 1 then
        return
    end
    for idx_offset = 0, #grids_table - 1 do
        local cur_idx = #grids_table-idx_offset
        local aabb = aabb_table[cur_idx]
        for prev_idx = 1, cur_idx - 1 do
            local prev_grids = grids_table[prev_idx]
            local prev_aabb = aabb_table[prev_idx]
            local inter_aabb = math3d.aabb_intersection(aabb, prev_aabb)
            if inter_aabb ~= mc.NULL then
                local inter_center, inter_extent = math3d.aabb_center_extents(inter_aabb)
                local inter_min, inter_max = math3d.sub(inter_center, inter_extent), math3d.add(inter_center, inter_extent)
                local inter_min_x, inter_min_z = math3d.index(inter_min, 1, 3)
                local inter_max_x, inter_max_z = math3d.index(inter_max, 1, 3)
                for zz = inter_min_z, inter_max_z do
                    for xx = inter_min_x, inter_max_x do
                        local compress_coord = (xx << 8) + zz
                        prev_grids[compress_coord] = nil
                    end
                end
            end
        end
    end
end

function itp.create_translucent_plane(rect_table, color_table, render_layer)
    local width, height, unit, offset = iplane_terrain.get_wh()
    local eid_table = {}
    local grids_table = create_grids_table(rect_table, offset)
    local aabb_table = create_aabb_table(rect_table, offset)
    update_grids_table(grids_table, aabb_table)
    for idx = 1, #rect_table do
        eid_table[idx] = create_translucent_plane_entity(grids_table[idx], color_table[idx], render_layer)
    end
    return eid_table
end

function itp.remove_translucent_plane(eid_table)
    for idx = 1,#eid_table do
        w:remove(eid_table[idx])
    end
end

