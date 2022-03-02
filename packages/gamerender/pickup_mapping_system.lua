local ecs = ...
local world = ecs.world
local w = world.w

local pickup_mb = world:sub {"pickup"}

local pickup_mapping_sys = ecs.system "pickup_mapping_system"
local ipickup_mapping = ecs.interface "ipickup_mapping"

local id_mapping = {}
local id_entity = {}

function pickup_mapping_sys:entity_remove()
	for eid in w:select "REMOVED scene:in" do
        -- print(("ipickup_mapping.entity_remove %s"):format(eid))

        id_mapping[eid] = nil

        local t = id_entity[eid]
        if t then
            id_entity[eid] = nil
            for id in pairs(t) do
                id_mapping[id] = nil
            end
        end
	end
end

function pickup_mapping_sys.after_pickup()
    local m
    local mapping_eid
    local params
    for _, eid in pickup_mb:unpack() do
        m = id_mapping[eid]
        if m then
            mapping_eid = m.eid
            params = m.params
            if #params == 0 then
                world:pub {"pickup_mapping", mapping_eid}
            else
                for _, v in ipairs(params) do
                    world:pub {"pickup_mapping", v, mapping_eid}
                end
            end
        end
    end
end

function ipickup_mapping.mapping(eid, mapping_eid, params)
    id_mapping[eid] = {eid = mapping_eid, params = params or {}}
    id_entity[mapping_eid] = id_entity[mapping_eid] or {}
    id_entity[mapping_eid][eid] = true
    -- print(("ipickup_mapping.mapping %s -> %s"):format(eid, mapping_eid))
end
