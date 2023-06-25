local ecs = ...
local world = ecs.world
local w = world.w
local open_sm = false
local aabb_test
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
local ratio, width, height = 0.70, 256, 256
local freq, depth, unit, offset = 4, 4, 10, 0
local remove_offset = 3
local is_build_sm = false
local instance_num = 0
local main_viewid = viewidmgr.get "csm_fb"
local open_area
local stone_area
-- mapping between instance idx and sm_idx
local scale_table = {b = 0.80, m = 0.50, s = 0.10}
local sm_rect_table = {}
local sm_grid_table = {}
local sm_table = {}
local stone_instance_params = {}
-- 1. mapping between mesh_idx and sm_idx with size_idx with count_idx (before get_final_map)
-- 1. mapping between mesh_idx and sm_idx with size_idx (after get_final_map)
local mesh_to_sm_table = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {}
}
local sm_bms_to_mesh_table = {}
local sm_group = {
    [1] = 40001, [2] = 40002, [3] = 40003, [4] = 40004
}
-- queue_idx to section_idx
local terrain_section_cull_table = {}

-- mesh_idx to mesh_origin_aabb
local mesh_aabb_table    = {}

local mesh_table = {
    [1] = "/pkg/mod.stonemountain/assets/mountain1.glb|meshes/Cylinder.002_P1.meshbin",
    [2] = "/pkg/mod.stonemountain/assets/mountain2.glb|meshes/Cylinder.004_P1.meshbin",
    [3] = "/pkg/mod.stonemountain/assets/mountain3.glb|meshes/Cylinder_P1.meshbin",
    [4] = "/pkg/mod.stonemountain/assets/mountain4.glb|meshes/Cylinder.021_P1.meshbin"
}


local function exclude_from_open_area(ix, iz, areas)
    local out_area = true
    if not areas then return true end
    for _, area in pairs(areas) do
        local ox, oz, ww, hh = area.x + offset, area.z + offset, area.w, area.h
        local lw, rw, lh, rh = math.max(0, ox - remove_offset), math.min(width, ox + ww + remove_offset), math.max(0, oz - hh - remove_offset), math.min(width, oz + remove_offset)
        if ix >= lw and ix <= rw and iz >= lh and iz <= rh then
            return false
        end
    end
    return out_area
end

local function get_corner_table(center, extent)
    local lt = {x = center.x - extent.x, z = center.z + extent.z}
    local t  = {x = center.x,            z = center.z + extent.z}
    local rt = {x = center.x + extent.x, z = center.z + extent.z}
    local r  = {x = center.x + extent.x, z = center.z}
    local rb = {x = center.x + extent.x, z = center.z - extent.z}
    local b  = {x = center.x,            z = center.z - extent.z}
    local lb = {x = center.x - extent.x, z = center.z - extent.z}
    local l  = {x = center.x - extent.x, z = center.z}
    --return {lt = lt, t = t, rt = rt, r = r, rb = rb, b = b, lb = lb, l = l}
    return {[1] = lt, [2] = t, [3] = rt, [4] = r,[5] = rb, [6] = b, [7] = lb, [8]= l}
end

local function get_inter_table(center, extent)
    local ltt = {x = center.x - extent.x * 0.5, z = center.z + extent.z}
    local trt = {x = center.x + extent.x * 0.5, z = center.z + extent.z}
    local rtr = {x = center.x + extent.x      , z = center.z + extent.z * 0.5}
    local rrb = {x = center.x + extent.x      , z = center.z - extent.z * 0.5}
    local rbb = {x = center.x + extent.x * 0.5, z = center.z - extent.z}
    local blb = {x = center.x - extent.x * 0.5, z = center.z - extent.z}
    local lbl = {x = center.x - extent.x      , z = center.z - extent.z * 0.5}
    local llt = {x = center.x - extent.x      , z = center.z + extent.z * 0.5}
    --return {ltt = ltt, trt = trt, rtr = rtr, rrb = rrb, rbb = rbb, blb = blb, lbl = lbl, llt = llt}
    return {[1] = ltt, [2]  = trt, [3]  = rtr, [4]  = rrb, [5]  = rbb, [6]  = blb, [7]  = lbl, [8]  = llt} 
end

