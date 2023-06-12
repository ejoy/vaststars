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
    item_description = "一种纯净气体",
}

prototype "氧气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-oxygen.texture",
    color = {2.5, 0, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种纯净气体",
}

prototype "氢气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-hydrogen.texture",
    color = {0.9, 0.9, 0.9, 0.1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种纯净气体",
}

prototype "乙烯" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-ethene.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种化工气体",
}

prototype "甲烷" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-ch4.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种化工气体",
}

prototype "二氧化碳" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-co2.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种纯净气体",
}

prototype "一氧化碳" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-co.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种化工气体",
}

prototype "氯气" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-chlorine.texture",
    color = {0, 2.5, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种纯净气体",
}

prototype "地下卤水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-groundwater.texture",
    color = {0.3, 0.3, 0.3, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    item_description = "地壳深处的固态水",
}

prototype "纯水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-water.texture",
    color = {2.5, 2.5, 2.5, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    item_description = "一种纯净的液体",
}

prototype "废水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-wastewater.texture",
    color = {0.75, 0.75, 0, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 20,
    max_temperature = 100,
    item_description = "一种混合物组成的液体",
}

prototype "盐酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种化工液体",
}

prototype "碱性溶液" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-solution.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种化工液体",
}

prototype "蒸汽" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-steam.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 165,
    max_temperature = 200,
    item_description = "一种化工气体",
}

prototype "地热气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-steam.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "1KJ",
    default_temperature = 165,
    max_temperature = 200,
    item_description = "一种化工气体",
    mineral_model = "prefabs/mineral/ground-geothermal.prefab",
    mineral_name = "地热",
}

prototype "丁二烯" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-butadiene.texture",
    color = {1, 1, 1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_description = "一种化工气体",
}

prototype "润滑油" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/lubricant.texture",
    color = {0.1, 0.8, 0.1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 200,
    item_description = "一种化工液体",
}

prototype "氨气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/lubricant.texture",
    color = {0.1, 0.8, 0.1, 1},
    heat_capacity = "0.05KJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种化工液体",
}

prototype "硫酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    item_description = "一种化工液体",
}

prototype "火箭燃料" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    color = {0.75, 0.75, 0.75, 1},
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 200,
    item_description = "一种化工液体",
}