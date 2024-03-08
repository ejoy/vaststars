local ecs = ...
local world = ecs.world
local w = world.w

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local iom       = ecs.require "ant.objcontroller|obj_motion"
local irl       = ecs.require "ant.render|render_layer.render_layer"
local ig        = ecs.require "ant.group|group"
local imodifier = ecs.require "ant.modifier|modifier"
local itl       = ecs.require "ant.timeline|timeline"
local imessage  = ecs.require "message_sub"
local imaterial = ecs.require "ant.render|material"
local iefk      = ecs.require "ant.efk|efk"
local iplayback = ecs.require "ant.animation|playback"
local ihitch    = ecs.require "ant.render|hitch.hitch"

imessage:sub("game_object|stop_world", function(prefab)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, false)
        end
        if e.efk then
            iefk.pause(e, true)
        end
    end
end)

imessage:sub("game_object|restart_world", function(prefab)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, true)
        end
        if e.efk then
            iefk.pause(e, false)
        end
    end
end)

local _calc_hash ; do
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
    local emissive_color_hash = get_hash_func(0xf)
    local render_layer_hash = get_hash_func(0xf)

    function _calc_hash(prefab, color, emissive_color, render_layer)
        local h1 = prefab_hash(prefab or 0) -- 8 bits
        local h2 = color_hash(color or 0) -- 4 bits
        local h3 = emissive_color_hash(emissive_color or 0) -- 4 bits
        local h4 = render_layer_hash(render_layer or 0) -- 4 bits
        return h1 | (h2 << 8) | (h3 << 12) | (h4 << 16)
    end
end

local _create_prefab, _get_hitch_group_id, _stop_world, _restart_world ; do
    local cache = {}
    local next_hitch_group = 1

    function _create_prefab(prefab, color, emissive_color, render_layer, dynamic_mesh)
        local hitch_group_id = ig.register("HITCH_GROUP_" .. next_hitch_group)
        next_hitch_group = next_hitch_group + 1

        local inst = world:create_instance {
            prefab = prefab,
            group = hitch_group_id,
            on_ready = function (self)
                local exclude = self.tag["no_color_factors"] or {}

                for _, eid in ipairs(self.tag["*"]) do
                    local e <close> = world:entity(eid, "render_object?update dynamic_mesh?out draw_indirect?in")
                    if e.draw_indirect then
                        e.draw_indirect.cid = ihitch.create_compute_entity() 
                    end
                    if render_layer and e.render_object then
                        irl.set_layer(e, render_layer)
                    end

                    if not exclude[eid] then
                        w:extend(e, "material?in")
                        if e.material then
                            if color then
                                imaterial.set_property(e, "u_basecolor_factor", color)
                            end
                            if emissive_color then
                                imaterial.set_property(e, "u_emissive_factor", emissive_color)
                            end
                        end
                    end
                end

                for _, eid in ipairs(self.tag["timeline"] or {}) do
                    local e <close> = world:entity(eid, "timeline?in loop_timeline?out")
                    e.timeline.eid_map = self.tag
                    itl:start(e)

                    if e.timeline.loop == true then
                        e.loop_timeline = true
                    end
                end
            end,
        }


        return hitch_group_id, inst
    end

    function _get_hitch_group_id(prefab, color, emissive_color, render_layer, dynamic_mesh)
        if not dynamic_mesh then
            prefab = prefab:gsub("(%.[^%.]+)$", "_di%1")
        end
        render_layer = render_layer or RENDER_LAYER.BUILDING
        local hash = _calc_hash(prefab, tostring(color), tostring(emissive_color), render_layer)
        if cache[hash] then
            return assert(cache[hash].hitch_group_id)
        end

        local hitch_group_id, inst = _create_prefab(prefab, color, emissive_color, render_layer, dynamic_mesh)
        cache[hash] = {instance = inst, hitch_group_id = hitch_group_id}
        return hitch_group_id
    end

    function _stop_world()
        for _, v in pairs(cache) do
            imessage:pub("game_object|stop_world", v.instance)
        end
    end

    function _restart_world()
        for _, v in pairs(cache) do
            imessage:pub("game_object|restart_world", v.instance)
        end
    end
end

local function _update_group(self, group)
    local e <close> = world:entity(self.tag["hitch"][1])
    w:extend(e, "hitch:update hitch_update?out")
    e.hitch.group = group
    e.hitch_update = true
end
imessage:sub("hitch_instance|update_group", _update_group)

imessage:sub("hitch_instance|modifier", function(self, ...)
    imodifier.start(imodifier.create_bone_modifier(self.tag["hitch"][1], 0, "/pkg/vaststars.resources/glbs/animation/Interact_build.glb|mesh.prefab", "Bone"), ...)
end)

imessage:sub("hitch_instance|attach", function(self, slot_name, instance)
    local eid = assert(self.tag[slot_name][1])
    world:instance_set_parent(instance, eid)
end)

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
function igame_object.preload(init)
    _create_prefab(init.prefab, init.color, init.emissive_color, init.render_layer, init.dynamic)
end

--[[
init = {
    prefab, -- the relative path to the prefab file
    group_id, -- the group id of the hitch, used to cull the hitch
    color,
    srt,
    parent, -- the parent of the hitch
    emissive_color,
    render_layer,
    on_ready,
}
--]]
function igame_object.create(init)
    local hitch_group_id = _get_hitch_group_id(init.prefab, init.color, init.emissive_color, init.render_layer, init.dynamic)
    local srt = init.srt or {}

    local hitch_instance = world:create_instance {
        group = init.group_id,
        prefab = init.prefab:gsub("^(.*%.glb|)(.*%.prefab)$", "%1hitch.prefab"),
        parent = init.parent,
        on_ready = function(self)
            local root <close> = world:entity(self.tag["hitch"][1])
            set_srt(root, srt)
            _update_group(self, hitch_group_id)
            if init.on_ready then
                init.on_ready(self)
            end
        end,
    }

    local function remove(self)
        imessage:pub("remove", self.hitch_instance)
    end

    local function update(self, t)
        for k, v in pairs(t) do
            if v == "null" then
                self.data[k] = nil
            else
                self.data[k] = v
            end
        end

        local hitch_group_id = _get_hitch_group_id(
            self.data.prefab,
            self.data.color,
            self.data.emissive_color,
            self.data.render_layer,
            self.data.dynamic
        )

        imessage:pub("hitch_instance|update_group", self.hitch_instance, hitch_group_id)
        self.hitch_group_id = hitch_group_id
    end
    local function send(self, msg, ...)
        imessage:pub(msg, self.hitch_instance, ...)
    end
    local function modifier(self, method, ...)
        imessage:pub("hitch_instance|modifier", self.hitch_instance, method, ...)
    end
    local function get_slot_position(self, slot_name)
        assert(self.hitch_instance)
        local eid = assert(self.hitch_instance.tag[slot_name][1])
        local e <close> = assert(world:entity(eid))
        return iom.worldmat(e)
    end

    local outer = {
        data = init,
        group_id = init.group_id,
        hitch_instance = hitch_instance,
        hitch_group_id = hitch_group_id,
    }
    outer.modifier = modifier
    outer.remove = remove
    outer.update = update
    outer.send   = send
    outer.get_slot_position = get_slot_position
    return outer
end

function igame_object.stop_world()
    _stop_world()
end

function igame_object.restart_world()
    _restart_world()
end

return igame_object
