local component = require "register.component"

component "entity" {
    "x:byte",
    "y:byte",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

component "chest" {
    "chest:word",
}

component "assembling" {
    "recipe:word",
    "speed:word",
    "fluidbox_in:word",
    "fluidbox_out:word",
    "chest_in:word",
    "chest_out:word",
    "status:byte",
    "progress:int",
}

component "laboratory" {
    "tech:word",
    "chest:word",
    "speed:word",
    "status:byte",
    "progress:int",
}

component "capacitance" {
    "shortage:dword",
    "delta:int",
    "network:byte"
}

component "burner" {
	"recipe:word",
    "chest_in:word",
    "chest_out:word",
	"progress:word",
}

component "chimney" {
    "recipe:word",
    "speed:word",
    "status:byte",
    "progress:int",
}

component "consumer" {
}

component "generator" {
}

component "accumulator" {
}

component "fluidbox" {
    "fluid:word",
    "id:word",
}

component "fluidboxes" {
    "in:fluidbox[4]",
    "out:fluidbox[3]",
}

component "pump" {
}

component "mining" {
}

component "road" {
}

component "station" {
	"id:word",
	"coord:word",
}

component "save_fluidflow" {
	"fluid:word",
	"id:word",
	"volume:dword"
}

component "solar_panel" {
}

component "base" {
}

component "manual" {
    "recipe:word",
    "speed:word",
    "status:byte",
    "progress:int",
}
