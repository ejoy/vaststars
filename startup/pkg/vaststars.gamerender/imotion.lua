local ecs = ...
local world = ecs.world

local ims   = ecs.require "ant.motion_sampler|motion_sampler"
local ig    = ecs.require "ant.group|group"

local motion = {}
function motion.create_motion_object(s, r, t, parent)
    if not motion.sampler_group then
        local gid = ims.sampler_group()
        ig.enable(gid, "view_visible", true)
        motion.sampler_group = gid
    end
    local m_eid = world:create_entity {
        group = motion.sampler_group,
        policy = {
            "ant.scene|scene_object",
            "ant.motion_sampler|motion_sampler",
        },
        data = {
            scene = {
                parent = parent,
                s = s,
                r = r,
                t = t,
            },
            motion_sampler = {},
        }
    }
    return m_eid
end

return motion
