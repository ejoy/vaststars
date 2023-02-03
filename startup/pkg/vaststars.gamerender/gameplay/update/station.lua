local ichest = require "gameplay.interface.chest"
local ltask = require "ltask"
local ltask_now = ltask.now
local last_update_time
local LORRY_CAPACITY <const> = 10
local INVALID_LORRY_ID <const> = 0xffff

local function _gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local function __place_lorry(world, e)
    for i = 1, LORRY_CAPACITY do
        if e.station["lorry" .. i] == INVALID_LORRY_ID then
            local l = world:roadnet_create_lorry()
            e.station["lorry" .. i] = l
            return true
        end
    end
    return false
end

local function update(world)
    local current = _gettime()
    last_update_time = last_update_time or current
    if current - last_update_time < 300 then
        return
    end
    last_update_time = current

    -- TODO: remove this
    for e in world.ecs:select "station:in chest:in entity:in" do
        if e.station.endpoint ~= 0xffff then
            for _, slot in pairs(ichest.collect_item(world, e)) do
                if slot.amount >= 0 then
                    local i
                    for i = 1, slot.amount do
                        if not __place_lorry(world, e) then
                            break
                        end
                    end
                    local amount = slot.amount - i - 1
                    assert(ichest.chest_pickup(world, e.chest, slot.item, amount))
                end
            end
        end
    end
end
return update