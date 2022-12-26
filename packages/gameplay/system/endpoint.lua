local system = require "register.system"
local m = system "endpoint"

function m.build(world)
    local ecs = world.ecs
    for e in ecs:select "endpoint_changed:in station:in entity:in" do
        assert(e.station.endpoint ~= 0xffff)
        local l = world.roadnet:create_lorry()
        world.roadnet:place_lorry(e.station.endpoint, l)
    end
    ecs:clear "endpoint_changed"
end
