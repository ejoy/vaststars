local ichest = require "gameplay.interface.chest"
local ltask = require "ltask"
local ltask_now = ltask.now
local last_update_time

local function _gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local function update(world)
    local current = _gettime()
    last_update_time = last_update_time or current
    if current - last_update_time < 300 then
        return
    end
    last_update_time = current

    for e in world.ecs:select "station:in chest:in entity:in" do
        for _, slot in pairs(ichest.collect_item(world, e)) do
            if slot.amount >= 0 then
                assert(ichest.chest_pickup(world, e.chest, slot.item, slot.amount))

                if e.station.endpoint ~= 0xffff then
                    for _ = 1, slot.amount do
                        local l = world:roadnet_create_lorry()
                        world:roadnet_place_lorry(e.station.endpoint, l)
                        print("place lorry")
                    end
                end
            end
        end
    end
end
return update