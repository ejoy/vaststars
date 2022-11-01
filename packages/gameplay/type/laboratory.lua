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

local function createChest(world, s)
    local container_in = {}
    for idx = 2, #s//2 do
        local id = string.unpack("<I2", s, 2*idx-1)
        assert(not isFluidId(id))
        container_in[#container_in+1] = string.pack("<I2I2I2I2I2", 0, id, 0, 2, 0)
    end
    return world:container_create("blue", table.concat(container_in))
end

function c:ctor(init, pt)
    local world = self
    local e = {
        chest = {
            endpoint = 0xffff,
            chest_in = createChest(world, pt.inputs),
            chest_out = 0xffff,
            fluidbox_in = 0,
            fluidbox_out = 0,
        },
        laboratory = {
            tech = 0,
            speed = math.floor(pt.speed * 100),
            status = STATUS_IDLE,
            progress = 0,
        }
    }
    return e
end
