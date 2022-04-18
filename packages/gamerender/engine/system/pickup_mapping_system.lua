local ecs = ...
local world = ecs.world
local w = world.w

local pickup_mb = world:sub {"pickup"}

local pickup_mapping_sys = ecs.system "pickup_mapping_system"
local ipickup_mapping = ecs.interface "ipickup_mapping"

local id_mapping = {}

function pickup_mapping_sys:entity_remove()
	for eid in w:select "REMOVED scene:in" do
        id_mapping[eid] = nil
	end
end

function pickup_mapping_sys.after_pickup()
    local v
    for _, eid in pickup_mb:unpack() do
        v = id_mapping[eid]
        if v then
            world:pub {"pickup_mapping", v}
        end
    end
end

function ipickup_mapping.mapping(eid, binding)
    id_mapping[eid] = binding
end

function ipickup_mapping.unmapping(eid)
    id_mapping[eid] = nil
end
