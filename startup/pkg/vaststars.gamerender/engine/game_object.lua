local ecs = ...
local world = ecs.world
local w = world.w
local game_object_event = ecs.require "engine.game_object_event"
local iani              = ecs.require "ant.animation|state_machine"
local iom               = ecs.require "ant.objcontroller|obj_motion"
local irl               = ecs.require "ant.render|render_layer.render_layer"
local ig                = ecs.require "ant.group|group"
local imodifier         = ecs.require "ant.modifier|modifier"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
local ANIMATIONS_BASE_PATH <const> = "/pkg/vaststars.resources/animations/"

local function on_prefab_message(prefab, cmd, ...)
    local event = game_object_event[cmd]
    if event then
        event(prefab, ...)
    else
        log.error(("game_object unknown event `%s`"):format(cmd))
    end
end

local calcHash ; do
    local function get_hash_func(max_value)
        local n = 0
        local cache = {}
        return function(s)
            if cache[s] then
                return cache[s]
            else
                assert(n <= max_value)
                cache[s] = n
                n = n + 1
                return cache[s]
            end
        end
    end

    local prefab_hash = get_hash_func(0xff)
    local color_hash = get_hash_func(0xf)
    local work_status_hash = get_hash_func(0xf)
    local emissive_color_hash = get_hash_func(0xf)
    local render_layer_hash = get_hash_func(0xf)

    function calcHash(prefab, color, work_status, emissive_color, render_layer)
        local h1 = prefab_hash(prefab or 0) -- 8 bits
        local h2 = color_hash(color or 0) -- 4 bits
        local h3 = work_status_hash(work_status or 0) -- 1 bits
        local h4 = emissive_color_hash(emissive_color or 0) -- 4 bits
        local h5 = render_layer_hash(render_layer or 0) -- 4 bits
        return h1 | (h2 << 8) | (h3 << 12) | (h4 << 13) | (h5 << 17)
    end
end

local getHitchChildren, stopWorld, restartWorld ; do
    local cache = {}
    local NEXT_HITCH_GROUP = 1

    local function getEventFile(prefab)
        local PATTERN <const> = "^.*/(.*)%.glb|.*%.prefab$"
        local match = prefab:match(PATTERN)
        local eventFile = (match or assert(prefab:match("^.*/(.*)%.prefab$"))) .. ".event"
        return ANIMATIONS_BASE_PATH .. eventFile
    end

    function getHitchChildren(prefab, color, work_status, emissive_color, render_layer)
        render_layer = render_layer or RENDER_LAYER.BUILDING
        local hash = calcHash(prefab, tostring(color), work_status, tostring(emissive_color), render_layer)
        if cache[hash] then
            return cache[hash]
        end

        local hitch_group_id = ig.register("HITCH_GROUP_" .. NEXT_HITCH_GROUP)
        NEXT_HITCH_GROUP = NEXT_HITCH_GROUP + 1

        local inst = world:create_instance {
            prefab = prefab,
            group = hitch_group_id,
            on_ready = function (self)
                for _, eid in ipairs(self.tag["*"]) do
                    local e <close> = world:entity(eid, "render_object?update anim_ctrl?in")
                    if render_layer and e.render_object then
                        irl.set_layer(e, render_layer)
                    end

                    if e.anim_ctrl then
                        -- special handling for keyframe animations
                        iani.load_events(eid, getEventFile(prefab))
                    end
                end

                -- special handling for work_start & idle_start work status
                if self.tag["animation_auto_triggered"] then
                    for _, eid in ipairs(self.tag["animation_auto_triggered"]) do
                        local e <close> = world:entity(eid, "animation_auto_triggered?out")
                        e.animation_auto_triggered = true
                    end
                end

                -- special handling for work status
                if self.tag["efk_auto_triggered"] then
                    for _, eid in ipairs(self.tag["efk_auto_triggered"]) do
                        local e <close> = world:entity(eid, "efk_auto_triggered?out")
                        e.efk_auto_triggered = true
                    end
                end
            end,
            on_message = function (self, ...)
                on_prefab_message(self, ...)
            end
        }
        if color then
            world:instance_message(inst, "material", "set_property", "u_basecolor_factor", color)
        end
        if emissive_color then
            world:instance_message(inst, "material", "set_property", "u_emissive_factor", emissive_color)
        end

        cache[hash] = {instance = inst, hitch_group_id = hitch_group_id}
        return cache[hash]
    end

    function stopWorld()
        for _, v in pairs(cache) do
            world:instance_message(v.instance, "stop_world")
        end
    end

    function restartWorld()
        for _, v in pairs(cache) do
            world:instance_message(v.instance, "restart_world")
        end
    end
