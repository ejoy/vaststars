local type = require "register.type"
local prototype = require "prototype"
local iendpoint = require "interface.endpoint"

local c = type "laboratory"
    .inputs "itemtypes"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function createChest(world, chest, s)
    local container_in = {}
    for idx = 2, #s//2 do
        local id = string.unpack("<I2", s, 2*idx-1)
        assert(not isFluidId(id))
        container_in[#container_in+1] = world:chest_slot {
            type = "blue",
            item = id,
            limit = 2,
        }
    end
    chest.chest = world:container_create(table.concat(container_in))
end

function c:ctor(init, pt)
    local world = self
    local endpoint = iendpoint.create(world, init, pt, "laboratory")
    local chest = {
        endpoint = endpoint,
        fluidbox_in = 0,
        fluidbox_out = 0,
        lorry = 0xffff,
    }
    createChest(world, chest, pt.inputs)
    local e = {
        chest = chest,
        laboratory = {
            tech = 0,
            speed = math.floor(pt.speed * 100),
            status = STATUS_IDLE,
            progress = 0,
        }
    }
    return e
end
