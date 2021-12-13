local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ipickup_mapping = ecs.import.interface "vaststars|ipickup_mapping"

local prefab_proxy_remove_mb = world:sub {"prefab_proxy", "remove"}
local iprefab_proxy = ecs.interface "iprefab_proxy"
local prefab_proxy_sys = ecs.system "prefab_proxy_system"

local ud_refs = {}

local function __remove_proxy(ud)
    local proxy = ud.proxy
    if not proxy.prefab then
        w:sync("prefab_proxy:in", proxy)
    end

    proxy.prefab_proxy.prefab:send("__remove")
end

function prefab_proxy_sys:component_init()
    for _, _, ud in prefab_proxy_remove_mb:unpack() do
        for slot_name, e in pairs(ud.slot_attachs) do
            world:call(e, "set_parent", nil)
        end
        __remove_proxy(ud)
    end
end

local gen_ud_ref_id ; do
    local id = 0
    function gen_ud_ref_id()
        id = id + 1
        return id
    end
end

local function __on_prefab_ready(ud_ref_id, prefab)
    local ud = ud_refs[ud_ref_id]
    if not ud then
        error(("can not found proxy id (%d)"):format(ud_ref_id))
    end

    local on_pickup_mapping = ud.events.on_pickup_mapping
    for _, e in ipairs(prefab.tag["*"]) do
        w:sync("scene:in slot?in name:in", e)

        if not on_pickup_mapping then
            ipickup_mapping.mapping(e.scene.id, ud.proxy)
        else
            on_pickup_mapping(e.scene.id)
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
    funcs["remove"] = function(ud)
        if next(ud.slot_attachs) then
            world:pub {"prefab_proxy", "remove", ud}
            return
        end

        __remove_proxy(ud)
    end

    funcs["__remove"] = function(ud, prefab)
        for _, e in ipairs(prefab.tag["*"]) do
            w:sync("scene:in", e)
            ipickup_mapping.unmapping(e.scene.id)
        end
        prefab:remove()

        ud_refs[ud.ud_ref_id] = nil
        w:remove(ud.proxy)
    end

    funcs["slot_attach"] = function(ud, prefab, slot_name, entity)
        local slot = ud.slots[slot_name]
        if not slot then
            -- todo
            return
            -- error(("can not found slot name (%s)"):format(slot_name))
        end

        world:call(entity, "set_parent", slot)
        ud.slot_attachs[slot_name] = entity
    end

    funcs["slot_detach"] = function(ud, _, slot_name)
        ud.slot_attachs[slot_name] = nil
    end

    function __on_prefab_message(ud_ref_id, prefab, cmd, ...)
        local ud = ud_refs[ud_ref_id]
        if not ud then
            error(("can not found proxy id (%d)"):format(ud_ref_id))
        end

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
function iprefab_proxy.create(prefab, v, events)
    local id = gen_ud_ref_id()
    prefab.on_ready = function(prefab)
        __on_prefab_ready(id, prefab)
    end
    prefab.on_message = function(prefab, ...)
        __on_prefab_message(id, prefab, ...)
    end
    local obj = world:create_object(prefab)

    --
    v = v or {policy = {}, data = {}}
    v.policy = v.policy or {}
    v.data = v.data or {}

    v.policy[#v.policy+1] = "vaststars|prefab_proxy"
    v.data.prefab_proxy = {prefab = obj, root = prefab.root}
    v.policy[#v.policy+1] = "ant.scene|scene_object"
    v.data.scene = v.data.scene or {}
    v.data.reference = true

    local srt = v.data.scene.srt
    if srt then
        iom.set_srt(prefab.root, srt.s, srt.r, srt.t)
    end

    local proxy = ecs.create_entity(v)
    ud_refs[id] = {ud_ref_id = id, proxy = proxy, slots = {}, slot_attachs = {}, events = events or {}}
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