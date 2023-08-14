require "item.blueprint"
require "item.buildings"
require "item.fluid"
require "item.intermediate"
require "item.plumbing"

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "任务" {
    type = {"item"},
    station_limit = 0,
    backpack_limit = 0,
    hub_limit = 0,
    pile = "0x0x0",
    pile_model = "",
    tech_icon = "",
    item_category = "",
    item_icon = "",
}

prototype "山丘" {
    type = {"mountain"},
    icon = "ui/textures/construct/alumina.texture",
    item_description = "地面上的沙丘",
    station_limit = 0,
    item_category = "",
}