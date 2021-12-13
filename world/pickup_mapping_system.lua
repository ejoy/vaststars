local ecs = ...
local world = ecs.world
local w = world.w

local pickup_mb = world:sub {"pickup"}

local pickup_mapping_sys = ecs.system "pickup_mapping_system"
local ipickup_mapping = ecs.interface "ipickup_mapping"

local id_mapping = {}
local entity_mapping = {}

function pickup_mapping_sys.after_pickup()
    local sid, msid
    for _, entity in pickup_mb:unpack() do
        if entity then
            sid = entity.scene.id
            msid = id_mapping[entity.scene.id]
            if msid then
                world:pub {"pickup_mapping", sid, msid}
            end
        end
    end
end

function ipickup_mapping.mapping(sid, entity)
    if not entity.scene then
        w:sync("scene:in", entity)
    end
    local msid = entity.scene.id
    id_mapping[sid] = msid
    entity_mapping[msid] = entity
end

function ipickup_mapping.unmapping(sid)
    local msid = id_mapping[sid]
    -- entity_mapping[msid] = nil -- todo the mapping entity may be the same one, so can not set nil here
end

function ipickup_mapping.get_entity(sid)
    local e = entity_mapping[sid]
    if not e then
        return
    end

    if not e[1] then -- todo bad taste
        entity_mapping[sid] = nil
        return
    end

    return e
end
