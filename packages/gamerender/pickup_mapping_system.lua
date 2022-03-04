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
    local mapping_eid
    for _, eid in pickup_mb:unpack() do
        mapping_eid = id_mapping[eid]
        if mapping_eid then
            local mapping_entity = world:entity(mapping_eid)
            if not mapping_entity then
                log.error(("can not found entity `%s`"):format(mapping_eid))
                goto continue
            end

            if not mapping_entity.pickup_mapping then
                log.error(("can not found component pickup_mapping `%s`"):format(mapping_eid))
                goto continue
            end

            for param in pairs(mapping_entity.pickup_mapping) do
                world:pub {"pickup_mapping", param, mapping_eid}
            end
            ::continue::
        end
    end
end

-- 调用此接口时, 允许 eid 与 mapping_eid 所对应的 entity 未创建好, 但在 after_pickup stage 里, mapping_eid 对应的 entity 必须创建好
function ipickup_mapping.mapping(eid, mapping_eid)
    id_mapping[eid] = mapping_eid
    id_entity[mapping_eid] = id_entity[mapping_eid] or {}
    id_entity[mapping_eid][eid] = true
    -- print(("ipickup_mapping.mapping %s -> %s"):format(eid, mapping_eid))
end

-- 主动去除映射关系
function ipickup_mapping.unmapping(eid, mapping_eid)
    id_mapping[eid] = nil
    id_entity[mapping_eid][eid] = nil
end
