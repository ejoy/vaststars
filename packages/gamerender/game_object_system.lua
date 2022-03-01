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
    local prefab_slot_cache = {}
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = world:entity(eid)
        if not e then
            log.error(("can nof found entity `%s`"):format(eid))
            goto continue
        end

        if game_object.pause_animation and e._animation then
            iani.pause(e, true)
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
prefab_events.on_update = function(game_object, prefab, pickup_mapping_param)
end

function igame_object.create(prefab, template, pickup_mapping_param)
    for fn, func in pairs(prefab_events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(p, ...)
            local eid = prefab_game_object[p.root]
            if not eid then
                return
            end

            local game_object = world:entity(eid)
            if not game_object then
                log.error(("can nof found game_object `%s`"):format(eid))
                return
            end

            func(game_object, p, pickup_mapping_param , ...)
            if ofunc then
                ofunc(game_object, p, ...)
            end
        end
    end

    local obj = world:create_object(prefab)
    local eid = ecs.create_entity(template)

    for _, id in ipairs(prefab.tag["*"]) do
        ipickup_mapping.mapping(id, eid, pickup_mapping_param)
    end

    prefab_game_object[obj.root] = eid
    game_object_prefab[eid] = obj
    return eid
end

function igame_object.remove(eid)
    world:remove_entity(eid)
    local obj = game_object_prefab[eid]
    if obj then
        -- obj:remove()
        prefab_game_object[obj.root] = nil
    end
    game_object_prefab[eid] = nil
end
