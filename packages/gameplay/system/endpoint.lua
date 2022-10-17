local system = require "register.system"
local m = system "endpoint"

function m.build(world)
    local ecs = world.ecs
    for v in ecs:select "endpoint_changed:in entity:in chest_2?update station?update " do
        local endpoint = world.roadnet:create_endpoint(v.entity.x | v.entity.y << 16 | 0 << 32) -- TODO Z --> direction
        if v.chest_2 then
            v.chest_2.endpoint = endpoint
        elseif v.station then
            v.station.endpoint = endpoint
        else
            assert(false)
        end
    end
    ecs:clear "endpoint_changed"
end
