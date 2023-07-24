local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "空气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-air.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_item_descriptioncription = "大气层中的基本气体",
}

prototype "氮气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-nitrogen.texture",
    color = {0, 0, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色无味的气体,化学式N2",
}

prototype "氧气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-oxygen.texture",
    color = {2.5, 0, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色无味的气体,化学式O2",
}

prototype "氢气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-hydrogen.texture",
    color = {0.9, 0.9, 0.9, 0.1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色无味易燃的气体,化学式H2",
}

prototype "乙烯" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-ethene.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色易燃的气体,化学式C2H4",
}

prototype "甲烷" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-ch4.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色无味易燃的气体,化学式CH4",
}

prototype "二氧化碳" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-co2.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色无味的气体,化学式CO2",
}

prototype "一氧化碳" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-co.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色无味的气体,化学式CO",
}

prototype "氯气" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-chlorine.texture",
    color = {0, 2.5, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种黄绿色有刺激性气味的气体,化学式CL2",
}

prototype "地下卤水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-groundwater.texture",
    color = {0.3, 0.3, 0.3, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    item_description = "蕴藏在地壳深处的天然盐水",
}

prototype "纯水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-water.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    item_description = "一种无色无味的液体,化学式H2O",
}

prototype "废水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-wastewater.texture",
    color = {0.75, 0.75, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 20,
    max_temperature = 100,
    item_description = "工业生产中使用过的水，包含各种污染物",
}

prototype "盐酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色有刺激性气味的液体,化学式HCL",
}

prototype "碱性溶液" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-solution.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种PH值大于7的溶液",
}

prototype "蒸汽" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-steam.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 165,
    max_temperature = 200,
    item_description = "水加热到沸点时产生的气体",
}

prototype "地热气" {
    display_name = "地热",
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-steam.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "1KJ",
    default_temperature = 165,
    max_temperature = 200,
    item_description = "因地下深处热量而产生的蒸汽",
    mineral_model = "prefabs/mineral/ground-geothermal.prefab",
    mineral_area = "3x3",
}

prototype "丁二烯" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-butadiene.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_description = "一种无色有轻微刺激性气味的气体,化学式C4H6",
}

prototype "氦气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-butadiene.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_description = "一种无色无味的气体,化学式He2",
}

prototype "润滑油" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/lubricant.texture",
    color = {0.1, 0.8, 0.1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_description = "一种用于减少运动部件之间摩擦和磨损的液体",
}

prototype "氨气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/lubricant.texture",
    color = {0.1, 0.8, 0.1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色有刺激性气味的气体,化学式NH3",
}

prototype "硫酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种高度腐蚀性和强酸,化学式为H2SO4",
}

prototype "四氯化钛" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种无色液体,化学式TiCL4",
}

prototype "火箭燃料" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 200,
    item_description = "用于推动火箭和航天器的推进剂",
}