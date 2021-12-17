require "type.entity"
require "type.chest"
require "type.inserter"
require "type.assembling"
require "type.powergrid"

local type = require "register.type"
type "item"
    .stack "number"

type "fuel"
    .fuel_energy "energy"
    .fuel_category "filter"

type "recipe"
    .ingredients "items"
    .results "items"
    .time "time"
