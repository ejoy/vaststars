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

local function build_mesh(plane_table, unit, offset, aabb)
    local packfmt<const> = "fff"
    local vb = {}
    local ib_handle = build_ib(#plane_table)
    for _, plane in pairs(plane_table) do
       local ox, oz = (plane.x + offset) * unit, (plane.z + offset) * unit
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
    for _, plane in pairs(plane_table) do
        local x, z = plane.x, plane.z
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

function itp.create_translucent_plane_entity(plane_table, tinfo)
    local color_idx, minx, minz = tinfo.color_idx, tinfo.min_x, tinfo.min_z
    local width, height, unit, offset = iplane_terrain.get_wh()
    local aabb = get_aabb(plane_table, width, height, unit, offset)
    local plane_mesh = build_mesh(plane_table, unit, offset, aabb)
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
                translucent_info = {
                    color_idx = color_idx,
                    min_x = minx,
                    min_z = minz
                }
            },
        }
    end
end

function itp.remove_translucent_plane_entity(tinfo)
    for e in w:select "translucent_info:in eid:in" do
        local translucent_info = e.translucent_info
        if translucent_info then
            if translucent_info.color_idx == tinfo.color_idx and translucent_info.min_x == tinfo.min_x and  translucent_info.min_z == tinfo.min_z then
                w:remove(e.eid)
            end
        end
    end
end





