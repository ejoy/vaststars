local ecs = ...
local world = ecs.world
local w = world.w
local open_sm = false
local idrawindirect = ecs.import.interface "ant.render|idrawindirect"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local math3d 	= require "math3d"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local mathpkg	= import_package "ant.math"
local mc		= mathpkg.constant
local renderpkg = import_package "ant.render"
local viewidmgr = renderpkg.viewidmgr
local declmgr   = import_package "ant.render".declmgr
local bgfx 			= require "bgfx"
local assetmgr  = import_package "ant.asset"
local icompute = ecs.import.interface "ant.render|icompute"
local terrain_module = require "terrain"
local ism = ecs.interface "istonemountain"
local sm_sys = ecs.system "stone_mountain"
local ratio, width, height = 0.60, 256, 256
local freq, depth, unit, offset = 4, 4, 10, 0
local main_viewid = viewidmgr.get "csm_fb"
local open_area = {}
local sm_area = {}
local sm_table = {}
local sm_group = {
    [1] = 40001, [2] = 40002, [3] = 40003, [4] = 40004
}

local mesh_table = {
    [1] = "/pkg/mod.stonemountain/assets/mountain1.glb|meshes/Cylinder.002_P1.meshbin",
    [2] = "/pkg/mod.stonemountain/assets/mountain2.glb|meshes/Cylinder.004_P1.meshbin",
    [3] = "/pkg/mod.stonemountain/assets/mountain3.glb|meshes/Cylinder_P1.meshbin",
    [4] = "/pkg/mod.stonemountain/assets/mountain4.glb|meshes/Cylinder.021_P1.meshbin"
}


