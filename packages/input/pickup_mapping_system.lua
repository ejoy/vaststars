local ecs = ...
local world = ecs.world
local w = world.w

local pickup_mb = world:sub {"pickup"}

local pickup_mapping_sys = ecs.system "pickup_mapping_system"
local ipickup_mapping = ecs.interface "ipickup_mapping"

local id_mapping = {}
local id_entity = {}

function pickup_mapping_sys:entity_remove()
	for e in w:select "REMOVED scene:in" do
        local sid = e.scene.id
        -- print(("ipickup_mapping.entity_remove %s"):format(sid))

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
    local params
    for _, entity in pickup_mb:unpack() do
        if entity then
            if id_mapping[entity.scene.id] then
                mapping_entity = id_mapping[entity.scene.id].entity
                params = id_mapping[entity.scene.id].params
                if #params == 0 then
                    world:pub {"pickup_mapping", mapping_entity}
                else
                    for _, v in ipairs(params) do
                        world:pub {"pickup_mapping", v, mapping_entity}
                    end
                end
            end
        end
    end
end

function ipickup_mapping.mapping(sid, entity, params)
    id_mapping[sid] = {entity = entity, params = params or {}}

    if not entity.scene then
        w:sync("scene:in", entity)
    end

    -- print(("ipickup_mapping.mapping %s -> %s"):format(sid, entity.scene.id))
    id_entity[entity.scene.id] = id_entity[entity.scene.id] or {}
    local t = id_entity[entity.scene.id]
    t[#t+1] = sid
end
