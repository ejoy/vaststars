local ecs = ...
local world = ecs.world
local w = world.w

local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local iprefab_object = ecs.interface "iprefab_object"

local function get_component(e, c)
    w:sync(("%s:in"):format(c), e)
    return e[c]
end

local events = {}
events.on_init = function(game_object, prefab)
end

events.on_ready = function(game_object, prefab)
    for _, e in ipairs(prefab.tag["*"]) do
        ipickup_mapping.mapping(get_component(e, "scene").id, game_object)
    end
end

events.on_update = function(game_object, prefab)
end

events.on_message = function(game_object, prefab)
end

function iprefab_object.create(prefab, template)
    if not template then
        return
    end

    for fn, func in pairs(events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(p, ...)
            local game_object = igame_object.get_game_object(p)
            func(game_object, p, ...)
            if ofunc then
                ofunc(game_object, p, ...)
            end
        end
    end

    return igame_object.new(world:create_object(prefab), template)
end
