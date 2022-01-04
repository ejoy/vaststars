local ecs = ...
local world = ecs.world
local w = world.w

local pickup_mb = world:sub {"pickup"}

local pickup_mapping_sys = ecs.system "pickup_mapping_system"
local ipickup_mapping = ecs.interface "ipickup_mapping"

local id_mapping = {}
local id_entity = {}

function pickup_mapping_sys:entity_remove()
	for e in w:select "REMOVED render_object:in scene:in" do
        local sid = e.scene.id
        -- print(("ipickup_mapping.clear %s"):format(sid))

        id_mapping[sid] = nil

        local t = id_entity[sid]
        if t then
            for _, v in ipairs(t) do
                id_mapping[v] = nil
            end
        end
        id_entity[sid] = nil
	end
end

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

    if not entity.scene then
        w:sync("scene:in", entity)
    end

    -- print(("ipickup_mapping.mapping %s -> %s"):format(sid, entity.scene.id))
    id_entity[entity.scene.id] = id_entity[entity.scene.id] or {}
    local t = id_entity[entity.scene.id]
    t[#t+1] = sid
end
