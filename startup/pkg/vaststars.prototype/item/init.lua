require "item.blueprint"
require "item.buildings"
require "item.fluid"
require "item.intermediate"
require "item.plumbing"

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "任务" {
    type = {"item"},
    stack = 10,
    tech_icon = "",
    group = {},
    icon = "",
}

prototype "山丘" {
    type = {"mountain"},
    icon = "textures/construct/alumina.texture",
    item_description = "地面上的沙丘",
    stack = 0,
    group = {},
}