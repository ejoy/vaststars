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
