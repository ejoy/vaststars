local ecs = ...
local world = ecs.world
local w = world.w

local ims = ecs.require "ant.motion_sampler|motion_sampler"
local iprototype = require "gameplay.interface.prototype"
local ivs = ecs.require "ant.render|visible_state"
local ig = ecs.require "ant.group|group"
local ientity = ecs.require "ant.render|components.entity"
local irl = ecs.require "ant.render|render_layer.render_layer"
local igame_object = ecs.require "engine.game_object"

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local ltween = require "motion.tween"
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"

local sampler_group

local function create(prefab, s, r, t)
    if not sampler_group then
        sampler_group = ims.sampler_group()
        ig.enable(sampler_group, "view_visible", sampler_group)
    end

    local outer = {
        item_classid = 0,
        item_amount = 0,
    }
    local motion_entity; motion_entity = world:create_entity {
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
                outer.motion = motion_entity
                ims.set_tween(e, ltween.type("None"), ltween.type("None"))
            end
        }
    }
    local lorry_obj = igame_object.create {
        prefab = prefab,
        group_id = 0,
        parent = motion_entity,
        render_layer = RENDER_LAYER.LORRY,
    }
    local shadow_minv, shadow_maxv = 1, 0
    local shadow_x, shadow_z = -5, -5
    local shadow_w, shadow_h = 10, 10
    local shadow_entity = world:create_entity {
        policy = {
            "ant.render|simplerender",
        },
        data = {
            simplemesh = ientity.create_mesh({"p3|t2", {
                shadow_x,            0, shadow_z,            0, shadow_minv, --bottom left
                shadow_x,            0, shadow_z + shadow_h, 0, shadow_maxv, --top left
                shadow_x + shadow_w, 0, shadow_z,            1, shadow_minv, --bottom right
                shadow_x + shadow_w, 0, shadow_z + shadow_h, 1, shadow_maxv, --top right
            }}),
            material = "/pkg/vaststars.resources/materials/lorry_shadow.material",
            scene = {t = {0, 0.1, 0}, parent = motion_entity},
            visible_state = "main_view",
            render_layer = RENDER_LAYER.LORRY_SHADOW,
        }
    }
    local arrow_instance = world:create_instance {
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
    }
    lorry_obj:send("attach", "arrow", arrow_instance)

    function outer:work()
        local model = assert(prefab:match("(.*%.glb|).*%.prefab"))
        model = model .. "work.prefab"
        lorry_obj:update({workstatus = "work", prefab = model})
    end
    function outer:idle()
        lorry_obj:update({workstatus = "idle", prefab = prefab})
    end
    function outer:remove()
        world:remove(motion_entity)
        world:remove(lorry_obj.id)
        world:remove(shadow_entity)
        world:remove_instance(arrow_instance)
        if self.item then
            world:remove_instance(self.item)
        end
    end
    function outer:show_arrow(b)
        world:instance_message(arrow_instance, "show", b)
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

        self.item = world:create_instance {
            prefab = RESOURCES_BASE_PATH:format(typeobject.item_model),
            on_ready = function(self)
                for _, eid in ipairs(self.tag['*']) do
                    local e <close> = world:entity(eid, "render_object?in")
                    if e.render_object then
                        irl.set_layer(e, RENDER_LAYER.LORRY_ITEM)
                    end
                end
            end,
        }
        lorry_obj:send("attach", "item", self.item)
    end
    return outer
end
return create
