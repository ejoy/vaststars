local ecs = ...
local world = ecs.world
local w = world.w

local pickup_gesture_mb = world:sub {"pickup_gesture"}

local pickup_mapping_sys = ecs.system "pickup_mapping_system"
local ipickup_mapping = ecs.interface "ipickup_mapping"

local bindings = {}

function pickup_mapping_sys:entity_remove()
	for eid in w:select "REMOVED scene:in" do
        bindings[eid] = nil
	end
end

function pickup_mapping_sys.after_pickup()
    local binding
    for _, eid, x, y in pickup_gesture_mb:unpack() do
        binding = bindings[eid]
        if binding then
            world:pub {"pickup_mapping", eid, x, y, binding}
        end
    end
end

function ipickup_mapping.mapping(eid, binding)
    bindings[eid] = binding
end

function ipickup_mapping.unmapping(eid)
    bindings[eid] = nil
end
