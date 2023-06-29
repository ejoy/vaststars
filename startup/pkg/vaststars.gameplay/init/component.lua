local def = require "register.component"

local type = def.type
local component = def.component
local tag = function (what)
    component(what) {}
end

type "roadnet::straightid" ("word")
type "enum roadnet::lorry_status" ("byte")

component "building" {
    "x:byte",
    "y:byte",
    "prototype:word",
    "direction:byte",	-- 0:North 1:East 2:South 3:West
}

component "backpack" {
    "item:word",
    "amount:word",
}

component "chest" {
    "chest:word",
}

component "station_producer" {
    "weights:byte",
}

component "station_consumer" {
    "maxlorry:byte",
}

tag "lorry_factory"

component "starting" {
    "neighbor:roadnet::straightid",
}

component "endpoint" {
    "neighbor:roadnet::straightid",
    "rev_neighbor:roadnet::straightid",
    "lorry:byte",
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
    "x:byte",
    "y:byte",
    "z:byte",
}

tag "lorry_free"
tag "lorry_removed"
tag "lorry_willremove"

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

tag "consumer"
tag "generator"
tag "accumulator"

component "fluidbox" {
    "fluid:word",
    "id:word",
}

component "fluidboxes" {
    "in:fluidbox[4]",
    "out:fluidbox[3]",
}

tag "pump"
tag "mining"
tag "road"

component "save_fluidflow" {
	"fluid:word",
	"id:word",
	"volume:dword"
}

component "solar_panel" {
    "efficiency:byte"
}

tag "wind_turbine"
tag "base"
tag "fluidbox_changed"

--
tag "base_changed"
tag "station_changed"
tag "building_new"
tag "building_changed"
tag "auto_set_recipe"
