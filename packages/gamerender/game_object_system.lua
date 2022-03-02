local ecs = ...
local world = ecs.world
local w = world.w

local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"
local iani = ecs.import.interface "ant.animation|ianimation"
local igame_object = ecs.interface "igame_object"

local prefab_game_object = {}
local game_object_prefab = {}

local prefab_events = {}
prefab_events.on_ready = function(game_object, prefab)
    local prefab_slot_id_cache = {}
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = world:entity(eid)
        if not e then
            log.error(("can nof found game_object `%s`"):format(eid))
            goto continue
        end
        if game_object.pause_animation and e._animation then
            iani.pause(e, true)
        end

        if e.slot then
            prefab_slot_id_cache[e.name] = eid
        end
        ::continue::
    end

    if next(prefab_slot_id_cache) then
        game_object.prefab_slot_id_cache = prefab_slot_id_cache
    end
end
prefab_events.on_update = function(game_object, prefab, pickup_mapping_param)
end
prefab_events.on_message = function(game_object, prefab, pickup_mapping_param)
end
prefab_events.on_init = function(game_object, prefab, pickup_mapping_param)
end

function igame_object.create(prefab, template, pickup_mapping_param)
    for fn, func in pairs(prefab_events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(p, ...)
            local eid = prefab_game_object[p.root]
            if not eid then
                log.error(("can nof found game_object `%s`"):format(eid))
                return
            end

            local game_object = world:entity(eid)
            if not game_object then
                log.error(("can nof found game_object entity `%s`"):format(eid))
                return
            end

            func(game_object, p, pickup_mapping_param, ...)
            if ofunc then
                ofunc(game_object, p, ...)
            end
        end
    end

    local game_object_eid = ecs.create_entity(template)
    local obj = world:create_object(prefab)

    for _, eid in ipairs(prefab.tag["*"]) do
        ipickup_mapping.mapping(eid, game_object_eid, pickup_mapping_param)
    end

    prefab_game_object[obj.root] = game_object_eid
    game_object_prefab[game_object_eid] = obj
end

function igame_object.remove(game_object_eid)
    world:remove_entity(game_object_eid)
    local prefab = game_object_prefab[game_object_eid]
    if prefab then
        prefab:remove()
        prefab_game_object[prefab.root] = nil
        game_object_prefab[game_object_eid] = nil
    end
end

function igame_object.get_prefab_object(game_object_eid)
    return game_object_prefab[game_object_eid]
end
