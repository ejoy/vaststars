local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "空气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "fluid/gas-air.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "大气层中的基本气体",
}

prototype "氮气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "fluid/gas-nitrogen.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "氧气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "fluid/gas-oxygen.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "氢气" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "fluid/gas-hydrogen.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "乙烯" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "fluid/gas-ethene.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工气体",
}

prototype "甲烷" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "fluid/gas-ch4.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工气体",
}

prototype "二氧化碳" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "fluid/gas-co2.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "一氧化碳" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "fluid/gas-co.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工气体",
}

prototype "氯气" {
    type = {"fluid"},
    catagory = {"化学气体"},
    icon = "fluid/gas-chlorine.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种纯净气体",
}

prototype "海水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "fluid/liquid-seawater.png",
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    des = "海洋中的液体",
}

prototype "纯水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "fluid/liquid-water.png",
    heat_capacity = "0.08kJ",
    default_temperature = 15,
    max_temperature = 100,
    des = "一种纯净的液体",
}

prototype "废水" {
    type = {"fluid"},
    catagory = {"普通液体"},
    icon = "fluid/liquid-wastewater.png",
    heat_capacity = "0.08kJ",
    default_temperature = 20,
    max_temperature = 100,
    des = "一种混合物组成的液体",
}

prototype "盐酸" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "fluid/liquid-hydrochloric.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工液体",
}

prototype "碱性溶液" {
    type = {"fluid"},
    catagory = {"化学液体"},
    icon = "fluid/liquid-solution.png",
    heat_capacity = "0.08kJ",
    default_temperature = 25,
    max_temperature = 100,
    des = "一种化工液体",
}

prototype "蒸汽" {
    type = {"fluid"},
    catagory = {"普通气体"},
    icon = "fluid/gas-steam.png",
    heat_capacity = "0.05KJ",
    default_temperature = 165,
    max_temperature = 200,
    des = "一种化工气体",
}