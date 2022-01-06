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
                for e in w:select "drapdrop:in scene:in" do
                    if e.drapdrop == true then
                        world:pub {"drapdrop_entity", e, vx, vy}
                    end
                end
            elseif state == "UP" then
                for e in w:select "drapdrop:in" do
                    if e.drapdrop == true then
                        e.drapdrop = false
                        w:sync("drapdrop:out", e)
                    end
                end
            end
        end
    end
end

function drapdrop_system.after_pickup_mapping()
    for _, _, mapping_entity in pickup_mapping_mb:unpack() do
        w:sync("drapdrop?in", mapping_entity)
        if mapping_entity.drapdrop ~= nil then
            mapping_entity.drapdrop = true
            w:sync("drapdrop:out", mapping_entity)
        end
    end
end