local function get_corner_range(corner_idx, extent)
    local extent_x = extent.x
    local extent_z = extent.z
    if corner_idx == 1 then -- lt
        return {[1] = {lb = 0, ub = extent_x},         [2] = {lb = -extent_z, ub = 0}}
    elseif corner_idx == 2 then -- t 
        return {[1] = {lb = -extent_x, ub = extent_x}, [2] = {lb = -extent_z, ub = 0}}
    elseif corner_idx == 3 then -- rt
        return {[1] = {lb = -extent_x, ub = 0},        [2] = {lb = -extent_z, ub = 0}}
    elseif corner_idx == 4 then -- r
        return {[1] = {lb = -extent_x, ub = 0},        [2] = {lb = -extent_z, ub = extent_z}}
    elseif corner_idx == 5 then -- rb
        return {[1] = {lb = -extent_x, ub = 0},        [2] = {lb = 0, ub = extent_z}}
    elseif corner_idx == 6 then -- b
        return {[1] = {lb = -extent_x, ub = extent_x}, [2] = {lb = 0, ub = extent_z}}
    elseif corner_idx == 7 then -- lb
        return {[1] = {lb = 0, ub = extent_x},         [2] = {lb = 0, ub = extent_z}}
    elseif corner_idx == 8 then -- l
        return {[1] = {lb = 0, ub = extent_x},         [2] = {lb = -extent_z, ub = extent_z}}
    end
end

local function get_inter_range(corner_idx, extent)
    local extent_x = extent.x
    local extent_z = extent.z
    if corner_idx == 1 then -- ltt
        return {[1] = {lb = -extent_x, ub = extent_x}, [2] = {lb = -extent_z, ub = 0}}
    elseif corner_idx == 2 then -- trt 
        return {[1] = {lb = -extent_x, ub = extent_x}, [2] = {lb = -extent_z, ub = 0}}
    elseif corner_idx == 3 then -- rtr
        return {[1] = {lb = -extent_x, ub = 0},        [2] = {lb = -extent_z, ub = extent_z}}
    elseif corner_idx == 4 then -- rrb
        return {[1] = {lb = -extent_x, ub = 0},        [2] = {lb = -extent_z, ub = extent_z}}
    elseif corner_idx == 5 then -- rbb
        return {[1] = {lb = -extent_x, ub = extent_x}, [2] = {lb = 0, ub = extent_z}}
    elseif corner_idx == 6 then -- blb
        return {[1] = {lb = -extent_x, ub = extent_x}, [2] = {lb = 0, ub = extent_z}}
    elseif corner_idx == 7 then -- lbl
        return {[1] = {lb = 0, ub = extent_x},         [2] = {lb = -extent_z, ub = extent_z}}
    elseif corner_idx == 8 then -- llt
        return {[1] = {lb = 0, ub = extent_x},         [2] = {lb = -extent_z, ub = extent_z}}
    end
end

local function get_center()
    local m_clamp = (ratio + 0.2) * 0.1 -- [0.02, 0.12]
    local b_clamp = 1 - m_clamp -- [0.88, 0.98]
    local tmp_center_table = {}
    -- random stone_area
    for iy = 6, height - 6 do
      for ix = 6, width - 6 do
        local cur_index = ix - 1 + (iy - 1) * width + 1
            local offset_x = iy
            local offset_y = ix
            local seed = iy * ix
            local e = terrain_module.noise(ix - 1, iy - 1, freq, depth, seed, offset_y, offset_x)
            local is_center = e <= m_clamp or e >= b_clamp
            if is_center then
                local cur_center
                if e > m_clamp then
                    cur_center = 2 -- m 1+1
                else
                    cur_center = 3-- b 2+1
                end
    
                for y_offset = -4, 4 do
                    for x_offset = -4, 4 do
                        local nei_x, nei_y = iy + y_offset, ix + x_offset
                        local nei_index = nei_x - 1 + (nei_y - 1) * width + 1
                        if tmp_center_table[nei_index] then
                            is_center = false
                            goto continue
                        end
                    end
                end
                ::continue::
                if is_center then
                    local out_area = exclude_from_open_area(ix, iy, open_area)
                    if out_area == true then
                        tmp_center_table[cur_index] = cur_center
                        sm_table[cur_index] = {}
                        if cur_center == 3 then
                            sm_table[cur_index][1] = {}
                            sm_table[cur_index].center_stone = {t = 1, idx = 1} -- big 1
                        else
                            sm_table[cur_index][2] = {}
                            sm_table[cur_index].center_stone = {t = 2, idx = 1} -- middle 1
                        end 
                    end
                end
            end 
        end
    end 

        -- pre-defined stone_area
        for _, stone in pairs(stone_area) do
            local iy, ix = stone.z + offset, stone.x + offset
            local cur_index = ix + iy * width + 1
            local offset_x = iy
            local offset_y = ix
            local seed = iy * ix
            local e = terrain_module.noise(ix - 1, iy - 1, freq, depth, seed, offset_y, offset_x)
            sm_table[cur_index] = {}
            local cur_center
            if e <= m_clamp then
                cur_center = 2 -- m 1+1
            else
                cur_center = 3-- b 2+1
            end
            if cur_center == 3 then
                sm_table[cur_index][1] = {}
                sm_table[cur_index].center_stone = {t = 1, idx = 1} -- big 1
            else
                sm_table[cur_index][2] = {}
                sm_table[cur_index].center_stone = {t = 2, idx = 1} -- middle 1
            end 
        end
  --sm_table[1].center_stone = {t = 1, idx = 1}
  for idx = 1, width * height do
    if not sm_table[idx].center_stone then
        sm_table[idx] = nil
    end
  end

