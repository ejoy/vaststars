local ecs = ...
local world = ecs.world
local w = world.w

local game_object_sys = ecs.system "game_object_system"
local igame_object = ecs.interface "igame_object"

local prefab_game_object = {}
local game_object_prefab = {}

function game_object_sys:entity_remove()
end

function igame_object.create(prefab, template)
    local obj = world:create_object(prefab)
    local eid = ecs.create_entity(template)

    prefab_game_object[obj.root] = eid
    game_object_prefab[eid] = obj
end

function igame_object.remove(eid)
    world:remove_entity(eid)
    local obj = game_object_prefab[eid]
    if obj then
        obj:remove()
        prefab_game_object[obj.root] = nil
    end
    game_object_prefab[eid] = nil
end
