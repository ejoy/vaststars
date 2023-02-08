local component = require "register.component"

component "entity" {
    "x:byte",
    "y:byte",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

component "chest" {
    "index:word",
    "asize:word",
    "fluidbox_in:word",
    "fluidbox_out:word",
    "endpoint:word",
}

component "logistic_hub" {
}

component "logistic_chest" {
    "head_index:word",
    "index:word",
}

component "station" {
    "endpoint:word",
    "lorry:word[8]",
    "count:byte",
}

component "park" {
    "endpoint:word",
    "lorry:word[8]",
    "count:byte",
}

component "assembling" {
    "progress:int",
    "recipe:word",
    "speed:word",
    "status:byte",
}

component "laboratory" {
    "progress:int",
    "tech:word",
    "speed:word",
    "status:byte",
}

component "capacitance" {
    "shortage:dword",
    "delta:int",
    "network:byte"
}

component "chimney" {
    "progress:int",
    "recipe:word",
    "speed:word",
    "status:byte",
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

component "fluidbox_changed" {}
