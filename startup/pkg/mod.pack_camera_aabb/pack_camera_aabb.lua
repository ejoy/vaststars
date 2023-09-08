local ecs   = ...
local world = ecs.world
local w     = world.w

local pca_sys = ecs.system "pack_camera_aabb_system"
local math3d    = require "math3d"
local setting	= import_package "ant.settings"
local ENABLE_SHADOW<const> = setting:get "graphic/shadow/enable"
local renderutil= ecs.require "ant.render|util"
if not ENABLE_SHADOW then
	renderutil.default_system(pca_sys, "data_changed")
	return
end

local INV_Z<const> = true
local CUSTOM_NPLANE<const>  = math3d.ref(math3d.plane(math3d.vector(0, 5, 0), math3d.vector(0, 1, 0)))
local CUSTOM_FPLANE<const>  = math3d.ref(math3d.plane(math3d.vector(0, 0, 0), math3d.vector(0, 1, 0)))

function pca_sys:data_changed()
    for pcae in w:select "pack_camera_aabb:update" do
        local mq = w:first "main_queue camera_ref:in"
        local ce <close> = world:entity(mq.camera_ref, "camera_changed?in camera:in scene:in")
        local main_camera = ce.camera
        local world_frustum_points = math3d.frustum_points(main_camera.viewprojmat)
        local keys, fpoints, rays, ipoints = {}, {}, {}, {}
        local function get_frustum_points_rays()
            if INV_Z then
                keys = {"lbf", "ltf", "rbf", "rtf", "lbn", "ltn", "rbn", "rtn"}
            else
                keys = {"lbn", "ltn", "rbn", "rtn", "lbf", "ltf", "rbf", "rtf"}
            end
            for i, n in ipairs(keys) do
                fpoints[n] = math3d.array_index(world_frustum_points, i)
            end
            rays.lbn, rays.ltn, rays.rbn, rays.rtn = math3d.sub(fpoints.lbf, fpoints.lbn), math3d.sub(fpoints.ltf, fpoints.ltn), math3d.sub(fpoints.rbf, fpoints.rbn), math3d.sub(fpoints.rtf, fpoints.rtn)
            rays.lbn, rays.ltn, rays.rbn, rays.rtn = math3d.normalize(rays.lbn), math3d.normalize(rays.ltn), math3d.normalize(rays.rbn),math3d.normalize(rays.rtn)
        end
        local function ray_intersect_with_plane(plane)
            for n, nray in pairs(rays) do
                local o = fpoints[n]
                ipoints[#ipoints+1] = math3d.add(math3d.mul(math3d.plane_ray(o, math3d.normalize(nray), plane.v), nray), o)
            end
        end
        get_frustum_points_rays()
        ray_intersect_with_plane(CUSTOM_NPLANE)
        ray_intersect_with_plane(CUSTOM_FPLANE)
        local aabb_min, aabb_max = math3d.minmax(ipoints)
        pcae.pack_camera_aabb = math3d.ref(math3d.aabb(aabb_min, aabb_max))          
    end
end

