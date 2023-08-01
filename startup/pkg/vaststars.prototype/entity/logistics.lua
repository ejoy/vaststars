local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    icon = "ui/textures/building_pic/small_pic_headquarter.texture",
    background = "ui/textures/build_background/pic_headquater.texture",
    construct_detector = {"exclusive"},
    craft_category = {"基地制造"},
    item = "运输车辆I", -- lorry_factory
    type = {"building", "base", "lorry_factory"},
    speed = "50%",
    maxslot = "8",
    area = "6x6",
    camera_distance = 100,
    teardown = false,
    move = false,
    building_base = false,
    crossing = {
        connections = {
            {type="lorry_factory", position={2,4,"S"}},
        },
    },
    starting = "2,2",
    road = {
        "2,2,║",
        "2,4,║",
        "2,6,╨",
    },
}

prototype "科研中心I" {
    type = {"building", "consumer","laboratory"},
    model = "prefabs/lab-1.prefab",
    icon = "ui/textures/building_pic/small_pic_lab.texture",
    background = "ui/textures/build_background/pic_lab.texture",
    construct_detector = {"exclusive"},
    area = "3x3",
    power = "100kW",
    speed = "100%",
    camera_distance = 75,
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
}

prototype "科研中心II" {
    type = {"building", "consumer","laboratory"},
    model = "prefabs/lab-1.prefab",
    icon = "ui/textures/building_pic/small_pic_lab.texture",
    background = "ui/textures/build_background/pic_lab.texture",
    construct_detector = {"exclusive"},
    area = "3x3",
    power = "250kW",
    speed = "200%",
    camera_distance = 75,
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
}

prototype "科研中心III" {
    type = {"building", "consumer","laboratory"},
    model = "prefabs/lab-1.prefab",
    icon = "ui/textures/building_pic/small_pic_lab.texture",
    background = "ui/textures/build_background/pic_lab.texture",
    construct_detector = {"exclusive"},
    area = "3x3",
    power = "500kW",
    speed = "400%",
    camera_distance = 75,
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
}


prototype "砖石公路-I型" {
    display_name = "砖石公路",
    construct_name = "砖石公路-X型",
    icon = "ui/textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    building_category = 4,
    building_direction = {"N", "E"},
    track = "I",
    type = {"building", "road"},
    area = "2x2",
    crossing = {
        connections = {
            {type="none", position={0,0,"N"}},
            {type="none", position={0,0,"S"}},
        },
    },
    road = {
        "0,0,║",
    },
    building_base = false,
}

prototype "砖石公路-L型" {
    display_name = "砖石公路",
    construct_name = "砖石公路-X型",
    icon = "ui/textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    building_category = 4,
    building_direction = {"N", "E", "S", "W"},
    track = "L",
    type = {"building", "road"},
    area = "2x2",
    crossing = {
        connections = {
            {type="none", position={0,0,"N"}},
            {type="none", position={0,0,"E"}},
        },
    },
    road = {
        "0,0,╚",
    },
    building_base = false,
}

prototype "砖石公路-T型" {
    display_name = "砖石公路",
    construct_name = "砖石公路-X型",
    icon = "ui/textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    building_category = 4,
    building_direction = {"N", "E", "S", "W"},
    track = "T",
    type = {"building", "road"},
    area = "2x2",
    crossing = {
        connections = {
            {type="none", position={0,0,"E"}},
            {type="none", position={0,0,"S"}},
            {type="none", position={0,0,"W"}},
        },
    },
    road = {
        "0,0,╦",
    },
    building_base = false,
}

prototype "砖石公路-O型" {
    display_name = "砖石公路",
    construct_name = "砖石公路-X型",
    icon = "ui/textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    building_category = 4,
    building_direction = {"N"},
    track = "O",
    type = {"building", "road"},
    area = "2x2",
    crossing = {
        connections = {
        }
    },
    road = {
    },
    building_base = false,
}

prototype "砖石公路-U型" {
    construct_name = "砖石公路-X型",
    display_name = "砖石公路",
    icon = "ui/textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    building_category = 4,
    building_direction = {"N", "E", "S", "W"},
    track = "U",
    type = {"building", "road"},
    area = "2x2",
    crossing = {
        connections = {
            {type="none", position={0,0,"N"}},
        },
    },
    road = {
        "0,0,v",
    },
    building_base = false,
}

prototype "砖石公路-X型" {
    display_name = "砖石公路",
    construct_name = "砖石公路-X型",
    model = "prefabs/road/road_X.prefab",
    icon = "ui/textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    building_category = 4,
    building_direction = {"N"},
    track = "X",
    type = {"building", "road"},
    area = "2x2",
    crossing = {
        connections = {
            {type="none", position={0,0,"N"}},
            {type="none", position={0,0,"E"}},
            {type="none", position={0,0,"S"}},
            {type="none", position={0,0,"W"}},
        },
    },
    road = {
        "0,0,╬",
    },
    building_base = false,
}

--出货车站需要设置送货类型以及需求车辆
prototype "出货车站" {
    model = "prefabs/delivery-station-1.prefab",
    icon = "ui/textures/building_pic/small_pic_goods_station1.texture",
    background = "ui/textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "station_producer"},
    building_base = false,
    rotate_on_build = true,
    area = "4x2",
    drone_height = 24,
    weights = 3,
    crossing = {
        connections = {
            {type="station", position={1,1,"S"}},
            {type="station", position={1,2,"S"}},
        },
    },
    endpoint = "2,0",
    road = {
        "0,0,╔╗",
        "0,2,╨╨",
    },
    camera_distance = 90,
}

--收货车站需要设置送货类型
prototype "收货车站" {
    model = "prefabs/receiving-station-1.prefab",
    icon = "ui/textures/building_pic/small_pic_goods_station1.texture",
    background = "ui/textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "station_consumer"},
    building_base = false,
    rotate_on_build = true,
    area = "4x2",
    drone_height = 24,
    maxlorry = 1,
    crossing = {
        connections = {
            {type="station", position={1,1,"S"}},
            {type="station", position={1,2,"S"}},
        },
    },
    endpoint = "2,0",
    road = {
        "0,0,╔╗",
        "0,2,╨╨",
    },
    camera_distance = 90,
}