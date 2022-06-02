local type = require "register.type"
local prototype = require "prototype"

local c = type "laboratory"
    .inputs "itemtypes"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function createContainer(world, s)
    local container_in = {}
    for idx = 2, #s//2 do
        local id = string.unpack("<I2", s, 2*idx-1)
        assert(not isFluidId(id))
        container_in[#container_in+1] = string.pack("<I2I2", id, 2)
    end
    return world:container_create("assembling", table.concat(container_in), "")
end

function c:ctor(init, pt)
    local world = self
    local e = {
        laboratory = {
            tech = 0,
            container = createContainer(world, pt.inputs),
            speed = math.floor(pt.speed * 100),
            status = STATUS_IDLE,
            progress = 0,
        }
    }
    return e
end
