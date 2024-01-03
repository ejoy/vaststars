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
    for i = 1, 4 do
        rays[#rays+1] = mu.create_ray(math3d.array_index(points, i), math3d.array_index(points, i+4))
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
    local sceneaabbVS = math3d.minmax(points, Cv)
    return mu.aabb_minmax_index(sceneaabbVS, 3)
end

function sb_sys:update_camera_bounding()
    local C = irq.main_camera_changed()
    if not C then
        return
    end

    w:extend(C, "camera:in")
    local sbe = w:first "shadow_bounding:in"
    local sb = sbe.shadow_bounding

    local pointsWS = math3d.frustum_points(C.camera.viewprojmat)
    local raysWS = get_frustum_points_rays(pointsWS)
    local intersectpoints = ray_intersect_nearfar_planes(raysWS)
    sb.PSR = math3d.marked_aabb(math3d.minmax(intersectpoints))
    sb.zn, sb.zf = find_zn_zf(intersectpoints, C.camera.viewmat)
end

