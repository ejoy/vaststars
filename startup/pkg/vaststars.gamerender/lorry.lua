local ecs = ...
local world = ecs.world
local w = world.w

local ims = ecs.require "ant.motion_sampler|motion_sampler"
local ientity_object = ecs.require "engine.system.entity_object_system"
local iprototype = require "gameplay.interface.prototype"
local ivs = ecs.require "ant.render|visible_state"
local ig = ecs.require "ant.group|group"

local irl = ecs.require "ant.render|render_layer.render_layer"
local igame_object = ecs.require "engine.game_object"

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local ltween = require "motion.tween"
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"

local sampler_group

local function __create_motion_object(s, r, t, events)
    return ientity_object.create(world:create_entity {
        group = sampler_group,
        policy = {
            "ant.scene|scene_object",
            "ant.motion_sampler|motion_sampler",
        },
        data = {
            scene = {
                s = s,
                r = r,
                t = t,
            },
            motion_sampler = {},
            on_ready = function(e)
                ims.set_tween(e, ltween.type("None"), ltween.type("None"))
            end
        }
    }, events)
end

local function __create_lorry_object(prefab, parent)
    return igame_object.create {
        prefab = prefab,
        group_id = 0,
        parent = parent,
        render_layer = RENDER_LAYER.LORRY,
    }
end

local function __create_shadow_object(parent)
    local ientity = ecs.require "ant.render|components.entity"
    local minv, maxv = 1, 0
    local x, z = -5, -5
    local w = 10
    local h = 10
    return ientity_object.create(world:create_entity {
        policy = {
            "ant.render|simplerender",
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
            render_layer = RENDER_LAYER.LORRY_SHADOW,
        }
    })
end

local function create(prefab, s, r, t, motion_events)
    if not sampler_group then
        sampler_group = ims.sampler_group()
        ig.enable(sampler_group, "view_visible", sampler_group)
    end

    local outer = {
        objs = {},
        item_classid = 0,
        item_amount = 0,
    }
    local motion_obj = __create_motion_object(s, r, t, motion_events)
    local lorry_obj = __create_lorry_object(prefab, motion_obj.id)
    local shadow_obj = __create_shadow_object(motion_obj.id)
    outer.objs[#outer.objs + 1] = motion_obj
    outer.objs[#outer.objs + 1] = lorry_obj
    outer.objs[#outer.objs + 1] = shadow_obj
    outer.arrow = world:create_instance({
        prefab = "/pkg/vaststars.resources/glbs/road/arrow.glb|mesh.prefab",
        on_ready = function(self)
            for _, eid in ipairs(self.tag['*']) do
                local e <close> = world:entity(eid, "visible_state?in render_object?in")
                if e.visible_state then
                    ivs.set_state(e, "cast_shadow", false)
                    ivs.set_state(e, "main_view", false)
                end
                if e.render_object then
                    irl.set_layer(e, RENDER_LAYER.LORRY_ITEM)
                end
            end
        end,
        on_message = function(self, msg, visible)
            assert(msg == "show")
            for _, eid in ipairs(self.tag['*']) do
                local e <close> = world:entity(eid, "visible_state?in render_object?in")
                if e.visible_state then
                    ivs.set_state(e, "main_view", visible)
                end
            end
        end,
    })
    lorry_obj:send("attach", "arrow", outer.arrow)

    function outer:work()
        local model = assert(prefab:match("(.*%.glb|).*%.prefab"))
        model = model .. "work.prefab"
        lorry_obj:update({workstatus = "work", prefab = model})
    end
    function outer:idle()
        lorry_obj:update({workstatus = "idle", prefab = prefab})
    end
    function outer:remove()
        for _, obj in ipairs(self.objs) do
            obj:remove()
        end
        world:remove_instance(self.arrow)
        if self.item then
            world:remove_instance(self.item)
        end
    end
    function outer:show_arrow(b)
        world:instance_message(outer.arrow, "show", b)
    end
    function outer:set_item(item_classid, item_amount)
        if self.item_classid == item_classid and self.item_amount == item_amount then
            return
        end
        self.item_classid = item_classid
        self.item_amount = item_amount

        if item_classid == 0 or item_amount == 0 then
            if self.item then
                world:remove_instance(self.item)
                self.item = nil
            end
            return
        end

        if self.item then
            world:remove_instance(self.item)
        end

        local typeobject = iprototype.queryById(item_classid) or error(("item_classid %d not found"):format(item_classid))
        assert(typeobject.item_model)

        self.item = world:create_instance({
            prefab = RESOURCES_BASE_PATH:format(typeobject.item_model),
            on_ready = function(self)
                for _, eid in ipairs(self.tag['*']) do
                    local e <close> = world:entity(eid, "render_object?in")
                    if e.render_object then
                        irl.set_layer(e, RENDER_LAYER.LORRY_ITEM)
                    end
                end
            end,
        })
        lorry_obj:send("attach", "item", self.item)
    end
    function outer:motion_opt(...)
        motion_obj:send(...)
    end
    return outer
end
return create