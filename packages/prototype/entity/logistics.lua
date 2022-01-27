local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "指挥中心" {
    type ={"entity", "generator"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
}

prototype "车站1" {
    type = {"entity", "chest"},
    area = "1x1",
    slots = 30,
}

prototype "物流中心" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "600kW",
    priority = "secondary",
}

prototype "机器爪1" {
    type = {"entity", "inserter", "consumer"},
    area = "1x1",
    speed = "1s",
    power = "12kW",
    priority = "secondary",
}

prototype "科技中心1" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}

prototype "砖石公路" {
    type ={"entity"},
    area = "1x1",
}