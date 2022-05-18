require "entity.chemistry"
require "entity.plumbing"
require "entity.logistics"
require "entity.energy"
require "entity.miner"
require "entity.powerpole"
require "entity.chest"
require "entity.assembler"
require "entity.furnace"

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "科研中心I" {
    type = {"entity", "laboratory", "consumer"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
    inputs = {
        "地质科技包",
    },
}
