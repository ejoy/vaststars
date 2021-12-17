local type = require "register.type"
local container = require "vaststars.container.core"
local prototype = require "prototype"

local burner = type "burner"
	.power "power"
	.capacitance "energy"
	--.fuel_filter "filter"

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
			shortage = pt.capacitance
		},
		generator = true,
	}
end

function consumer:ctor(init, pt)
	return {
		capacitance = {
			shortage = pt.capacitance
		},
		consumer = true,
	}
end

function accumulator:ctor(init, pt)
	return {
		capacitance = {
			shortage = pt.capacitance
		},
		accumulator = true,
	}
end

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

function burner:ctor(init, pt)
    local recipe = assert(prototype.query("recipe", init.recipe))
	local id = container.create(self.cworld, "assembling", recipe.ingredients, recipe.results)
	if init.items then
        for i, item in pairs(init.items) do
            local what = prototype.query("item", item[1])
            container.place(self.cworld, id, what.id, item[2])
        end
    end
	return {
		capacitance = {
			shortage = pt.capacitance
		},
		burner = {
            recipe = recipe.id,
            container = id,
            process = STATUS_IDLE,
		}
	}
end
