local ecs = ...
local world = ecs.world
local w = world.w

local ims = ecs.import.interface "ant.motion_sampler|imotion_sampler"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local iprototype = require "gameplay.interface.prototype"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant

local prefab_slots = require("engine.prefab_parser").slots
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local ltween = require "motion.tween"
local ITEM_INDEX <const> = 4
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"

local sampler_group

local function __create_motion_object(s, r, t, events)
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
            on_ready = function(e)
                ims.set_tween(e, ltween.type("None"), ltween.type("None"))
            end
        }
    }, events)
end

local function __create_lorry_object(prefab, parent)
    local p = sampler_group:create_instance(prefab, parent)
    function p:on_ready()
    end
    function p:on_message()
    end
    return world:create_object(p)
end

local function __create_shadow_object(parent)
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

local function __create_item_object(prefab, parent, offset_srt)
    local p = sampler_group:create_instance(prefab, parent)
    function p:on_ready()
        local root <close> = w:entity(self.tag['*'][1])
        iom.set_srt(root, offset_srt.s or mc.ONE, offset_srt.r or mc.IDENTITY_QUAT, offset_srt.t or mc.ZERO_PT)

        for _, eid in ipairs(self.tag['*']) do
            local e <close> = w:entity(eid, "visible_state?in")
            if e.visible_state then
                ivs.set_state(e, "cast_shadow", false)
            end
        end
    end
    return world:create_object(p)
end

local function create(prefab, s, r, t, motion_events)
    if not sampler_group then
        sampler_group = ims.sampler_group()
        sampler_group:enable "view_visible"
        sampler_group:enable "scene_update"
    end

    local outer = {objs = {}, item_classid = 0, item_amount = 0}
    local motion_obj = __create_motion_object(s, r, t, motion_events)
    local prefab_obj = __create_lorry_object(prefab, motion_obj.id)
    local shadow_obj = __create_shadow_object(motion_obj.id)
    outer.objs[#outer.objs + 1] = motion_obj
    outer.objs[#outer.objs + 1] = prefab_obj
    outer.objs[#outer.objs + 1] = shadow_obj

    function outer:remove()
        for _, obj in ipairs(self.objs) do
            obj:remove()
        end
    end
    function outer:set_item(item_classid, item_amount)
        if self.item_classid == item_classid then
            return
        end
        self.item_classid = item_classid

        if item_classid == 0 then
            return
        end

        if self.objs[ITEM_INDEX] then
            self.objs[ITEM_INDEX]:remove()
        end

        local typeobject = iprototype.queryById(item_classid)
        assert(typeobject.pile_model)
        local slots = prefab_slots(prefab)
        assert(slots.item)

        self.objs[ITEM_INDEX] = __create_item_object(RESOURCES_BASE_PATH:format(typeobject.pile_model), motion_obj.id, slots.item.scene)
    end
    function outer:motion_opt(...)
        motion_obj:send(...)
    end
    return outer
end
return create