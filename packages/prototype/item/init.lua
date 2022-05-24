require "item.broken"
require "item.buildings"
require "item.fluid"
require "item.intermediate"
require "item.plumbing"

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "任务" {
    type = {"item"},
    stack = 10,
}
