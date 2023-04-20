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

local function build_mesh(plane_num, plane_table, unit, offset, aabb)
    local packfmt<const> = "fff"
    local vb = {}
    local ib_handle = build_ib(plane_num)
    for plane, _ in pairs(plane_table) do
       local x, z = plane & 0xff, plane >> 8
       local ox, oz = (x + offset) * unit, (z + offset) * unit
       local nx, nz = ox + unit, oz + unit
       local v = {
            packfmt:pack(ox, 0, oz),
            packfmt:pack(ox, 0, nz),
            packfmt:pack(nx, 0, nz),
            packfmt:pack(nx, 0, oz),        
        }  
        vb[#vb+1] = table.concat(v, "")
    end
    return to_mesh_buffer(vb, ib_handle, aabb)
end

local function get_aabb(plane_table, width, height, unit, offset)
    local minx, minz = width + 1, height + 1
    local maxx, maxz = -1, -1
    for plane, _ in pairs(plane_table) do
        local x, z = plane & 0xff, plane >> 8
        if x > maxx then
            maxx = x
        end
        if x < minx then
            minx = x
        end
        if z > maxz then
            maxz = z
        end
        if z < minz then
            minz = z
        end
    end
    local aabb_min = math3d.vector((minx + offset) * unit, 0, (minz + offset) * unit)
    local aabb_max = math3d.vector((maxx + offset) * unit + unit, 0, (maxz + offset) * unit + unit)
    return math3d.aabb(aabb_min, aabb_max)
end

function init_sys:init_world()
    translucent_plane_material = "/pkg/mod.translucent_plane/assets/translucent_plane.material"
end

function itp.set_translucent_rgba(translucent_rgba_table)
    assert(#translucent_rgba_table < 4)
    for idx, rgba in pairs(translucent_rgba_table) do
        local r, g, b, a = rgba.r, rgba.g, rgba.b, rgba.a
        rgba_table[idx] = {r/255, g/255, b/255, a/255}
    end
end

local function create_translucent_plane(tinfo)
    local plane_table = tinfo.plane_table
    local color_idx = tinfo.color_idx
    local plane_num = tinfo.plane_num
    local width, height, unit, offset = iplane_terrain.get_wh()
    local aabb = get_aabb(plane_table, width, height, unit, offset)
    local plane_mesh = build_mesh(plane_num, plane_table, unit, offset, aabb)
    if plane_mesh then
        ecs.create_entity{
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
                    imaterial.set_property(e, "u_colorTable", math3d.vector(rgba_table[color_idx]))
                end,
                visible_state = "main_view",
                render_layer = "translucent",
                translucent_info = tinfo
            },
        }
    end
end

local function get_translucent_info(rect, color_idx)
    local plane_table, tinfo = {}, {}
    local plane_num = 0
    for ih = 0, rect.h - 1 do
        for iw = 0, rect.w - 1 do
            local coord = {rect.x + iw, rect.z + ih}
            local plane_coord = (coord[2] << 8) + coord[1]
            plane_table[plane_coord] = true
            plane_num = plane_num + 1
        end
    end
    tinfo.merge_table = {}
    tinfo.plane_table, tinfo.rect, tinfo.color_idx, tinfo.plane_num = plane_table, rect, color_idx, plane_num
    return tinfo
end

function itp.create_translucent_plane_entity(rect, color_idx)
    local tinfo = get_translucent_info(rect, color_idx)
    create_translucent_plane(tinfo)
end

function itp.remove_translucent_plane_entity(remove_coord)
    for e in w:select "translucent_info:in eid:in" do
        local translucent_info = e.translucent_info
        if translucent_info then
            if translucent_info.rect.x == remove_coord[1] and  translucent_info.rect.z == remove_coord[2] then
                w:remove(e.eid)
                local merge_table = translucent_info.merge_table
                for compress_m, _ in pairs(merge_table) do
                    for ee in w:select "translucent_info:in eid:in" do
                        local cur_tinfo = ee.translucent_info
                        local compress_c = (ee.translucent_info.rect.z << 8) + ee.translucent_info.rect.x
                        if compress_c == compress_m then
                            local compress_t = (translucent_info.rect.z << 8) + translucent_info.rect.x
                            cur_tinfo.merge_table[compress_t] = nil
                            merge_table[compress_m] = nil
                            local merge_coord_table = {}
                            for compress_coord, _ in pairs(cur_tinfo.merge_table)do
                                local merge_coord = {compress_coord & 0xff, compress_coord >> 8}
                                merge_coord_table[#merge_coord_table+1] = merge_coord
                            end
                            itp.merge_translucent_plane_entity(cur_tinfo.rect, cur_tinfo.color_idx, merge_coord_table)
                            w:remove(ee.eid)
                        end
                    end 
                end
            end
        end
    end
end

function itp.merge_translucent_plane_entity(rect, color_idx, merge_coord_table)
    local intersect_table = {}
    local origin_plane_num_table = {}
    local tinfo = get_translucent_info(rect, color_idx)
    local cur_plane_table, cur_plane_num = tinfo.plane_table, tinfo.plane_num
    local merge_tinfo_table = {}
    for e in w:select "translucent_info:in eid:in" do
        local translucent_info = e.translucent_info
        if translucent_info then
            for _, merge_coord in pairs(merge_coord_table) do
                local ix, iz = translucent_info.rect.x, translucent_info.rect.z
                if ix == merge_coord[1] and iz == merge_coord[2] then
                    merge_tinfo_table[merge_coord] = translucent_info
                    origin_plane_num_table[merge_coord] = translucent_info.plane_num
                end
            end
        end
    end
    for compress_coord, _ in pairs(cur_plane_table) do
        for merge_coord, merge_tinfo in pairs(merge_tinfo_table) do
            if merge_tinfo.plane_table[compress_coord] then
                intersect_table[merge_coord] = true
                if color_idx < merge_tinfo.color_idx then
                    merge_tinfo.plane_table[compress_coord] = nil
                    merge_tinfo.plane_num = merge_tinfo.plane_num - 1
                else
                    cur_plane_table[compress_coord] = nil
                    cur_plane_num = cur_plane_num - 1
                end
            end
        end
    end
    for merge_coord, merge_tinfo in pairs(merge_tinfo_table) do
        if merge_tinfo.plane_num ~= origin_plane_num_table[merge_coord] then
            itp.remove_translucent_plane_entity(merge_coord)
        end
        if intersect_table[merge_coord] then
            local compress_t = (tinfo.rect.z << 8) + tinfo.rect.x
            local compress_m = (merge_tinfo.rect.z << 8) + merge_tinfo.rect.x
            merge_tinfo.merge_table[compress_t] = true
            tinfo.merge_table[compress_m] = true 
        end
        if merge_tinfo.plane_num ~= origin_plane_num_table[merge_coord] then
            create_translucent_plane(merge_tinfo)
        end
    end
    create_translucent_plane(tinfo)
end

