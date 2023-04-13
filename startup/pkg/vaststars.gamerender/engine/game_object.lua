local ecs = ...
local world = ecs.world
local w = world.w

local iefk = ecs.import.interface "ant.efk|iefk"
local game_object_event = ecs.require "engine.game_object_event"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local iani = ecs.import.interface "ant.animation|ianimation"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local COLOR_INVALID <const> = math3d.constant "null"
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
local prefab_parse = require("engine.prefab_parser").parse
local replace_material = require("engine.prefab_parser").replace_material
local irl = ecs.import.interface "ant.render|irender_layer"

local function on_prefab_message(prefab, inner, cmd, ...)
    local event = game_object_event[cmd]
    if event then
        event(prefab, inner, ...)
    else
        log.error(("game_object unknown event `%s`"):format(cmd))
    end
end

local _instance_hash ; do
    local get_hash_func; do
        function get_hash_func()
            local cache = {}
            local n = 0
            return function(s)
                if cache[s] then
                    return cache[s]
                else
                    n = n + 1
                    assert(n <= 0xff)
                    cache[s] = n
                    return n
                end
            end
        end
    end

    local prefab_name_hash = get_hash_func()
    local state_hash = get_hash_func()
    local color_hash = get_hash_func()
    local animation_hash = get_hash_func()
    local animation_loop_hash = get_hash_func()
    local emissive_color_hash = get_hash_func()

    function _instance_hash(prefab_file_name, state, color, animation_name, animation_loop, emissive_color)
        local h1 = prefab_name_hash(prefab_file_name or 0)
        local h2 = state_hash(state or 0)
        local h3 = color_hash(color or 0)
        local h4 = animation_hash(animation_name or 0)
        local h5 = animation_loop_hash(animation_loop or 0)
        local h6 = emissive_color_hash(emissive_color or 0)

        return h1 | (h2 << 8) | (h3 << 16) | (h4 << 24) | (h5 << 32) | (h6 << 40) -- assuming 255 types of every parameter at most
    end
end

