local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "空气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-air.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "大气层中的基本气体",
}

prototype "氮气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-nitrogen.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "氧气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-oxygen.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "氢气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-hydrogen.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "乙烯" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-ethene.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工气体",
}

prototype "甲烷" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-ch4.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工气体",
}

prototype "二氧化碳" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-co2.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "一氧化碳" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-co.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工气体",
}

prototype "氯气" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "textures/fluid/gas-chlorine.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "地下卤水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-seawater.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    des = "地壳深处的固态水",
}

prototype "纯水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-water.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    des = "一种纯净的液体",
}

prototype "废水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "textures/fluid/liquid-wastewater.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 20,
    max_temperature = 100,
    des = "一种混合物组成的液体",
}

prototype "盐酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-hydrochloric.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工液体",
}

prototype "碱性溶液" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "textures/fluid/liquid-solution.texture",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工液体",
}

prototype "蒸汽" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "textures/fluid/gas-steam.texture",
    heat_capacity = "0.05KJ",
    default_temperature = 165,
    max_temperature = 200,
    des = "一种化工气体",
}