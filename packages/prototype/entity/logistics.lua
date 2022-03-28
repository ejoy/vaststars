local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    type ={"entity", "generator", "chest"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
    slots = 20,
}

prototype "车站1" {
    model = "prefabs/goods-station-1.prefab",
    type = {"entity", "chest"},
    area = "1x1",
    slots = 30,
}

prototype "物流中心" {
    model = "prefabs/logistics-center-1.prefab",
    type ={"entity", "consumer"},
    area = "3x3",
    power = "600kW",
    priority = "secondary",
}

prototype "机器爪1" {
    model = "prefabs/inserter-1.prefab",
    type = {"entity", "inserter", "consumer"},
    area = "1x1",
    speed = "1s",
    power = "12kW",
    priority = "secondary",
}

prototype "科技中心1" {
    model = "prefabs/lab-1.prefab",
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}

prototype "砖石公路" {
    model = "prefabs/road/road_O.prefab",
    type ={"entity"},
    area = "1x1",
}