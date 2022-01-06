local ecs = ...
local world = ecs.world
local w = world.w

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local iprefab_object = ecs.interface "iprefab_object"
local iani = ecs.import.interface "ant.animation|ianimation"

local events = {}
events.on_init = function(game_object, prefab, components)
end

events.on_ready = function(game_object, prefab, components)
    local stop_animation = false
    w:sync("stop_ani_during_init?in", game_object)
    if game_object.stop_ani_during_init then
        stop_animation = true
    end

    for _, e in ipairs(prefab.tag["*"]) do
        w:sync("scene:in", e)
        ipickup_mapping.mapping(e.scene.id, game_object, components)

        w:sync("_animation?in", e)
        if stop_animation and e._animation then
            iani.pause(e, true)
        end
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
