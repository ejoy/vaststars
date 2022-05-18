local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    icon = "textures/building_pic/small_pic_headquarter.texture",
    background = "textures/build_background/pic_headquater.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "generator", "chest"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
    group = {"物流"},
    slots = 20,
    headquater = true,
}

prototype "车站I" {
    model = "prefabs/goods-station-1.prefab",
    icon = "textures/construct/logisitic1.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    area = "1x1",
    slots = 30,
    group = {"物流","自定义"},
}

prototype "物流中心" {
    model = "prefabs/logistics-center-1.prefab",
    icon = "textures/construct/logisitic2.texture",
    background = "textures/build_background/pic_logisticscenter.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer"},
    area = "3x3",
    power = "600kW",
    priority = "secondary",
    group = {"物流"},
}

prototype "机器爪I" {
    model = "prefabs/inserter-1.prefab",
    icon = "textures/building_pic/small_pic_inserter.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "inserter", "consumer"},
    area = "1x1",
    speed = "1s",
    power = "12kW",
    priority = "secondary",
    group = {"物流","自定义"},
}

prototype "科技中心I" {
    model = "prefabs/lab-1.prefab",
    icon = "textures/building_pic/small_pic_lab.texture",
    background = "textures/build_background/pic_lab.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
    group = {"物流"},
}

prototype "砖石公路-O型" {
    show_prototype_name = "砖石公路",
    model = "prefabs/road/road_O.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    road = true,
    type ={"entity"},
    area = "1x1",
    group = {"物流","自定义"},
}

prototype "砖石公路-I型" {
    model = "prefabs/road/road_I.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    road = true,
    type ={"entity"},
    area = "1x1",
}

prototype "砖石公路-L型" {
    model = "prefabs/road/road_L.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    road = true,
    type ={"entity"},
    area = "1x1",
}

prototype "砖石公路-T型" {
    model = "prefabs/road/road_T.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    road = true,
    type ={"entity"},
    area = "1x1",
}

prototype "砖石公路-U型" {
    model = "prefabs/road/road_U.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    road = true,
    type ={"entity"},
    area = "1x1",
}

prototype "砖石公路-X型" {
    model = "prefabs/road/road_X.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    road = true,
    type ={"entity"},
    area = "1x1",
}