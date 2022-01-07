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
events.on_init = function(game_object, prefab, components)
end

events.on_ready = function(game_object, prefab, components)
    local stop_animation = false
    w:sync("stop_ani_during_init?in", game_object)
    if game_object.stop_ani_during_init then
        stop_animation = true
    end

    local prefab_slot_cache = {}
    for _, e in ipairs(prefab.tag["*"]) do
        w:sync("scene:in", e)
        ipickup_mapping.mapping(e.scene.id, game_object, components)

        if stop_animation then
            w:sync("_animation?in", e)
            if e._animation then
                iani.pause(e, true)
            end
        end

        w:sync("slot?in name:in", e)
        if e.slot then
            prefab_slot_cache[e.name] = e
        end
    end

    if next(prefab_slot_cache) then
        game_object.prefab_slot_cache = prefab_slot_cache
        w:sync("prefab_slot_cache:out", game_object)
    end
end

events.on_update = function(game_object, prefab, components)
end

events.on_message = function(game_object, prefab, components)
end

function iprefab_object.create(prefab, template)
    if not template then
        return
    end

    local components = {}
    for k, v in pairs(template.data or {}) do
        components[#components+1] = k
    end

    for fn, func in pairs(events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(p, ...)
            local game_object = igame_object.get_game_object(p)
            func(game_object, p, components , ...)
            if ofunc then
                ofunc(game_object, p, ...)
            end
        end
    end

    return igame_object.create(world:create_object(prefab), template)
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