end

local function get_count()
    for sm_idx, _ in pairs(sm_table) do
        local iy = (sm_idx - 1) // width -- real iy need add 1
        local ix = (sm_idx - 1) % width
        for size_idx = 1, 3 do
            local offset_x = iy * size_idx
            local offset_y = ix * size_idx
            local seed = sm_idx * size_idx
            if size_idx == 1 then -- big size
                if sm_table[sm_idx][1] then --center_stone:big1
                    sm_table[sm_idx][1].c = 1
                else
                    sm_table[sm_idx][1] = {c = 0}
                end
             elseif size_idx == 2 then
                local e = terrain_module.noise(ix, iy, freq, depth, seed, offset_y, offset_x) * (8 + 1 - 1) + 1
                e = math.floor(e)
                if aabb_test then
                    if sm_table[sm_idx][2] then -- center_stone:middle1
                        sm_table[sm_idx][2].c = 1
                    else
                        sm_table[sm_idx][2] = {c = 0}
                    end
                else
                    if sm_table[sm_idx][2] then -- center_stone:middle1
                        sm_table[sm_idx][2].c = e + 1
                    else
                        sm_table[sm_idx][2] = {c = e}
                    end
                end
            else
                local e = terrain_module.noise(ix, iy, freq, depth, seed, offset_y, offset_x) * (16 + 1 - 1) + 1
                e = math.floor(e)
                if aabb_test then
                    sm_table[sm_idx][3] = {c = 0}
                else
                    sm_table[sm_idx][3] = {c = e} 
                end
            end
        end
    end
    return string.pack(("B"):rep(width * height), table.unpack(idx_table))
end

local function get_scale()
    for sm_idx, _ in pairs(sm_table) do
        if sm_table[sm_idx] then
            local iy = (sm_idx - 1) // width
            local ix = (sm_idx - 1) % width
            for size_idx = 1, 3 do
                local count_sum = sm_table[sm_idx][size_idx].c
                sm_table[sm_idx][size_idx].temp_scale_table = {}
                local temp_scale_table = sm_table[sm_idx][size_idx].temp_scale_table
                if not count_sum then
                    count_sum = 0
                end
                for count_idx = 1, count_sum do
                    local offset_x = iy * size_idx * count_idx
                    local offset_y = ix * size_idx * count_idx
                    local seed = sm_idx * size_idx * count_idx
                    if size_idx == 1 then
                        local e = terrain_module.noise(ix, iy, freq, depth, seed, offset_y, offset_x) * 0.5 + scale_table.b
                        sm_table[sm_idx][size_idx].s = e
                        sm_table[sm_idx].center_stone.s = e
                    elseif size_idx == 2 then
                        local e = terrain_module.noise(ix, iy, freq, depth, seed, offset_y, offset_x) * (scale_table.b - scale_table.m) + scale_table.m
                        temp_scale_table[count_idx] = e
                    elseif size_idx == 3 then
                        local e = terrain_module.noise(ix, iy, freq, depth, seed, offset_y, offset_x) * (scale_table.m - scale_table.s) + scale_table.s
                        temp_scale_table[count_idx] = e     
                    end
                end
            end
            if sm_table[sm_idx].center_stone.t == 2 then
                sm_table[sm_idx].center_stone.s = sm_table[sm_idx][2].temp_scale_table[1]
            end
        end
    end
