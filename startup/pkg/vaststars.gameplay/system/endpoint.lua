local system = require "register.system"
local m = system "endpoint"

function m.build(world)
    local ecs = world.ecs
    for e in ecs:select "endpoint_changed station:update entity:in" do
        if e.station.endpoint ~= 0xffff then
            local l = world.roadnet:create_lorry()
            world.roadnet:place_lorry(e.station.endpoint, l)
            e.station.lorry_count = e.station.lorry_count + 1
        end
    end
    ecs:clear "endpoint_changed"
end
