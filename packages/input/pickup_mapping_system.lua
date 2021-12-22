local ecs = ...
local world = ecs.world
local w = world.w

local pickup_mb = world:sub {"pickup"}

local pickup_mapping_sys = ecs.system "pickup_mapping_system"
local ipickup_mapping = ecs.interface "ipickup_mapping"

local id_mapping = {}

function pickup_mapping_sys.after_pickup()
    local mapping_entity
    for _, entity in pickup_mb:unpack() do
        if entity then
            mapping_entity = id_mapping[entity.scene.id]
            if mapping_entity then
                if not mapping_entity.pickup_mapping_tag then
                    w:sync("pickup_mapping_tag?in", mapping_entity)
                end

                world:pub {"pickup_mapping", mapping_entity.pickup_mapping_tag, mapping_entity}
            end
        end
    end
end

function ipickup_mapping.mapping(sid, entity)
    id_mapping[sid] = entity
end

function ipickup_mapping.unmapping(sid)
    id_mapping[sid] = nil
end