end

local hitchEvents = {}
hitchEvents["group"] = function(self, group)
    local e <close> = world:entity(self.tag["hitch"][1])
    w:extend(e, "hitch:update hitch_bounding?out")
    e.hitch.group = group
    e.hitch_bounding = true
end
hitchEvents["obj_motion"] = function(self, method, ...)
    local e <close> = world:entity(self.tag["hitch"][1])
    iom[method](e, ...)
end
hitchEvents["modifier"] = function(self, method, ...)
    imodifier[method](
        self.tag["hitch"][1],
        0,
        "/pkg/vaststars.resources/glbs/animation/Interact_build.glb|mesh.prefab",
        "Bone",
        ...)
end
hitchEvents["attach"] = function(self, slot_name, instance)
    local eid = assert(self.tag[slot_name][1])
    world:instance_set_parent(instance, eid)
end

local function set_srt(e, srt)
    if srt.s then
        iom.set_scale(e, srt.s)
    end
    if srt.r then
        iom.set_rotation(e, srt.r)
    end
    if srt.t then
        iom.set_position(e, srt.t)
    end
end

local igame_object = {}
--[[
init = {
    prefab, -- the relative path to the prefab file
    group_id, -- the group id of the hitch, used to cull the hitch
    color,
    srt,
    parent, -- the parent of the hitch
    emissive_color,
    render_layer,
}
--]]
function igame_object.create(init)
    local prefab = RESOURCES_BASE_PATH:format(init.prefab)
    local glb = assert(prefab:match("^(.*%.glb)|.*%.prefab$"))
    local hitchPrefab = glb .. "|hitch.prefab"
    -- log.info(("hitch prefab: %s, group_id: %s"):format(hitchPrefab, init.group_id))

    local children = getHitchChildren(prefab, init.color, init.work_status or "idle", init.emissive_color, init.render_layer)
    local srt = init.srt or {}

    local hitchObject = world:create_instance {
        group = init.group_id,
        prefab = hitchPrefab,
        parent = init.parent,
        on_ready = function(self)
            local root <close> = world:entity(self.tag["hitch"][1])
            set_srt(root, srt)
            assert(hitchEvents["group"])(self, children.hitch_group_id)
        end,
        on_message = function(self, event, ...)
            assert(hitchEvents[event])(self, ...)
        end
    }

    local function remove(self)
        world:remove_instance(self.hitchObject)
    end

    local function update(self, t)
        for k, v in pairs(t) do
            if v == "null" then
                self.data[k] = nil
            else
                self.data[k] = v
            end
        end

        children = getHitchChildren(
            RESOURCES_BASE_PATH:format(self.data.prefab),
            self.data.color,
            self.data.work_status,
            self.data.emissive_color,
            self.data.render_layer
        )
        world:instance_message(self.hitchObject, "group", children.hitch_group_id)
    end
    local function send(self, ...)
        world:instance_message(self.hitchObject, ...)
    end
    local function modifier(self, method, ...)
        world:instance_message(self.hitchObject, "modifier", method, ...)
    end
    local function get_slot_position(self, slot_name)
        assert(self.hitchObject)
        local eid = assert(self.hitchObject.tag[slot_name][1])
        local e <close> = assert(world:entity(eid))
        return iom.worldmat(e)
    end

    local outer = {
        data = init,
        group_id = init.group_id,
        hitchObject = hitchObject,
    }
    outer.modifier = modifier
    outer.remove = remove
    outer.update = update
    outer.send   = send
    outer.get_slot_position = get_slot_position
    return outer
end

function igame_object.stop_world()
    stopWorld()
end

function igame_object.restart_world()
    restartWorld()
end

return igame_object