end

function ism.create_sm_entity(idx_string)
    open_sm = true
    for iz = 0, height - 1 do
        for ix = 0, width - 1 do
            local idx = iz * width + ix + 1
            local is_sm = string.unpack(("B"), idx_string, idx)
            if is_sm == 1 then
                sm_table[(iz << 16) + ix] = {}
            end
        end
    end
end

local function get_translation()
    -- center_stone b1 or m1
    for sm_idx, _ in pairs(sm_table) do
        local center_stone = sm_table[sm_idx].center_stone
        local size_idx, count_idx
        if center_stone.t == 1 then
            size_idx, count_idx = 1, 1
        else
            size_idx, count_idx = 2, 1
        end
        local iy = (sm_idx - 1) // width + 1
        local ix = (sm_idx - 1) % width + 1
        local offset_x = iy * size_idx
        local offset_y = ix * size_idx
        local seedx = sm_idx * size_idx * count_idx * ix
        local seedz = sm_idx * size_idx * count_idx * iy
        local ex = terrain_module.noise(ix, iy, freq, depth - 1, seedx, offset_x, offset_x)
        local ez = terrain_module.noise(ix, iy, freq - 1, depth, seedz, offset_y, offset_y)
        local mesh_idx = sm_bms_to_mesh_table[sm_idx][size_idx][count_idx]
        local scale = center_stone.s
        center_stone.center = {
            x = (ix + ex - offset - 1) * unit,
            z = (iy + ez - offset - 1) * unit,
        }
        sm_table[sm_idx][size_idx].t = center_stone.center
        local extent = {}
        extent.x, extent.z = mesh_aabb_table[mesh_idx].extent[1] * scale, mesh_aabb_table[mesh_idx].extent[3] * scale -- radius
        local corner_table = get_corner_table(center_stone.center, extent)
        local inter_table = get_inter_table(center_stone.center, extent)
        sm_table[sm_idx].b_corner_table = corner_table
        sm_table[sm_idx].b_inter_table = inter_table     
    end

    -- get middle_stone's translation
    -- get m_inter_table   
    local sm_m_table = {}
    for sm_idx, _ in pairs(sm_table) do
        local size_idx = 2
        local m_min = {x = 100000,  z = 100000}
        local m_max = {x = -100000, z = -100000}
        local cb = 1
        if sm_table[sm_idx].center_stone.t == 2 then
            cb = 2
        end
        local count_sum = sm_table[sm_idx][size_idx].c
        if not count_sum then
            count_sum = 0
        end
        for count_idx = cb , count_sum do
            local iy = sm_idx // width + 1
            local ix = sm_idx % width + 1
            local corner_idx = (iy * ix * count_idx + iy + ix + count_idx) % 8 + 1
            local corner_center = sm_table[sm_idx].b_corner_table[corner_idx]
            local scale = sm_table[sm_idx][size_idx].temp_scale_table[count_idx]
            local mesh_idx = sm_bms_to_mesh_table[sm_idx][size_idx][count_idx]
            local extent = {}
            extent.x, extent.z = mesh_aabb_table[mesh_idx].extent[1] * scale, mesh_aabb_table[mesh_idx].extent[3] * scale   -- radius
            local corner_range = get_corner_range(corner_idx, extent)
            local offset_x = iy * size_idx
            local offset_y = ix * size_idx
            local seedx = sm_idx * size_idx * count_idx * ix
            local seedz = sm_idx * size_idx * count_idx * iy
            local lb_x, ub_x = corner_range[1].lb, corner_range[1].ub
            local lb_z, ub_z = corner_range[2].lb, corner_range[2].ub
            local ex = terrain_module.noise(ix, iy, freq, depth - 1, seedx, offset_x, offset_x) * (ub_x - lb_x) + lb_x
            local ez = terrain_module.noise(ix, iy, freq - 1, depth, seedz, offset_y, offset_y) * (ub_z - lb_z) + lb_z
            local corner_x = ex + corner_center.x
            local corner_z = ez + corner_center.z
            local grid_x   = math.floor(corner_x // unit + offset)
            local grid_z   = math.floor(corner_z // unit + offset)
            local m_idx = grid_x - 1 + (grid_z - 1) * width + 1
            if not sm_table[m_idx] then
                sm_m_table[m_idx]={[1] = {}, [2] = {}, [3] = {}}
                sm_m_table[m_idx][2].s = sm_table[sm_idx][size_idx].temp_scale_table[count_idx]
                sm_m_table[m_idx][2].r = sm_table[sm_idx][size_idx].temp_rotation_table[count_idx]
                sm_m_table[m_idx][2].t = {x = corner_x, z = corner_z}
                sm_m_table[m_idx][2].origin = {sm_idx = sm_idx, size_idx = size_idx, count_idx = count_idx}
            else
                sm_table[m_idx][size_idx].t = {
                    x = corner_x,
                    z = corner_z
                }
                sm_table[m_idx][2].origin = {sm_idx = sm_idx, size_idx = size_idx, count_idx = count_idx}
            end
            if corner_x - extent.x < m_min.x then
                m_min.x = corner_x - extent.x
                end
            if corner_x + extent.x > m_max.x then
                m_max.x = corner_x + extent.x
            end
            if corner_z - extent.z < m_min.z then
                m_min.z = corner_z - extent.z
            end
            if corner_z + extent.z > m_max.z then
                m_max.z = corner_z + extent.z
            end
            local m_center = {x = (m_max.x + m_min.x) * 0.5, z = (m_max.z + m_min.z) * 0.5}
            local m_extent = {x = (m_max.x - m_min.x) * 0.5, z = (m_max.z - m_min.z) * 0.5}
            local inter_table = get_inter_table(m_center, m_extent)
            sm_table[sm_idx].m_inter_table = inter_table
            sm_table[sm_idx].outer_extent = m_extent
        end 
    end

    local sm_s_table = {}

    for sm_idx, _ in pairs(sm_table) do
        local ix, iz = sm_idx & 65535, sm_idx >> 16
        local seed, offset_y, offset_x = iz * ix + 1, iz + 1, ix + 1
        local s_noise = terrain_module.noise(ix, iz, freq * 2, depth * 2, seed * 2, offset_y * 2, offset_x * 2) * 0.064 + 0.064 * 1.5
        local r_noise = math.floor(terrain_module.noise(ix, iz, freq * 3, depth * 3, seed * 3, offset_y * 3, offset_x * 3) * 360)
        local mesh_noise = (sm_idx) % 4 + 1
        local tx, tz = (ix + 0.5 - offset) * unit, (iz + 0.5 - offset) * unit
        sm_table[sm_idx] = {[1] = {s = s_noise, r = r_noise, tx = tx, tz = tz, m = mesh_noise}}
    end
end

local function make_sm_noise()
    get_center()
    get_count()
    get_map()
    get_scale()
    get_rotation()
    get_translation()

end

function sm_sys:init()
    sm_material = assetmgr.resource("/pkg/ant.resources/materials/stone_mountain/stone_mountain.material")
end
local kb_mb = world:sub{"keyboard"}


--world coordinate
local function set_sm_rect(mesh_aabb_value, worldmat)
    local cc, ee = mesh_aabb_value.center, mesh_aabb_value.extent
    local min, max = math3d.sub(cc, ee), math3d.add(cc, ee)
    local origin_aabb = math3d.aabb(min, max)
    local t_aabb = math3d.aabb_transform(worldmat, origin_aabb)
    local center, extent = math3d.aabb_center_extents(t_aabb)
    local minv, maxv = math3d.sub(center, extent), math3d.add(center, extent)
    local minx, minz= math.ceil(math.floor(math3d.index(minv, 1)) / unit),  math.ceil(math.floor(math3d.index(minv, 3)) / unit)
    local maxx, maxz= math.floor(math.ceil(math3d.index(maxv, 1)) / unit),  math.floor(math.ceil(math3d.index(maxv, 3)) / unit)
    local rect = {x = minx, z = maxz - 1, w = maxx - minx, h = maxz - minz}
    sm_rect_table[#sm_rect_table+1] = rect
    return rect
end


local function set_sm_grid(rect)
    local ox, oz, ww, hh = rect.x + offset, rect.z + offset, rect.w, rect.h
    for ih = 0, hh - 1 do
        for iw = 0, ww - 1 do
            local xx, zz = ox + iw, oz - ih
            local sm_idx = xx + zz * width + 1
            sm_grid_table[sm_idx] = true
        end
    end
end

local function create_sm_entity()
    local stonemountain_info_table  = {
        {}, {}, {}, {}
    }
    for sm_idx, _ in pairs(sm_table)do
        for size_idx = 1, 3 do
            local stone = sm_table[sm_idx][size_idx]
            if stone and stone.s  then
                local mesh_idx = sm_bms_to_mesh_table[sm_idx][size_idx]
                --local mesh_address = mesh_table[mesh_idx]
                stonemountain_info_table[mesh_idx][#stonemountain_info_table[mesh_idx]+1] = {
                    {stone.s, stone.t.x, stone.t.z, stone.r}
                }
                local scale = stone.s;
                local scale_y = stone.s;
                local tx = stone.t.x;
                local tz = stone.t.z;
                local cosy = stone.r;
                local scosy = cosy * scale;
                local ssiny = (1 - cosy * cosy) ^ 0.5 * scale;
                if scale_y > 1 then
                    scale_y = scale_y * 0.5
                end
                local world_mat = math3d.matrix(scosy, 0, -ssiny, 0, 0, scale_y, 0, 0, ssiny, 0, scosy, 0, tx, 0, tz ,1)
                local mesh_aabb_value = mesh_aabb_table[mesh_idx]
                local rect = set_sm_rect(mesh_aabb_value, world_mat)
                set_sm_grid(rect)
            end
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


function ism.get_sm_grid(world_x, world_z)
    local logic_x, logic_z = world_x + offset, world_z + offset
    local sm_idx = logic_z * width + logic_x + 1
    return sm_grid_table[sm_idx]
end

function ism.get_sm_rect_intersect(area)
    local minx, maxx, minz, maxz = area.x, area.x + area.w, area.z - area.h, area.z
    local intersect_rect_table = {}
    for rect_idx, rect in pairs(sm_rect_table) do
        local rminx, rmaxx, rminz, rmaxz = rect.x, rect.x + rect.w, rect.z - rect.h, rect.z
        local intersect = true
        if rminx > maxx or rmaxx < minx or rminz > maxz or rmaxz < minz then
            intersect = false
        end
        if intersect then
            intersect_rect_table[#intersect_rect_table+1] = {idx = rect_idx, rect = rect}
        end
    end
    return intersect_rect_table 
end

function ism.get_sm_rect_inside(area)
    local minx, maxx, minz, maxz = area.x, area.x + area.w, area.z - area.h, area.z
    local inside_rect_table = {}
    for rect_idx, rect in pairs(sm_rect_table) do
        local rminx, rmaxx, rminz, rmaxz = rect.x, rect.x + rect.w, rect.z - rect.h, rect.z
        if rminx > minx and rmaxx < maxx and rminz > minz and rmaxz < maxz then
            inside_rect_table[#inside_rect_table+1] = {idx = rect_idx, rect = rect}
        end 

    end
    return inside_rect_table 
end

function ism.exist_sm(areas)
    local out_area
    for sm_idx, _ in pairs(sm_table)do
        for size_idx = 1, 3 do
            local stone = sm_table[sm_idx][size_idx]
            if stone and stone.s then
                local ix, iz = math.floor(stone.t.x // unit + offset), math.floor(stone.t.z // unit + offset)
                out_area = exclude_from_open_area(ix, iz, areas)
                if out_area == false then
                    return true
                end
            end
        end
    end
    return false
end

function sm_sys:stone_mountain()
    if open_sm then
        for mesh_idx = 1, 4 do
            local aabb = assetmgr.resource(mesh_table[mesh_idx]).bounding.aabb
            local center, extent = math3d.aabb_center_extents(aabb)
            mesh_aabb_table[mesh_idx] = {center = math3d.tovalue(center), extent = math3d.tovalue(extent)}
        end
        make_sm_noise()
        create_sm_entity()
        open_sm = false
    end
end

function sm_sys:entity_init()
    for e in w:select "INIT stonemountain:update render_object?update indirect?update" do
        local stonemountain = e.stonemountain
        local max_num = 3000
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
            local instance_memory_buffer = get_instance_memory_buffer(stonemountain_info, 3000)
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

function ism.get_sm_group(mesh_idx)
    return sm_group[mesh_idx]
end
