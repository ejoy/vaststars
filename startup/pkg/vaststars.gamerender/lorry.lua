local ecs = ...
local world = ecs.world
local w = world.w

local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local ltween = require "motion.tween"

local sampler_group

local function _create_motion_object(s, r, t)
    local events = {}
    events["set_target"] = function(_, e, from_srt, to_srt, duration)
        ims.set_tween(e, ltween.type("Quartic"), ltween.type("Quartic"))
        ims.set_duration(e, duration)
        ims.set_keyframes(e,
            {s = from_srt.s, r = from_srt.r, t = from_srt.t, step = 0.0},
            {s = to_srt.s, r = to_srt.r, t = to_srt.t, step = 1.0}
        )
    end
    return ientity_object.create(sampler_group:create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.motion_sampler|motion_sampler",
            "ant.general|name",
        },
        data = {
            scene = {
                s = s,
                r = r,
                t = t,
            },
            motion_sampler = {},
            name = "motion_sampler",
        }
    }, events)
end

local function _create_prefab_object(prefab, parent)
    local p = sampler_group:create_instance(prefab, parent)
    function p:on_ready()
    end
    function p:on_message()
    end
    return world:create_object(p)
end

local function _create_shadow_object(parent)
    local ientity = ecs.import.interface "ant.render|ientity"
    local minv, maxv = 1, 0
    local x, z = -5, -5
    local w = 10
    local h = 10
    return ientity_object.create(ecs.create_entity {
        policy = {
            "ant.render|simplerender",
            "ant.general|name",
        },
        data = {
            simplemesh = ientity.create_mesh({"p3|t2", {
                x, 		0,	z, 	    0, minv,	--bottom left
                x,		0, 	z + h, 	0, maxv,	--top left
                x + w, 	0,	z, 	    1, minv,	--bottom right
                x + w, 	0, 	z + h, 	1, maxv,	--top right
            }}),
            material = "/pkg/vaststars.resources/materials/lorry_shadow.material",
            scene = {t = {0, 0.1, 0}, parent = parent},
            visible_state = "main_view",
            name = "lorry_shadow",
            render_layer = RENDER_LAYER.LORRY_SHADOW,
        }
    })
end

local function _create_cargo_object(prefab, parent)
    local p = sampler_group:create_instance(prefab, parent)
    function p:on_ready()
    end
    return world:create_object(p)
end

local function create(prefab, s, r, t)
    if not sampler_group then
        sampler_group = ims.sampler_group()
        sampler_group:enable "view_visible"
        sampler_group:enable "scene_update"
    end

    local outer = {objs = {}, s, r, t}
    local motion_obj = _create_motion_object(s, r, t)
    local prefab_obj = _create_prefab_object(prefab, motion_obj.id)
    local shadow_obj = _create_shadow_object(motion_obj.id)
    outer.objs[#outer.objs + 1] = motion_obj
    outer.objs[#outer.objs + 1] = prefab_obj
    outer.objs[#outer.objs + 1] = shadow_obj

    function outer:remove()
        for _, obj in ipairs(self.objs) do
            obj:remove()
        end
    end
    function outer:set_cargo(prefab)
        local cargo_obj = _create_cargo_object(prefab, motion_obj.id)
        outer.objs[#outer.objs + 1] = cargo_obj
    end
    function outer:reset_cargo()
        if #outer.objs > 3 then
            outer.objs[#outer.objs]:remove()
            outer.objs[#outer.objs] = nil
        end
    end
    function outer:set_target(s, r, t, duration)
        motion_obj:send("set_target", {s = self.s, r = self.r, t = self.t}, {s = s, r = r, t = t}, duration)
        self.s, self.r, self.t = s, r, t
    end

    return outer
end
return create