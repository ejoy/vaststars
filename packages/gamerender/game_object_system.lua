local ecs = ...
local world = ecs.world
local w = world.w

local object_remove_mb  = world:sub {"object_remove"}
local game_object_sys = ecs.system "game_object_system"
local igame_object = ecs.interface "igame_object"

local prefab_game_object = {}
local game_object_prefab = {}

function game_object_sys:entity_remove()
    local root, game_object
    for _, prefab in object_remove_mb:unpack() do
        w:sync("prefab:in", prefab)
        root = prefab.prefab.root

        w:sync("scene:in", root)
        game_object = prefab_game_object[root.scene.id]
        if game_object then
            w:sync("scene:in", game_object)
            -- print(("remove game_object `%s`"):format(game_object.scene.id))
            game_object_prefab[game_object.scene.id] = nil
            w:remove(game_object)
            prefab_game_object[root.scene.id] = nil
        end
    end
end

function game_object_sys:entity_ready()
end

function igame_object.new(prefab, template)
    template = template or {}
    template.policy = template.policy or {}
    template.policy[#template.policy+1] = "vaststars.gamerender|game_object"

    template.data = template.data or {}
    template.data.scene = {}
    template.data.reference = true
    template.data.game_object = true
    template.data.on_ready = function(game_object)
        w:sync("scene:in", game_object)
        -- print(("add game_object `%s` `%s` `%s`"):format(game_object.scene.id, game_object[1], game_object[2]))
        -- assert(game_object_prefab[game_object.scene.id] == nil)
        game_object_prefab[game_object.scene.id] = prefab
    end

    local entity = ecs.create_entity(template)
    prefab_game_object[prefab.root.scene.id] = entity
    return entity
end

function igame_object.get_prefab_object(game_object)
    w:sync("scene:in", game_object)
    return game_object_prefab[game_object.scene.id]
end

function igame_object.get_game_object(prefab)
    w:sync("scene:in", prefab.root)
    return prefab_game_object[prefab.root.scene.id]
end
