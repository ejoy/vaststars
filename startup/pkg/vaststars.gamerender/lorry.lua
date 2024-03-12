local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local irl = ecs.require "ant.render|render_layer.render_layer"
local igame_object = ecs.require "engine.game_object"
local imotion = ecs.require "engine.motion"
local itl = ecs.require "ant.timeline|timeline"
local imessage = ecs.require "message_sub"

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local function create(prefab, s, r, t)
    local motion_entity = imotion.create_motion_object(s, r, t)
    local outer = {
        item_classid = 0,
        item_amount = 0,
        motion = motion_entity,
    }
    local lorry_obj = igame_object.create {
        prefab = prefab,
        group_id = 0,
        parent = motion_entity,
        render_layer = RENDER_LAYER.LORRY,
        dynamic = true,
    }
    local arrow_instance = world:create_instance {
        prefab = "/pkg/vaststars.resources/glbs/road/arrow.glb|mesh.prefab",
        on_ready = function(self)
            for _, eid in ipairs(self.tag['*']) do
                local e <close> = world:entity(eid, "visible?out render_object?in timeline?in loop_timeline?out")
                e.visible = false
                if e.render_object then
                    irl.set_layer(e, RENDER_LAYER.LORRY_ITEM)
                end
                if e.timeline then
                    e.timeline.eid_map = self.tag
                    itl:start(e)

                    if e.timeline.loop == true then
                        e.loop_timeline = true
                    end
                end
            end
        end,
    }
    lorry_obj:send("hitch_instance|attach", "arrow", arrow_instance)

    local idle_prefab <const> = prefab
    local work_prefab <const> = igame_object.replace_prefab(prefab, "work.prefab")

    function outer:work()
        lorry_obj:update {prefab = work_prefab}
    end
    function outer:idle()
        lorry_obj:update {prefab = idle_prefab}
    end
    function outer:remove()
        world:remove_entity(motion_entity)
        lorry_obj:remove()
        world:remove_instance(arrow_instance)
        if self.item then
            self.item:remove()
        end
    end
    function outer:show_arrow(b)
        imessage:pub("show", arrow_instance, b)
    end
    function outer:set_item(item_classid, item_amount)
        if self.item_classid == item_classid and self.item_amount == item_amount then
            return
        end
        self.item_classid = item_classid
        self.item_amount = item_amount

        if item_classid == 0 or item_amount == 0 then
            if self.item then
                self.item:remove()
                self.item = nil
            end
            return
        end

        if self.item then
            self.item:remove()
        end

        local typeobject = iprototype.queryById(item_classid) or error(("item_classid %d not found"):format(item_classid))
        assert(typeobject.item_model)

        self.item = igame_object.create {
            prefab = typeobject.item_model,
            on_ready = function(self)
                for _, eid in ipairs(self.tag['*']) do
                    local e <close> = world:entity(eid, "render_object?in")
                    if e.render_object then
                        irl.set_layer(e, RENDER_LAYER.LORRY_ITEM)
                    end
                end
            end,
        }
        lorry_obj:send("hitch_instance|attach", "item", self.item.hitch_instance)
    end
    return outer
end
return create
