local ecs   = ...
local world = ecs.world
local w     = world.w

local INV_Z <const> = true

local math3d    = require "math3d"
local CUSTOM_NPLANE <const> = math3d.constant("v4", {0, 1, 0, 5})
local CUSTOM_FPLANE <const> = math3d.constant("v4", {0, 1, 0, 0})

local cbp_sys = ecs.system "camera_bounding_pack_system"

function cbp_sys:update_camera()
    local sbe = w:first "shadow_bounding:update"
    local mq = w:first "main_queue camera_ref:in"
	local ce <close> = world:entity(mq.camera_ref, "camera_changed?in camera:in scene:in")
    if sbe and ce.camera_changed then
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
                ipoints[#ipoints+1] = math3d.add(math3d.mul(math3d.plane_ray(o, nray, plane), nray), o)
            end
        end
        
        get_frustum_points_rays()
        ray_intersect_with_plane(CUSTOM_NPLANE)
        ray_intersect_with_plane(CUSTOM_FPLANE)
        local aabb_min, aabb_max = math3d.minmax(ipoints)
        math3d.unmark(sbe.shadow_bounding.camera_aabb)
        sbe.shadow_bounding.camera_aabb = math3d.marked_aabb(aabb_min, aabb_max)
        w:submit(sbe)
    end

end

