local ecs   = ...
local world = ecs.world
local w     = world.w

local INV_Z <const> = true

local math3d    = require "math3d"
local CUSTOM_NEAR_PLANE <const> = math3d.constant("v4", {0, 1, 0, 5})
local CUSTOM_FAR_PLANE <const>  = math3d.constant("v4", {0, 1, 0, 0})

local mathpkg   = import_package "ant.math"
local mu        = mathpkg.util

local irq       = ecs.require "ant.render|render_system.renderqueue"

local sb_sys = ecs.system "scene_bounding_system"

local function get_frustum_points_rays(points)
    local rays = {}
    if INV_Z then
        for i = 1, 4 do
            rays[#rays+1] = mu.create_ray(math3d.array_index(points, i+4), math3d.array_index(points, i))
        end
    else
        for i = 1, 4 do
            rays[#rays+1] = mu.create_ray(math3d.array_index(points, i), math3d.array_index(points, i+4))
        end
    end
    return rays
end

local function ray_intersect_nearfar_planes(rays)
    local p = {}
    for _, r in ipairs(rays) do
        local function intersect_plane(plane)
            local t = math3d.plane_ray(r.o, r.d, plane)
            assert(0 <= t and t <= 1.0, "We assume scene between near and far plane")
            p[#p+1] =  mu.ray_point(r, t)
        end
        intersect_plane(CUSTOM_NEAR_PLANE)
        intersect_plane(CUSTOM_FAR_PLANE)
    end

    return p
end

local function find_zn_zf(points, Cv)
    local nc = math3d.mul(0.5, math3d.add(math3d.array_index(points, 2), math3d.array_index(points, 3)))
    local fc = math3d.mul(0.5, math3d.add(math3d.array_index(points, 6), math3d.array_index(points, 7)))

    local r = mu.create_ray(nc, fc)
    local znpt = mu.ray_point(r, math3d.plane_ray(r.o, r.d, CUSTOM_NEAR_PLANE))
    local zfpt = mu.ray_point(r, math3d.plane_ray(r.o, r.d, CUSTOM_FAR_PLANE))

    return math3d.index(math3d.transform(Cv, znpt, 1), 3), math3d.index(math3d.transform(Cv, zfpt, 1), 3)
end

function sb_sys:update_camera()
    local C = irq.main_camera_changed()
    if not C then
        return
    end

    w:extend(C, "camera:in")
    local sbe = w:first "shadow_bounding:update"
    local points = math3d.frustum_points(C.camera.viewprojmat)
    local rays = get_frustum_points_rays(points)
    local newaabb = math3d.minmax(ray_intersect_nearfar_planes(rays))
    local zn, zf = find_zn_zf(points, C.camera.viewmat)
    sbe.shadow_bounding.scene_info = {
        PSR = math3d.marked_aabb(newaabb),
        zn = zn,
        zf = zf,
    }
    w:submit(sbe)

end

