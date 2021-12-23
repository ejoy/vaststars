require "type.entity"
require "type.chest"
require "type.inserter"
require "type.assembling"
require "type.powergrid"
require "type.pipe"

local type = require "register.type"
type "item"
    .stack "number"

type "fluid"

type "recipe"
    .ingredients "items"
    .results "items"
    .time "time"
