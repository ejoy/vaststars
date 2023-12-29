local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "空气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-air.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 2,
    pollution = 0,
    item_item_descriptioncription = "大气层中的基本气体",
}

prototype "氮气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-nitrogen.texture",
    color = {0, 0, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 4,
    pollution = 0,
    item_description = "一种无色无味的气体,化学式N2",
}

prototype "氧气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-oxygen.texture",
    color = {2.5, 0, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 6,
    pollution = 0,
    item_description = "一种无色无味的气体,化学式O2",
}

prototype "氢气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-hydrogen.texture",
    color = {0.9, 0.9, 0.9, 0.1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 8,
    pollution = 0,
    item_description = "一种无色无味易燃的气体,化学式H2",
}

prototype "乙烯" {
    type = {"fluid"},
    catagory = {"化学气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-ethene.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 10,
    pollution = 25,
    item_description = "一种无色易燃的气体,化学式C2H4",
}

prototype "甲烷" {
    type = {"fluid"},
    catagory = {"化学气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-ch4.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 12,
    pollution = 25,
    item_description = "一种无色无味易燃的气体,化学式CH4",
}

prototype "二氧化碳" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-co2.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 14,
    pollution = 25,
    item_description = "一种无色无味的气体,化学式CO2",
}

prototype "一氧化碳" {
    type = {"fluid"},
    catagory = {"化学气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-co.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 16,
    pollution = 50,
    item_description = "一种无色无味的气体,化学式CO",
}

prototype "氯气" {
    type = {"fluid"},
    catagory = {"化学气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-chlorine.texture",
    color = {0, 2.5, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 18,
    pollution = 150,
    item_description = "一种黄绿色有刺激性气味的气体,化学式CL2",
}

prototype "地下卤水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-groundwater.texture",
    color = {0.3, 0.3, 0.3, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    item_order = 20,
    pollution = 0,
    item_description = "蕴藏在地壳深处的天然盐水",
}

prototype "纯水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-water.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    item_order = 22,
    pollution = 0,
    item_description = "一种无色无味的液体,化学式H2O",
}

prototype "废水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-wastewater.texture",
    color = {0.75, 0.75, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 20,
    max_temperature = 100,
    item_order = 24,
    pollution = 100,
    item_description = "工业生产中使用过的水，包含各种污染物",
}

prototype "盐酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 26,
    pollution = 150,
    item_description = "一种无色有刺激性气味的液体,化学式HCL",
}

prototype "碱性溶液" {
    type = {"fluid"},
    catagory = {"化学液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-solution.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 28,
    pollution = 150,
    item_description = "一种PH值大于7的溶液",
}

prototype "蒸汽" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-steam.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 165,
    max_temperature = 200,
    item_order = 30,
    pollution = 0,
    item_description = "水加热到沸点时产生的气体",
}

prototype "地热气" {
    mineral_name = "地热",
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-steam.texture",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_geothermal_well.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "1KJ",
    default_temperature = 165,
    max_temperature = 200,
    item_order = 32,
    pollution = 100,
    item_description = "因地下深处热量而产生的蒸汽",
    mineral_model = "glbs/mineral/crack.glb|mesh.prefab",
    mineral_area = "3x3",
}

prototype "丁二烯" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-butadiene.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_order = 34,
    pollution = 75,
    item_description = "一种无色有轻微刺激性气味的气体,化学式C4H6",
}

prototype "氦气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-butadiene.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_order = 36,
    pollution = 0,
    item_description = "一种无色无味的气体,化学式He2",
}

prototype "润滑油" {
    type = {"fluid"},
    catagory = {"化学液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-lubricant.texture",
    color = {0.1, 0.8, 0.1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_order = 38,
    pollution = 50,
    item_description = "一种用于减少运动部件之间摩擦和磨损的液体",
}

prototype "氨气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/gas-nitrogen.texture",
    color = {0.1, 0.8, 0.1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 40,
    pollution = 75,
    item_description = "一种无色有刺激性气味的气体,化学式NH3",
}

prototype "硫酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 42,
    pollution = 150,
    item_description = "一种高度腐蚀性和强酸,化学式为H2SO4",
}

prototype "四氯化钛" {
    type = {"fluid"},
    catagory = {"化学液体"},
    item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_order = 44,
    pollution = 150,
    item_description = "一种无色液体,化学式TiCL4",
}

-- prototype "火箭燃料" {
--     type = {"fluid"},
--     catagory = {"化学液体"},
--     item_icon = "/pkg/vaststars.resources/textures/icons/item/liquid-hydrochloric.texture",
--     color = {0.75, 0.75, 0.75, 1},
--     heat_capacity = "0.08kJ",
--     default_temperature = 25,
--     max_temperature = 200,
--     item_order = 46,
--     pollution = 0,
--     item_description = "用于推动火箭和航天器的推进剂",
-- }