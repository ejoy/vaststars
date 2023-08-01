require "item.blueprint"
require "item.buildings"
require "item.fluid"
require "item.intermediate"
require "item.plumbing"

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "任务" {
    type = {"item"},
    stack = 0,
    backpack_stack = 0,
    tech_icon = "",
    item_category = "",
    icon = "",
}

prototype "山丘" {
    type = {"mountain"},
    icon = "ui/textures/construct/alumina.texture",
    item_description = "地面上的沙丘",
    stack = 0,
    item_category = "",
}