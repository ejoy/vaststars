local ecs = ...
local world = ecs.world
local w = world.w

local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local prefab_cfgs = import_package "vaststars.config".prefab
local math3d = require "math3d"

local prefab_proxy_remove_mb = world:sub {"prefab_proxy", "remove"}
local iprefab_proxy = ecs.interface "iprefab_proxy"
local prefab_proxy_sys = ecs.system "prefab_proxy_system"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local iani = ecs.import.interface "ant.animation|ianimation"

local function destroy_proxy(ud, prefab)
    for _, e in ipairs(prefab.tag["*"]) do
        w:sync("scene:in", e)
        ipickup_mapping.unmapping(e.scene.id)
    end
    prefab:remove()
    w:remove(ud.proxy)
end

function prefab_proxy_sys:component_init()
    for _, _, ud, prefab in prefab_proxy_remove_mb:unpack() do
        for _, prefab in pairs(ud.slot_attachs) do
            world:call(prefab.root, "set_parent", nil)
            prefab:send("remove")
        end
        destroy_proxy(ud, prefab)
    end
end

local function __on_prefab_ready(ud, prefab)
    local on_pickup_mapping = ud.events.on_pickup_mapping
    for _, e in ipairs(prefab.tag["*"]) do
        w:sync("scene:in slot?in name:in _animation?in", e)

        if not on_pickup_mapping then
            ipickup_mapping.mapping(e.scene.id, ud.proxy)
        else
            on_pickup_mapping(e.scene.id)
        end

        if e._animation then
            iani.pause(e, true)
        end

        if e.slot then
            ud.slots[e.name] = e
        end
    end

    local on_ready = ud.events.on_ready
    if on_ready then
        on_ready(ud.proxy, prefab)
    end
end

local __on_prefab_message ; do
    local funcs = {}
    funcs["remove"] = function(ud, prefab)
        if next(ud.slot_attachs) then
            world:pub {"prefab_proxy", "remove", ud, prefab}
            return
        end

        destroy_proxy(ud, prefab)
    end

    do
        local function entity_play(e, state)
            w:sync("animation?in", e)
            if not e.animation then
                return
            end

            iani.play(e, state)
        end

        funcs["play_animation_once"] = function(ud, prefab, animation_name)
            local state = {name = animation_name, loop = false, manual = false, owner = ud.proxy}
            for _, e in ipairs(prefab.tag["*"]) do
                entity_play(e, state)
            end
        end
    end

    function __on_prefab_message(ud, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(ud, prefab, ...)
        end

        local on_message = ud.events.on_message
        if on_message then
            on_message(ud.proxy, prefab, cmd, ...)
        end
    end
end

-- 'prefab' must be the value returned by calling the function ecs.create_instance()
function iprefab_proxy.create(prefab, srt, v, events)
    local ud = {slots = {}, slot_attachs = {}, events = events or {}}
    prefab.on_ready = function(prefab)
        __on_prefab_ready(ud, prefab)
    end
    prefab.on_message = function(prefab, ...)
        __on_prefab_message(ud, prefab, ...)
    end
    iom.set_srt(prefab.root, srt.s, srt.r, srt.t)
    local obj = world:create_object(prefab)

    --
    v = v or {policy = {}, data = {}}
    v.policy = v.policy or {}
    v.data = v.data or {}

    v.policy[#v.policy+1] = "vaststars.utility|prefab_proxy"
    v.data.prefab_proxy = {prefab = obj, root = prefab.root, ud = ud}
    v.policy[#v.policy+1] = "ant.scene|scene_object"
    v.data.scene = {}
    v.data.reference = true

    local proxy = ecs.create_entity(v)
    ud.proxy = proxy
    return proxy
end

function iprefab_proxy.remove(entity)
    w:sync("prefab_proxy:in", entity)
    entity.prefab_proxy.prefab:send("remove")
end

function iprefab_proxy.message(proxy, ...)
    w:sync("prefab_proxy:in", proxy)
    proxy.prefab_proxy.prefab:send(...)
end

function iprefab_proxy.get_root(proxy)
    w:sync("prefab_proxy:in", proxy)
    return proxy.prefab_proxy.prefab.root
end

function iprefab_proxy.get_config_srt(prefab_file_name)
    local prefab_cfg = prefab_cfgs[prefab_file_name]
    if not prefab_cfg then
        return {}
    end

    local srt = {}
    if prefab_cfg.scale then
        srt.s = math3d.vector({prefab_cfg.scale, prefab_cfg.scale, prefab_cfg.scale})
    end

    if prefab_cfg.direction then
        srt.r = math3d.torotation(math3d.normalize(math3d.vector(prefab_cfg.direction)))
    end

    if prefab_cfg.position then
        srt.t = prefab_cfg.position
    end

    return srt
end

function iprefab_proxy.slot_attach(proxy, slot_name, prefab)
    w:sync("prefab_proxy:in", proxy)
    local ud = proxy.prefab_proxy.ud
    local slot = ud.slots[slot_name]
    if not slot then
        error(("can not found slot name (%s)"):format(slot_name))
        return
    end

    world:call(prefab.root, "set_parent", slot)
    ud.slot_attachs[slot_name] = prefab
end

function iprefab_proxy.slot_detach(proxy, slot_name)
    w:sync("prefab_proxy:in", proxy)
    local ud = proxy.prefab_proxy.ud
    local slot = ud.slots[slot_name]
    local prefab = ud.slot_attachs[slot_name]
    if not slot or not prefab then
        error(("can not found slot name (%s)"):format(slot_name))
        return
    end

    world:call(prefab.root, "set_parent", slot)
    prefab:send("remove")
    ud.slot_attachs[slot_name] = nil
end

function iprefab_proxy.has_slot_attach(proxy, slot_name)
    w:sync("prefab_proxy:in", proxy)
    local ud = proxy.prefab_proxy.ud
    local slot = ud.slots[slot_name]
    if not slot then
        error(("can not found slot name (%s)"):format(slot_name))
        return
    end

    return (ud.slot_attachs[slot_name] ~= nil)
end
