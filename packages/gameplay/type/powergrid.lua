local type = require "register.type"
local prototype = require "prototype"

-- output inner capacitance to powergrid
local generator = type "generator"
	.power "power"
	.priority "priority"
	.capacitance "energy"

-- consume inner capacitance
local consumer = type "consumer"
	.power "power"
	.drain "drain_power"
	.priority "priority"
	.capacitance "energy"

local accumulator = type "accumulator"
	.power "power"
	.charge_power "power"
	.capacitance "energy"

function generator:ctor(init, pt)
	return {
		capacitance = {
			shortage = pt.capacitance,
			delta = 0,
			network = 0,
		},
		generator = true,
	}
end

function consumer:ctor(init, pt)
	return {
		capacitance = {
			shortage = pt.capacitance,
			delta = 0,
			network = 0,
		},
		consumer = true,
	}
end

function accumulator:ctor(init, pt)
	return {
		capacitance = {
			shortage = pt.capacitance,
			delta = 0,
			network = 0,
		},
		accumulator = true,
	}
end

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function createChest(world, type, s)
    local chest = {}
    for idx = 2, #s//4 do
        local id, n = string.unpack("<I2I2", s, 4*idx-3)
        chest[#chest+1] = world:chest_slot {
            type = type,
            item = id,
            limit = n * 2,
        }
    end
    return table.concat(chest)
end
