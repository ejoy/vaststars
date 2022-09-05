local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    icon = "textures/building_pic/small_pic_headquarter.texture",
    background = "textures/build_background/pic_headquater.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "generator", "chest", "base"},
    area = "5x5",
    supply_area = "9x9",
    supply_distance = 9,
    power = "1MW",
    priority = "primary",
    group = {"物流"},
    slots = 70,
    headquater = true,
    teardown = false,
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

prototype "物流中心I" {
    model = "prefabs/logistics-center-1.prefab",
    icon = "textures/construct/logisitic2.texture",
    background = "textures/build_background/pic_logisticscenter.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer"},
    area = "3x3",
    power = "300kW",
    priority = "secondary",
    group = {"物流"},
    crossing = {
        connections = {
            {type="output", position={1,2,"S"}},
        },
    }
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

prototype "科研中心I" {
    type ={"entity", "consumer","laboratory"},
    model = "prefabs/lab-1.prefab",
    icon = "textures/building_pic/small_pic_lab.texture",
    background = "textures/build_background/pic_lab.texture",
    construct_detector = {"exclusive"},
    area = "3x3",
    power = "150kW",
    speed = "100%",
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
    group = {"物流"},
}

prototype "砖石公路-I型" {
    model = "prefabs/road/road_I.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E"},
    track = "I",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"S"}},
        },
    }
}

prototype "砖石公路-L型" {
    model = "prefabs/road/road_L.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E", "S", "W"},
    track = "L",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
        },
    }
}

prototype "砖石公路-T型" {
    model = "prefabs/road/road_T.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E", "S", "W"},
    track = "T",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        },
    }
}

prototype "砖石公路-X型" {
    show_prototype_name = "砖石公路",
    model = "prefabs/road/road_X.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N"},
    track = "X",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        },
    }
}

prototype "砖石公路-O型" {
    model = "prefabs/road/road_O.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N"},
    track = "O",
    tickcount = 0,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    group = {"物流","自定义"},
    crossing = {
        connections = {
        }
    }
}

prototype "砖石公路-U型" {
    model = "prefabs/road/road_U.prefab",
    icon = "textures/construct/processor.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E", "S", "W"},
    track = "U",
    tickcount = 20,
    show_build_function = false,
    type ={"entity", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="input-output", position={0,0,"N"}},
        },
    }
}