local function generate_sm_config()
    local idx_table = {}
    local cnt = 0
    for iz = 0, height - 1 do
        for ix = 0, width - 1 do
            local seed, offset_y, offset_x = iz * ix + 1, iz + 1, ix + 1
            local noise = terrain_module.noise(ix, iz, freq, depth, seed, offset_y, offset_x)
            if noise > ratio then
                idx_table[#idx_table+1] = 1
                cnt = cnt + 1
            else
                idx_table[#idx_table+1] = 0
            end
        end
    end
    return string.pack(("i"):rep(width * height), table.unpack(idx_table))
end

function ism.create_random_sm(d, ww, hh, off, un)
    ratio = ratio + (1 - d) / 10
    width, height =  ww, hh
    if off then offset = off end
    if un then unit = un end
    return generate_sm_config()
end

function ism.create_sm_entity(idx_string)
    open_sm = true
    for iz = 0, height - 1 do
        for ix = 0, width - 1 do
            local idx = iz * width + ix + 1
            local is_sm = string.unpack(("i"), idx_string, idx)
            if is_sm == 1 then
                sm_table[(ix << 8) + iz] = {}
            end
        end
    end
end


local function get_1x1_srt()
    for sm_idx, _ in pairs(sm_table) do
        local ix, iz = sm_idx >> 8, sm_idx & 255
        local seed, offset_y, offset_x = iz * ix + 1, iz + 1, ix + 1
        local s_noise = terrain_module.noise(ix, iz, freq * 2, depth * 2, seed * 2, offset_y * 2, offset_x * 2) * 0.064 + 0.064 * 1.5
        local r_noise = math.floor(terrain_module.noise(ix, iz, freq * 3, depth * 3, seed * 3, offset_y * 3, offset_x * 3) * 360)
        local mesh_noise = (sm_idx) % 4 + 1
        local tx, tz = (ix + 0.5 - offset) * unit, (iz + 0.5 - offset) * unit
        sm_table[sm_idx] = {[1] = {s = s_noise, r = r_noise, tx = tx, tz = tz, m = mesh_noise}}
    end
end

local function make_sm_noise()
    get_1x1_srt()
end

function sm_sys:init()

end
local kb_mb = world:sub{"keyboard"}


local function create_sm_entity()
    local stonemountain_info_table  = {
        {}, {}, {}, {}
    }
    for _, sms in pairs(sm_table)do
        for sm_type = 1, #sms do
            local sm = sms[sm_type]
            local mesh_idx = sm.m
            stonemountain_info_table[mesh_idx][#stonemountain_info_table[mesh_idx]+1] = {
                {sm.s, sm.r, sm.tx, sm.tz}
            }
        end
    end
    for mesh_idx = 1, 4 do
        local mesh_address = mesh_table[mesh_idx]
        local gid = sm_group[mesh_idx]
        local g = ecs.group(gid)
        ecs.group(gid):enable "view_visible"
        ecs.group(gid):enable "scene_update"
        g:create_entity {
            policy = {
                "ant.render|render",
                "mod.stonemountain|stonemountain",
                "ant.render|indirect"
             },
            data = {
                scene         = {},
                material      ="/pkg/mod.stonemountain/assets/pbr_sm.material", 
                visible_state = "main_view|cast_shadow",
                mesh          = mesh_address,
                stonemountain = {
                    group = sm_group[mesh_idx],
                    stonemountain_info = stonemountain_info_table[mesh_idx],
                },
                render_layer = "foreground",
                indirect = "STONE_MOUNTAIN",
                on_ready = function(e)
                    local draw_indirect_type = idrawindirect.get_draw_indirect_type("STONE_MOUNTAIN")
                    imaterial.set_property(e, "u_draw_indirect_type", math3d.vector(draw_indirect_type))
                end
            }
        }
    end
end

function sm_sys:stone_mountain()
    if open_sm then
        make_sm_noise()
        create_sm_entity()
        open_sm = false
    end
end

function sm_sys:entity_init()
    for e in w:select "INIT stonemountain:update render_object?update indirect?update" do
        local stonemountain = e.stonemountain
        local max_num = 2500
        local draw_indirect_eid = ecs.create_entity {
            policy = {
                "ant.render|compute_policy",
                "ant.render|draw_indirect"
            },
            data = {
                material    = "/pkg/ant.resources/materials/indirect/indirect.material",
                dispatch    = {
                    size    = {0, 0, 0},
                },
                compute = true,
                draw_indirect = {
                    itb_flag = "r",
                    max_num = max_num
                },
                on_ready = function()
                    stonemountain.ready = true
                end 
            }
        }
        stonemountain.draw_indirect_eid = draw_indirect_eid
        e.render_object.draw_num = 0
        e.render_object.idb_handle = 0xffffffff
        e.render_object.itb_handle = 0xffffffff
    end   
end

function sm_sys:entity_remove()
    for e in w:select "REMOVED stonemountain:in" do
        w:remove(e.stonemountain.draw_indirect_eid)
    end
end

local function get_instance_memory_buffer(stonemountain_info, max_num)
    local stonemountain_num = #stonemountain_info
    local fmt<const> = "ffff"
    local memory_buffer = bgfx.memory_buffer(3 * 16 * max_num)
    local memory_buffer_offset = 1
    for stonemountain_idx = 1, stonemountain_num do
        local instance_data = stonemountain_info[stonemountain_idx]
        for data_idx = 1, 3 do
            if data_idx == 1 then
                memory_buffer[memory_buffer_offset] = fmt:pack(table.unpack(instance_data[data_idx]))
            else
                memory_buffer[memory_buffer_offset] = fmt:pack(table.unpack({0, 0, 0, 0})) 
            end
            memory_buffer_offset = memory_buffer_offset + 16
        end
    end
    return memory_buffer
end

local function create_stonemountain_compute(dispatch, stonemountain_num, indirect_buffer, instance_buffer, instance_params, indirect_params)
    dispatch.size[1] = math.floor((stonemountain_num - 1) / 64) + 1
    local m = dispatch.material
    m.u_instance_params			= instance_params
    m.u_indirect_params         = indirect_params
    m.indirect_buffer           = indirect_buffer
    m.instance_buffer           = instance_buffer
    icompute.dispatch(main_viewid, dispatch)
end

function sm_sys:data_changed()
    
    for e in w:select "stonemountain:update render_object:update scene:in bounding:update" do
        if not e.stonemountain.ready then
            goto continue
        end
        e.bounding.scene_aabb = mc.NULL
        local stonemountain = e.stonemountain
        local stonemountain_info = stonemountain.stonemountain_info
        local stonemountain_num = #stonemountain_info
        if stonemountain_num > 0 then
            local de <close> = w:entity(stonemountain.draw_indirect_eid, "draw_indirect:in dispatch:in")
            local idb_handle, itb_handle = de.draw_indirect.idb_handle, de.draw_indirect.itb_handle
            local instance_memory_buffer = get_instance_memory_buffer(stonemountain_info, 2500)
            bgfx.update(itb_handle, 0, instance_memory_buffer)
            local instance_params = math3d.vector(0, e.render_object.vb_num, 0, e.render_object.ib_num)
            local indirect_params = math3d.vector(stonemountain_num, 0, 0, 0)
            create_stonemountain_compute(de.dispatch, stonemountain_num, idb_handle, itb_handle, instance_params, indirect_params)
            e.render_object.idb_handle = idb_handle
            e.render_object.itb_handle = itb_handle
            e.render_object.draw_num = stonemountain_num
        else
            e.render_object.idb_handle = 0xffffffff
            e.render_object.itb_handle = 0xffffffff
            e.render_object.draw_num = 0
        end

        e.stonemountain.ready = nil
        ::continue::
    end
end
