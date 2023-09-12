local ecs   = ...
local world = ecs.world
local w     = world.w

local sau_sys = ecs.system "shadow_aabb_update_system"
local math3d    = require "math3d"
local setting	= import_package "ant.settings"
local ENABLE_SHADOW<const> = setting:get "graphic/shadow/enable"
local renderutil= ecs.require "ant.render|util"
if not ENABLE_SHADOW then
	renderutil.default_system(sau_sys, "entity_ready", "update_camera")
	return
end

local INV_Z<const> = true
local CUSTOM_NPLANE<const>  = math3d.ref(math3d.vector(0, 1, 0, 5))
local CUSTOM_FPLANE<const>  = math3d.ref(math3d.vector(0, 1, 0, 0))

local REMOVE_DEFAULT_UPDATE_CAMERA = false
local CLOSE_SCENE_UPDATE = false

function sau_sys:entity_ready()
    if not REMOVE_DEFAULT_UPDATE_CAMERA then
        for e in w:select "main_camera_aabb:update" do
            e.main_camera_aabb.default_update = false 
            REMOVE_DEFAULT_UPDATE_CAMERA = true
        end
    end

    if not CLOSE_SCENE_UPDATE then
        for e in w:select "pack_scene_aabb:update" do
            e.pack_scene_aabb.need_update = false
            CLOSE_SCENE_UPDATE = true
        end
    end
end

function sau_sys:update_camera()
    local mcae = w:first "main_camera_aabb:update"
    local mq = w:first "main_queue camera_ref:in"
	local ce <close> = world:entity(mq.camera_ref, "camera_changed?in camera:in scene:in")
    if mcae and ce.camera_changed then
        local main_camera = ce.camera
        local points = math3d.frustum_points(main_camera.viewprojmat)
        local fp, np
        local opoints, rays, ipoints = {}, {}, {}
        local function get_frustum_points_rays()
            for i = 1, 4 do
                fp, np = math3d.array_index(points, i+4), math3d.array_index(points, i)
                if INV_Z then
                    rays[#rays+1] = math3d.normalize(math3d.sub(np, fp))
                    opoints[#opoints+1] = fp
                else
                    rays[#rays+1] = math3d.normalize(math3d.sub(fp, np))
                    opoints[#opoints+1] = np
                end
            end
        end
        local function ray_intersect_with_plane(plane)
            for n, nray in pairs(rays) do
                local o = opoints[n]
                ipoints[#ipoints+1] = math3d.add(math3d.mul(math3d.plane_ray(o, nray, plane.v), nray), o)
            end
        end
        get_frustum_points_rays()
        ray_intersect_with_plane(CUSTOM_NPLANE)
        ray_intersect_with_plane(CUSTOM_FPLANE)
        local aabb_min, aabb_max = math3d.minmax(ipoints)
        math3d.unmark(mcae.main_camera_aabb.scene_aabb)
        mcae.main_camera_aabb.scene_aabb = math3d.marked_aabb(aabb_min, aabb_max)
        w:submit(mcae)
    end

end

