local type = require "register.type"

local generator = type "generator"
	.power "power"
	.priority "priority"
	.capacitance "energy"

function generator:init(object)
	assert(object.power, "power is empty.")
	return {
		capacitance = object.power * 2
	}
end

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

local consumer = type "consumer"
	.power "power"
	.drain "power"
	.priority "priority"
	.capacitance "energy"

function consumer:init(object)
	assert(object.power, "power is empty.")
	if object.drain then
		assert(object.drain <= object.power, "drain must be less than power.")
		return {
			capacitance = object.power * 2
		}
	end
	return {
		drain = object.power // 30,
		capacitance = object.power * 2
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

local accumulator = type "accumulator"
	.power "power"
	.charge_power "power"
	.capacitance "energy"

function accumulator:init(object)
	assert(object.power, "power is empty.")
	assert(object.charge_power, "charge_power is empty.")
	return {
		capacitance = object.power * 2
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
