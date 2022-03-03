local ecs = ...
local world = ecs.world
local w = world.w

local pickup_mapping_mb = world:sub {"pickup_mapping", "drapdrop"}
local mouse_mb = world:sub {"mouse"}

local drapdrop_system = ecs.system "drapdrop_system"

function drapdrop_system:data_changed()
    for _, _, state, vx, vy in mouse_mb:unpack() do
        if vx and vy then
            if state == "MOVE" then
                for e in w:select "drapdrop_selected:in scene:in id:in" do
                    world:pub {"drapdrop_entity", e.id, vx, vy}
                end
            elseif state == "UP" then
                for e in w:select "drapdrop_selected:in" do
                    e.drapdrop_selected = false
                    w:sync("drapdrop_selected:out", e)
                end
            end
        end
    end
end

function drapdrop_system.after_pickup_mapping()
    for _, _, mapping_entity_eid in pickup_mapping_mb:unpack() do
        local mapping_entity = world:entity(mapping_entity_eid)
        if mapping_entity.drapdrop then
            mapping_entity.drapdrop_selected = true
        end
    end
end
