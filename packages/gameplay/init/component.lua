local component = require "register.component"

component "entity" {
    "x:byte",
    "y:byte",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

component "chest" {
    "container:word",
}

component "assembling" {
    "recipe:word",
    "container:word",
    "process:word",
}

component "inserter" {
    "input_container:word",
    "output_container:word",
    "hold_item:word",
    "hold_amount:word",
    "process:word",
}

component "capacitance" {
	"shortage:float"
}

component "burner" {
	"recipe:word",
	"container:word",
	"process:word",
}

component "consumer" {
}

component "generator" {
}

component "accumulator" {
}
