local ecs = ...
local world = ecs.world
local w = world.w

local object_remove_mb  = world:sub {"object_remove"}
local game_object_sys = ecs.system "game_object_system"
local igame_object = ecs.interface "igame_object"
local prefab_to_game_object = {}

function game_object_sys:entity_remove()
    local root, game_object
    for _, prefab in object_remove_mb:unpack() do
        w:sync("prefab:in", prefab)
        root = prefab.prefab.root
        w:sync("scene:in", root)

        game_object = prefab_to_game_object[root.scene.id]
        if game_object then
            w:remove(game_object)
            prefab_to_game_object[root.scene.id] = nil
        end
    end
end

function igame_object.new(prefab, template)
    template.policy = template.policy or {}
    template.policy[#template.policy+1] = "vaststars.gamerender|game_object"

    template.data = template.data or {}
    template.data.prefab_raw = prefab
    template.data.prefab_object = world:create_object(prefab)
    template.data.scene = {}
    template.data.reference = true

    local entity = ecs.create_entity(template)
    prefab_to_game_object[prefab.root.scene.id] = entity
    return entity
end

function igame_object.get_prefab_object(game_object)
    if not game_object.prefab_object then
        w:sync("prefab_object:in", game_object)
    end
    return game_object.prefab_object
end

function igame_object.get_prefab(game_object)
    if not game_object.prefab_raw then
        w:sync("prefab_raw:in", game_object)
    end
    return game_object.prefab_raw
end
