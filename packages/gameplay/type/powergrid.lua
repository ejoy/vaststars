local component = require "register.component"
local type = require "register.type"

-- store energy
component "capacitance" {
	name = "capacitance",
	type = "float",
}

-- Anything with a bunker is a burner
component "bunker" {
	"type:int",
	"number:float",
}

-- tags
component "consumer" {
}

component "generator" {
}

component "accumulator" {
}

-- convert fuel/heat to charge capacitance
local burner = type "burner"
	.burner_type "burner_type"

-- store solid fuel
type "bunker"
	.capacity "count"
	.fuel_filter "filter"

-- output inner capacitance to powergrid
local generator = type "generator"
	.power "power"
	.efficiency "percentage"
	.priority "priority"

-- consume inner capacitance
local consumer = type "consumer"
	.power "power"
	.drain "drain_power"
	.priority "priority"

local accumulator = type "accumulator"
	.power "power"
	.charge_power "power"
	.battery "energy"

function generator:ctor(init, prototype)
	return {
		capacitance = prototype.power / prototype.efficiency,
		generator = true,
	}
end

-- consumer has 2x capacitance
function consumer:ctor(init, prototype)
	return {
		capacitance = prototype.power * 2,
		consumer = true,
	}
end

function burner:ctor(init)
	if init.fuel then
		local f, n = init.fuel:match "^([%w_]+)%*(%d+)$"
		local fobj = query(f)
		if fobj == nil then
			error ("No fuel : " .. init.fuel)
		end
		return {
			bunker = {
				type = fobj.id,
				number = n + 0,
			}
		}
	else
		return {
			bunker = {
				type = 0,
				number = 0,
			}
		}
	end
end

function accumulator:ctor(init, prototype)
	return {
		capacitance = prototype.battery,
		accumulator = true,
	}
end
