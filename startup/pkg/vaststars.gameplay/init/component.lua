local def = require "register.component"

local component = def.component
local type = def.type

component "building" {
    "x:byte",
    "y:byte",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

component "chest" {
    "chest:word",
}

component "station_producer" {
    "chest:word",
    "weights:byte",
    "lorry:byte",
}

component "station_consumer" {
    "chest:word",
    "maxlorry:byte",
    "lorry:byte",
}

component "lorry_factory" {}

type "roadnet::straightid" ("word")
type "enum roadnet::lorry_status" ("byte")

component "endpoint" {
    "neighbor:roadnet::straightid",
    "rev_neighbor:roadnet::straightid",
}

component "lorry" {
    "ending:roadnet::straightid",
    "classid:word",
    "item_classid:word",
    "item_amount:word",
    "progress:byte",
    "maxprogress:byte",
    "time:byte",
    "status:enum roadnet::lorry_status",
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
    "fluidbox_in:word",
    "fluidbox_out:word",
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
    "x:byte",
    "y:byte",
    "mask:byte",
    "classid:word",
}

component "save_fluidflow" {
	"fluid:word",
	"id:word",
	"volume:dword"
}

component "solar_panel" {
    "efficiency:byte"
}

component "wind_turbine" {
}

component "base" {
    "chest:word",
}
component "base_changed" {}

component "fluidbox_changed" {}

--
component "station_changed" {}
component "endpoint_road" {}
component "building_new" {}
component "building_changed" {}
component "road_changed" {}
component "auto_set_recipe" {}
