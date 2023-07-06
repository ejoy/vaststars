local ecs = ...
local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"

local events = {
    ["motion"] = function(_, e, method, ...)
        ims[method](e, ...)
    end
}

local motion = {}
function motion.create_motion_object(s, r, t, parent, ev)
    if not motion.sampler_group then
        local sampler_group = ims.sampler_group()
        sampler_group:enable "scene_update"
        motion.sampler_group = sampler_group
    end
    local m_eid = motion.sampler_group:create_entity {
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
    return ev and ientity_object.create(m_eid, events) or m_eid
end
return motion