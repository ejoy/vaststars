local ecs = ...
local world = ecs.world
local w = world.w

local ipickup_mapping = ecs.import.interface "vaststars|ipickup_mapping"
local pickup_mapping_mb = world:sub {"pickup_mapping"}
local mouse_drag_mb = world:sub {"mousedrag"}

local drapdrop_system = ecs.system 'drapdrop_system'

local entity -- todo is there a better way to find the "drapdrop" entity?
function drapdrop_system.data_changed()
    local mapping_entity
    for _, _, msid in pickup_mapping_mb:unpack() do
        mapping_entity = ipickup_mapping.get_entity(msid)
        if mapping_entity then
            w:sync("drapdrop?in", mapping_entity)
            if mapping_entity.drapdrop then
                entity = mapping_entity
            end
        end
    end

    for _, what, mouse_x, mouse_y in mouse_drag_mb:unpack() do
        if what ~= "LEFT" or not entity then
            goto continue
        end

        world:pub {"drapdrop_entity", entity.scene.id, mouse_x, mouse_y}
       ::continue::
    end
end