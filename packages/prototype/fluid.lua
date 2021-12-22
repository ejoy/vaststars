local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "空气" {
    type = {"fluid"},
    heat_capacity = "0.08KJ",
    default_temperature = 50,
    max_temperature = 100,
    des = "大气层中的基本气体",
}

prototype "氮气" {
    type = {"fluid"},
    heat_capacity = "0.08KJ",
    default_temperature = 50,
    max_temperature = 100,
    des = "大气层中的基本气体",
}

prototype "二氧化碳" {
    type = {"fluid"},
    heat_capacity = "0.08KJ",
    default_temperature = 50,
    max_temperature = 100,
    des = "大气层中的基本气体",
}