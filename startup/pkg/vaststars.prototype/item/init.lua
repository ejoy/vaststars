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
    item_model = "",
    tech_icon = "",
    item_category = "",
    item_icon = "",
}

prototype "山丘" {
    type = {"mountain"},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_mountain.texture",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/mountain.texture",
    item_description = "星球表面的小山",
    station_limit = 0,
    item_category = "",
}