local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    construct_detector = {"exclusive"},
    type ={"entity", "generator", "chest"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
    slots = 20,
}

prototype "车站1" {
    model = "prefabs/goods-station-1.prefab",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    area = "1x1",
    slots = 30,
}

prototype "物流中心" {
    model = "prefabs/logistics-center-1.prefab",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer"},
    area = "3x3",
    power = "600kW",
    priority = "secondary",
}

prototype "机器爪1" {
    model = "prefabs/inserter-1.prefab",
    construct_detector = {"exclusive"},
    type = {"entity", "inserter", "consumer"},
    area = "1x1",
    speed = "1s",
    power = "12kW",
    priority = "secondary",
}

prototype "科技中心1" {
    model = "prefabs/lab-1.prefab",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}

prototype "砖石公路-O型" {
    model = "prefabs/road/road_O.prefab",
    construct_detector = {"exclusive"},
    type ={"entity"},
    area = "1x1",
    road = true,
}

prototype "砖石公路-I型" {
    model = "prefabs/road/road_I.prefab",
    construct_detector = {"exclusive"},
    type ={"entity"},
    area = "1x1",
    road = true,
}

prototype "砖石公路-L型" {
    model = "prefabs/road/road_L.prefab",
    construct_detector = {"exclusive"},
    type ={"entity"},
    area = "1x1",
    road = true,
}

prototype "砖石公路-T型" {
    model = "prefabs/road/road_T.prefab",
    construct_detector = {"exclusive"},
    type ={"entity"},
    area = "1x1",
    road = true,
}

prototype "砖石公路-U型" {
    model = "prefabs/road/road_U.prefab",
    construct_detector = {"exclusive"},
    type ={"entity"},
    area = "1x1",
    road = true,
}

prototype "砖石公路-X型" {
    model = "prefabs/road/road_X.prefab",
    construct_detector = {"exclusive"},
    type ={"entity"},
    area = "1x1",
    road = true,
}