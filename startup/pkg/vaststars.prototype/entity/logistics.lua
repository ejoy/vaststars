local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    icon = "textures/building_pic/small_pic_headquarter.texture",
    background = "textures/build_background/pic_headquater.texture",
    construct_detector = {"exclusive"},
    craft_category = {"基地制造"},
    chest_type = "red",
    type = {"building", "consumer", "assembling", "base", "lorry_factory"},
    speed = "50%",
    maxslot = "8",
    recipe_init_limit = {ingredientsLimit = 0, resultsLimit = 0},
    recipe = "车辆装配",
    area = "6x6",
    building_base = false,
    power_supply_area = "8x8",
    power_supply_distance = 9,
    power = "100kW",
    priority = "primary",
    camera_distance = 100,
    teardown = false,
    crossing = {
        connections = {
            {type="lorry_factory", position={2,4,"S"}},
        },
    },
    endpoint = "3,4",
    endpoint_road = {
        {position={1, 4}, prototype = "砖石公路-L型", dir = "E", mask={}},
        {position={3, 4}, prototype = "砖石公路-L型", dir = "S", mask={"Endpoint"}},
    },
    affected_roads = {
        {position={1, 6}, dir = "N"},
        {position={3, 6}, dir = "N"},
    },
    move = false,
    io_shelf = false,
    assembling_icon = false,
}

prototype "科研中心I" {
    type = {"building", "consumer","laboratory"},
    model = "prefabs/lab-1.prefab",
    icon = "textures/building_pic/small_pic_lab.texture",
    background = "textures/build_background/pic_lab.texture",
    construct_detector = {"exclusive"},
    area = "3x3",
    power = "150kW",
    speed = "100%",
    show_arc_menu = false,
    camera_distance = 75,
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
}

prototype "砖石公路-I型" {
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
    building_base = false,
}

prototype "砖石公路-L型" {
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
    building_base = false,
}

prototype "砖石公路-T型" {
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
    building_base = false,
}

prototype "砖石公路-O型" {
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
    building_base = false,
}

prototype "砖石公路-U型" {
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
    building_base = false,
}

prototype "砖石公路-X型" {
    show_prototype_name = "砖石公路",
    model = "prefabs/road/road_X.prefab",
    icon = "textures/construct/road1.texture",
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
    building_base = false,
}

--出货车站需要设置送货类型以及需求车辆
prototype "出货车站" {
    model = "prefabs/delivery-station-1.prefab",
    icon = "textures/building_pic/small_pic_goods_station1.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "station_producer"},
    chest_type = "blue",
    building_base = false,
    area = "4x2",
    weights = 3,
    crossing = {
        connections = {
            {type="station", position={1,1,"S"}},
            {type="station", position={1,2,"S"}},
        },
    },
    endpoint = "2,0",
    endpoint_road = {
        {position={0, 0}, prototype = "砖石公路-L型", dir = "E", mask={}},
        {position={2, 0}, prototype = "砖石公路-L型", dir = "S", mask={"Endpoint"}},
    },
    affected_roads = {
        {position={0, 2}, dir = "N"},
        {position={2, 2}, dir = "N"},
    },
    camera_distance = 90,
}

--收货车站需要设置送货类型
prototype "收货车站" {
    model = "prefabs/receiving-station-1.prefab",
    icon = "textures/building_pic/small_pic_goods_station1.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "station_consumer"},
    chest_type = "red",
    building_base = false,
    area = "4x2",
    maxlorry = 1,
    crossing = {
        connections = {
            {type="station", position={1,1,"S"}},
            {type="station", position={1,2,"S"}},
        },
    },
    endpoint = "2,0",
    endpoint_road = {
        {position={0, 0}, prototype = "砖石公路-L型", dir = "E", mask={}},
        {position={2, 0}, prototype = "砖石公路-L型", dir = "S", mask={"Endpoint"}},
    },
    affected_roads = {
        {position={0, 2}, dir = "N"},
        {position={2, 2}, dir = "N"},
    },
    camera_distance = 90,
}