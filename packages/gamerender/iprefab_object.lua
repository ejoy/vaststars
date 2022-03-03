local ecs = ...
local world = ecs.world
local w = world.w

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local prefab_object_system = ecs.system "prefab_object_system"
local iprefab_object = ecs.interface "iprefab_object"
local iani = ecs.import.interface "ant.animation|ianimation"

function prefab_object_system:component_init()

end

local events = {}

events.on_ready = function(game_object, prefab, components)

    local prefab_slot_cache = {}
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = world:entity(eid)
        if not e then
            log.error(("can not found entity `%s`"):format(eid))
            goto continue
        end

        ipickup_mapping.mapping(eid, game_object.id, components)

        if game_object.pause_animation and e._animation then
            iani.pause(eid, true)
        end

        if e.slot then
            prefab_slot_cache[e.name] = e
        end
        ::continue::
    end

    if next(prefab_slot_cache) then
        game_object.prefab_slot_cache = prefab_slot_cache
    end
end

events.on_update = function(game_object, prefab, components)
end

events.on_message = function(game_object, prefab, components)
end

events.on_init = function(game_object, prefab, components)
end

function iprefab_object.create(prefab, template)
    if not template then
        return
    end

    local components = {}
    for k in pairs(template.data or {}) do
        components[#components+1] = k
    end

    for fn, func in pairs(events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(p, ...)
            local game_object_eid = igame_object.get_game_object(p)
            local game_object
            if game_object_eid then
                game_object = world:entity(game_object_eid)
            end
            if not game_object then
                log.error(("can not found entity `%s`"):format(game_object_eid))
                return
            end
            func(game_object, p, components , ...)
            if ofunc then
                ofunc(game_object, p, ...)
            end
        end
    end

    return igame_object.create(prefab, world:create_object(prefab), template)
end

function iprefab_object.slot_attach(game_object, slot_name, prefab)
    w:sync("prefab_slot_cache:in", game_object)
    local slot = game_object.prefab_slot_cache[slot_name]
    if not slot then
        print(("can not found slot `%s`"):format(slot_name))
        return
    end

    w:sync("prefab_slot_attach:in", game_object)
    if game_object.prefab_slot_attach[slot_name] then
        print(("already attach slot name `%s`"):format(slot_name))
        return
    end

    world:call(prefab.root, "set_parent", slot)
    game_object.prefab_slot_attach[slot_name] = prefab
    w:sync("prefab_slot_attach:out", game_object)
end

function iprefab_object.slot_detach(game_object, slot_name)
    w:sync("prefab_slot_cache:in", game_object)
    local slot = game_object.prefab_slot_cache[slot_name]
    if not slot then
        print(("can not found slot `%s`"):format(slot_name))
        return
    end

    w:sync("prefab_slot_attach:in", game_object)
    local prefab = game_object.prefab_slot_attach[slot_name]
    if not prefab then
        print(("no attach slot name `%s`"):format(slot_name))
        return
    end

    world:call(prefab.root, "set_parent", nil)
    prefab:send("remove")
    game_object.prefab_slot_attach[slot_name] = nil
    w:sync("prefab_slot_attach:out", game_object)
end

function iprefab_object.has_tag(e, tag)
    w:sync("tag?in", e)
    if not e.tag then
        return false
    end

    for _, t in ipairs(e.tag) do
        if t == tag then
            return true
        end
    end
    return false
end
