local ecs = ...
local world = ecs.world
local w = world.w

local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"
local iani = ecs.import.interface "ant.animation|ianimation"
local igame_object = ecs.interface "igame_object"
local game_object_sys = ecs.system "game_object_system"
local game_object_remove_mb = world:sub {"game_object_system", "remove"}

function game_object_sys:update_world()
    for _, _, game_object_eid in game_object_remove_mb:unpack() do
        world:remove_entity(game_object_eid)
    end
end

local game_object_prefab = {}

local prefab_events = {}
prefab_events.on_ready = function(game_object, prefab)
    local prefab_slot_eid_cache = {}
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
            prefab_slot_eid_cache[e.name] = eid
        end
        ::continue::
    end

    if next(prefab_slot_eid_cache) then
        game_object.prefab_slot_eid_cache = prefab_slot_eid_cache
    end
end
prefab_events.on_update = function(game_object, prefab)
end
prefab_events.on_message = function(game_object, prefab)
end
prefab_events.on_init = function(game_object, prefab)
end

function igame_object.create(prefab, template)
    assert(template.data.pickup_mapping)
    local game_object_eid = ecs.create_entity(template)
    for fn, func in pairs(prefab_events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(p, ...)
            local game_object = world:entity(game_object_eid)
            if not game_object then
                log.error(("can nof found game_object `%s`"):format(game_object_eid))
                return
            end

            func(game_object, p, ...)
            if ofunc then
                ofunc(game_object, p, ...)
            end
        end
    end

    local obj = world:create_object(prefab)
    for _, eid in ipairs(prefab.tag["*"]) do
        ipickup_mapping.mapping(eid, game_object_eid)
    end

    game_object_prefab[game_object_eid] = obj
end

function igame_object.remove(game_object_eid)
    local prefab = game_object_prefab[game_object_eid]
    if prefab then
        game_object_prefab[game_object_eid] = nil
        prefab:remove()
    end
    -- remove game_object entity must ensure that after prefab is deleted, in `update_world` stage
    world:pub {"game_object_system", "remove", game_object_eid}
end

function igame_object.get_prefab_object(game_object_eid)
    return game_object_prefab[game_object_eid]
end