local _get_hitch_children ; do
    local cache = {} -- prefab_file_name + state + color -> object
    local hitch_group_id = 10000 -- see also: terrain.lua -> TERRAIN_MAX_GROUP_ID

    local function _cache_prefab_info(template)
        local effects = {}
        local slots = {}
        local scene = {}
        local animations = {}
        for _, v in ipairs(template) do
            if v.data then
                if v.data.slot then
                    slots[v.data.name] = v.data
                elseif v.data.efk and not v.data.efk.auto_play then
                    -- work effects
                    effects[#effects + 1] = {efk = v.data.efk, slotname = v.mount and template[v.mount].data.name}
                end
                if v.data.name == "Scene" and v.data.scene then -- TODO: special for hitch which attach to slot
                    scene = v.data.scene
                end
                if v.data.animation then
                    for animation_name in pairs(v.data.animation) do
                        animations[animation_name] = true
                    end
                end
            end
        end
        return scene, slots, effects, animations
    end

    function _get_hitch_children(prefab_file_path, state, color, animation_name, animation_loop, emissive_color, render_layer)
        local hash = _instance_hash(prefab_file_path, state, tostring(color), animation_name, animation_loop, tostring(emissive_color))
        if cache[hash] then
            return cache[hash]
        end

        local template = prefab_parse(prefab_file_path)
        if state == "translucent" then
            template = replace_material(template, "/pkg/vaststars.resources/materials/translucent.material")
        elseif state == "opacity" then
            template = replace_material(template, "/pkg/vaststars.resources/materials/opacity.material")
        else
            template = template
        end

        -- cache all slots & srt of the prefab
        local scene, slots, effects, animations = _cache_prefab_info(template)
        hitch_group_id = hitch_group_id + 1
        local g = ecs.group(hitch_group_id)
        g:enable "scene_update"

        log.info(("game_object.new_instance: %s"):format(table.concat({hitch_group_id, prefab_file_path, state, require("math3d").tostring(color), animation_name}, " "))) -- TODO: remove this line

        local inner = { tags = {} } -- tag -> eid
        local pose = iani.create_pose()
        local prefab = g:create_instance(template)
        prefab.on_init = function(prefab)
            for _, eid in ipairs(prefab.tag["*"]) do
                local e <close> = w:entity(eid, "scene_update_once?out")
                e.scene_update_once = true -- TODO: scene_update_once should be generated by prefab editor
            end
        end
        prefab.on_ready = function(prefab)
            for _, eid in ipairs(prefab.tag["*"]) do
                local e <close> = w:entity(eid, "tag?in animation?in anim_ctrl?in render_layer?update render_object?update")
                if e.tag then
                    for _, tag in ipairs(e.tag) do
                        inner.tags[tag] = inner.tags[tag] or {}
                        table.insert(inner.tags[tag], eid)
                    end
                end
                if e.anim_ctrl then
                    e.anim_ctrl.for_hitch = true
                    e.anim_ctrl.group_id = cache[hash].hitch_group_id
                    iani.load_events(eid, string.sub(prefab_file_path, 1, -8) .. ".event")
                end
                if render_layer and e.render_object then
                    e.render_layer = render_layer
                    e.render_object.render_layer = irl.layeridx(e.render_layer)
                end
            end

            if animation_name and animations[animation_name] then
                log.info(("prefab_file_path: %s animation_name: %s animation_loop: %s"):format(prefab_file_path, animation_name, animation_loop))
                iani.play(prefab, {name = animation_name, loop = animation_loop, speed = 1.0, manual = false, forwards = true})
            else
                if animations["ArmatureAction"] then
                    iani.play(prefab, {name = "ArmatureAction", loop = true, speed = 1.0, manual = false, forwards = true})
                end
            end
        end
        prefab.on_message = function(prefab, ...)
            on_prefab_message(prefab, inner, ...)
        end
        local instance = world:create_object(prefab)
        if state == "translucent" or state == "opacity" then
            instance:send("material", "set_property", "u_basecolor_factor", color)
        end
        if emissive_color then -- see also: meno/u_emissive_factor
            instance:send("material_tag", "set_property", "u_emissive_factor", "u_emissive_factor", emissive_color)
        end

        cache[hash] = {prefab_file_name = prefab_file_path, instance = instance, hitch_group_id = hitch_group_id, scene = scene, slots = slots, pose = pose, effects = effects, animations = animations}
        return cache[hash]
    end
end

local igame_object = ecs.interface "igame_object"
--[[
init = {
    prefab, -- the relative path to the prefab file
    effect, -- the relative path to the effect file
    group_id, -- the group id of the hitch, used to cull the hitch
    state, -- "translucent", "opaque", "opacity"
    color,
    srt,
    parent, -- the parent of the hitch
    slot, -- the slot of the hitch
    animation_name,
    emissive_color,
    render_layer,
}
--]]
function igame_object.create(init)
    local children = _get_hitch_children(RESOURCES_BASE_PATH:format(init.prefab), init.state, init.color, init.animation_name, init.animation_loop or false, init.emissive_color, init.render_layer)
    local hitch_events = {}
    hitch_events["group"] = function(_, e, group)
        w:extend(e, "hitch:update")
        e.hitch.group = group
    end
    hitch_events["slot_pose"] = function(_, e, pose)
        w:extend(e, "slot:in")
        e.slot.pose = pose
    end
    hitch_events["obj_motion"] = function(_, e, method, ...)
        iom[method](e, ...)
    end

    local policy = {
        "ant.general|name",
        "ant.scene|hitch_object",
    }
    if init.slot then
        policy[#policy+1] = "ant.animation|slot"
    end

    local hitch_entity_object = ientity_object.create(ecs.group(init.group_id):create_entity{
        policy = policy,
        data = {
            name = init.prefab, -- for debug
            scene = {
                s = init.srt.s,
                t = init.srt.t,
                r = init.srt.r,
                parent = init.parent,
            },
            hitch = {
                group = children.hitch_group_id,
            },
            slot = init.slot,
            scene_needchange = true,
        }
    }, hitch_events)

    local function remove(self)
        self.hitch_entity_object:remove()
    end

    local function update(self, prefab_file_name, state, color, animation_name, animation_loop, emissive_color)
        children.instance:send("detach_hitch", hitch_entity_object.id)
        children = _get_hitch_children(RESOURCES_BASE_PATH:format(prefab_file_name), state, color, animation_name, animation_loop, emissive_color)
        children.instance:send("attach_hitch", hitch_entity_object.id)

        self.hitch_entity_object:send("group", children.hitch_group_id)
        for _, slot_game_object in pairs(self.slot_attach) do
            slot_game_object.hitch_entity_object:send("slot_pose", children.pose)
        end
    end
    local function has_animation(self, animation_name)
        return children.animations[animation_name] ~= nil
    end
    local function attach(self, slot_name, model, state, color)
        local s = children.slots[slot_name]
        if not s then
            log.error(("game_object.attach: slot %s not found"):format(slot_name))
            return
        end
        local _slot = {}
        for k, v in pairs(s.slot) do
            _slot[k] = v
        end
        _slot.pose = children.pose

        -- TODO: create a new entity for hitch's parent
        -- slot.offset_srt is the offset of the slot when the slot is attached to the bone
        -- slot.scene is the offset of the slot when the slot not attached to the bone
        -- children.scene: offset of the parent
        self.slot_attach[slot_name] = igame_object.create {
            prefab = model,
            group_id = init.group_id,
            state = state or "opaque",
            color = color or COLOR_INVALID,
            srt = children.scene, -- TODO: slot scene
            parent = self.hitch_entity_object.id,
            slot = _slot,
        }
    end
    local function detach(self)
        for _, v in pairs(self.slot_attach) do
            v:remove()
        end
        self.slot_attach = {}
    end
    local function send(self, ...)
        self.hitch_entity_object:send(...)
    end

    -- special for hitch
    local effects = {}
    for _, efkinfo in ipairs(children.effects) do
        effects[#effects + 1] = iefk.create(efkinfo.efk.path, {
            auto_play = efkinfo.efk.auto_play or false,
            loop = efkinfo.efk.loop or false,
            speed = efkinfo.efk.loop or 1.0,
            scene = {
                parent = hitch_entity_object.id
            }
        })
    end

    children.instance:send("attach_hitch", hitch_entity_object.id)

    local outer = {hitch_entity_object = hitch_entity_object, slot_attach = {}}
    outer.remove = remove
    outer.update = update
    outer.attach = attach
    outer.detach = detach
    outer.send   = send
    outer.has_animation = has_animation
    outer.on_work = function ()
        local effeting = false
        if #effects > 0 then
            -- when multiple effects are playing simultaneously, only the first effect is checked to see if it is playing.
            -- if the first effect is playing, it is assumed that all effects are playing.
            local e <close> = w:entity(effects[1])
            effeting = iefk.is_playing(e)
        end
        if not effeting then
            for _, eid in ipairs(effects) do
                local e <close> = w:entity(eid)
                iefk.play(e)
            end
        end
    end
    outer.on_idle = function ()
        local effeting = false
        if #effects > 0 then
            local e <close> = w:entity(effects[1])
            effeting = iefk.is_playing(e)
        end
        if effeting then
            for _, eid in ipairs(effects) do
                local e <close> = w:entity(eid)
                iefk.stop(e, true)
            end
        end
    end
    return outer
end

function igame_object.get_prefab(prefab)
    return _get_hitch_children(RESOURCES_BASE_PATH:format(prefab), "opaque", COLOR_INVALID, nil, nil, nil)
end
