local ecs = ...
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local motion = {}
function motion.create_motion_object(s, r, t, parent)
    if not motion.sampler_group then
        local sampler_group = ims.sampler_group()
        sampler_group:enable "view_visible"
        sampler_group:enable "scene_update"
        motion.sampler_group = sampler_group
    end
    return motion.sampler_group:create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.motion_sampler|motion_sampler",
            "ant.general|name",
        },
        data = {
            scene = {
                parent = parent,
                s = s,
                r = r,
                t = t,
            },
            motion_sampler = {},
            name = "motion_sampler",
        }
    }
end
return motion