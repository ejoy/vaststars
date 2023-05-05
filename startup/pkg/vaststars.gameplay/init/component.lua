local component = require "register.component"

component "building" {
    "x:byte",
    "y:byte",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

component "chest" {
    "chest:word",
    "fluidbox_in:word",
    "fluidbox_out:word",
}

component "inventory" {
    "chest:word",
}

component "station_producer" {
}

component "station_consumer" {
}

component "station" {
    "endpoint:word",
    "chest:word",
    "weights:byte",
    "lorry:byte",
}

component "lorry_factory" {
    "endpoint:word",
}

component "hub" {
    "id:word",
    "chest:word",
}

--
-- prev/next/mov2
-- | unused(5bit) | type(2bit) | chest(4bit) | slot(3bit) | y(9bit) | x(9bit) |
-- 32            27           25            21           18         9         0
--
component "drone" {
    "prev:dword",
    "next:dword",
    "mov2:dword",
    "home:word",
    "classid:word",
    "maxprogress:word",
    "progress:word",
    "item:word",
    "status:byte",
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

component "wind_turbine" {
}

component "base" {
}

component "fluidbox_changed" {}
component "building_changed" {}
component "inventory_changed" {}