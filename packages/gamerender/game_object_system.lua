local ecs = ...
local world = ecs.world
local w = world.w

local object_remove_mb  = world:sub {"object_remove"}
local game_object_remove_mb = world:sub {"game_object_system", "remove"}
local game_object_sys = ecs.system "game_object_system"
local igame_object = ecs.interface "igame_object"

local prefab_game_object = {}
local game_object_prefab = {}
local game_object_id = 0

local function get_id()
    game_object_id = game_object_id + 1
    return game_object_id
end

function game_object_sys:entity_ready()
    for _, _, game_object_eid in game_object_remove_mb:unpack() do
        igame_object.get_prefab_object(game_object_id):remove()
    end
end

function game_object_sys:entity_remove()
    local game_object
    for _, prefab_eid in object_remove_mb:unpack() do
        local prefab = world:entity(prefab_eid)
        if prefab then
            if prefab_game_object[prefab.prefab.root] then
                game_object = world:entity(prefab_game_object[prefab.prefab.root])
                if game_object then
                    -- print(("remove game_object `%s`"):format(game_object.game_object_id))
                    game_object_prefab[game_object.game_object_id] = nil
                    world:remove_entity(game_object.id)
                    prefab_game_object[prefab.prefab.root] = nil
                end
            end
        end
    end
end

function igame_object.create(prefab, prefab_object, template)
    template = template or {}
    template.policy = template.policy or {}
    template.policy[#template.policy+1] = "vaststars.gamerender|game_object"
    template.data = template.data or {}
    template.data.scene = {}
    template.data.game_object_id = get_id()
    game_object_prefab[template.data.game_object_id] = {prefab = prefab, prefab_object = prefab_object}

    local eid = ecs.create_entity(template)
    prefab_game_object[prefab_object.root] = eid
    return eid
end

function igame_object.get_prefab(game_object)
    return game_object_prefab[game_object.game_object_id].prefab
end

function igame_object.get_prefab_object(game_object_id)
    return game_object_prefab[game_object_id].prefab_object
end

function igame_object.get_game_object(prefab)
    return prefab_game_object[prefab.root]
end

function igame_object.remove_prefab(game_object_eib)
    world:pub{"game_object_system", "remove", game_object_eib}
end
