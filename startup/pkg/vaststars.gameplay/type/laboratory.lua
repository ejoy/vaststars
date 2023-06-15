local type = require "register.type"
local prototype = require "prototype"

local c = type "laboratory"
    .inputs "itemtypes"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    local pt = prototype.queryById(id)
    for _, t in ipairs(pt.type) do
        if t == "fluid" then
            return true
        end
    end
    return false
end

local function createChest(world, s)
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
    return world:container_create(table.concat(container_in))
end

function c:ctor(init, pt)
    local world = self
    local e = {
        chest = {
            chest = createChest(world, pt.inputs)
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
