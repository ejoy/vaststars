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

local function is_valid_reference(reference)
    return reference[1] ~= nil
end

function game_object_sys:entity_ready()
    for _, _, game_object in game_object_remove_mb:unpack() do
        igame_object.get_prefab_object(game_object):remove()
    end
end

function game_object_sys:entity_remove()
    local root, game_object
    for _, prefab in object_remove_mb:unpack() do
        if is_valid_reference(prefab) then
            w:sync("prefab:in", prefab)
            root = prefab.prefab.root

            w:sync("scene:in", root)
            game_object = prefab_game_object[root.scene.id]
            if game_object then
                w:sync("game_object_id:in", game_object)
                -- print(("remove game_object `%s`"):format(game_object.game_object_id))
                game_object_prefab[game_object.game_object_id] = nil
                w:remove(game_object)
                prefab_game_object[root.scene.id] = nil
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

    local entity = ecs.create_entity(template)
    prefab_game_object[prefab_object.root.scene.id] = entity
    return entity
end

function igame_object.get_prefab(game_object)
    w:sync("game_object_id:in", game_object)
    return game_object_prefab[game_object.game_object_id].prefab
end

function igame_object.get_prefab_object(game_object)
    w:sync("game_object_id:in", game_object)
    return game_object_prefab[game_object.game_object_id].prefab_object
end

function igame_object.get_game_object(prefab)
    w:sync("scene:in", prefab.root)
    return prefab_game_object[prefab.root.scene.id]
end

function igame_object.remove_prefab(game_object)
    world:pub{"game_object_system", "remove", game_object}
end
