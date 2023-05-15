local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    model = "prefabs/headquater-1.prefab",
    icon = "textures/building_pic/small_pic_headquarter.texture",
    background = "textures/build_background/pic_headquater.texture",
    construct_detector = {"exclusive"},
    craft_category = {"基地制造"},
    chest_type = "red",
    type = {"building", "consumer", "assembling", "base", "inventory", "lorry_factory"},
    speed = "50%",
    maxslot = "8",
    recipe_init_limit = {ingredientsLimit = 0, resultsLimit = 0},
    recipe = "车辆装配",
    area = "5x5",
    power_supply_area = "9x9",
    power_supply_distance = 9,
    dismantle_area = "21x21",
    power = "100kW",
    priority = "primary",
    teardown = false,
    crossing = {
        connections = {
            {type="lorry_factory", position={2,4,"S"}},
        },
    },
    endpoint = {
        {position={0, 4}, prototype = "砖石公路-L型", dir = "E", entrance_dir = "S", mask={"ROADNET_MASK_ROADNET_ONLY"}},
        {position={1, 4}, prototype = "砖石公路-L型", dir = "S", entrance_dir = "S", mask={"ROADNET_MASK_ROADNET_ONLY", "ROADNET_MASK_ENDPOINT", "ROADNET_MASK_NOLEFTTURN"}},
    },
    move = false,
    io_shelf = false,
    assembling_icon = false,
}

prototype "物流需求站" {
    model = "prefabs/goods-station-1.prefab",
    icon = "textures/building_pic/small_pic_goodsstation_input.texture",
    background = "textures/build_background/small_pic_goodsstation_input.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "1x1",
    slots = 10,
}

prototype "物流中心I" {
    model = "prefabs/logistics-center-1.prefab",
    icon = "textures/building_pic/small_pic_logistics_center2.texture",
    background = "textures/build_background/pic_logisticscenter.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer"},
    area = "3x3",
    capacitance = "50MJ",
    power = "400kW",
    priority = "secondary",
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
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
}

prototype "砖石公路-I型" {
    model = "prefabs/road/road_I.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E"},
    track = "I",
    type = {"building", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="none", position={0,0,"N"}},
            {type="none", position={0,0,"S"}},
        },
    },
    building_base = false,
}

prototype "砖石公路-L型" {
    model = "prefabs/road/road_L.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E", "S", "W"},
    track = "L",
    type = {"building", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="none", position={0,0,"N"}},
            {type="none", position={0,0,"E"}},
        },
    },
    building_base = false,
}

prototype "砖石公路-T型" {
    model = "prefabs/road/road_T.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E", "S", "W"},
    track = "T",
    type = {"building", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="none", position={0,0,"E"}},
            {type="none", position={0,0,"S"}},
            {type="none", position={0,0,"W"}},
        },
    },
    building_base = false,
}

prototype "砖石公路-X型" {
    show_prototype_name = "砖石公路",
    model = "prefabs/road/road_X.prefab",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N"},
    track = "X",
    type = {"building", "road"},
    area = "1x1",
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

prototype "砖石公路-O型" {
    model = "prefabs/road/road_O.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N"},
    track = "O",
    type = {"building", "road"},
    area = "1x1",
    crossing = {
        connections = {
        }
    },
    building_base = false,
}

prototype "砖石公路-U型" {
    model = "prefabs/road/road_U.prefab",
    show_prototype_name = "砖石公路-I型",
    icon = "textures/construct/road1.texture",
    construct_detector = {"exclusive"},
    flow_type = 11,
    flow_direction = {"N", "E", "S", "W"},
    track = "U",
    type = {"building", "road"},
    area = "1x1",
    crossing = {
        connections = {
            {type="none", position={0,0,"N"}},
        },
    },
    building_base = false,
}

prototype "拆除点" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    area = "1x1",
    dismantle_area = "32x32",
    slots = 20,
}

prototype "建造中心" {
    model = "prefabs/construction-center.prefab",
    icon = "textures/building_pic/small_pic_construction_site.texture",
    background = "textures/build_background/pic_headquater.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    maxslot = 6,
    craft_category = {"框架打印"},
    fluidboxes = {
        input = {
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={4,1,"E"}},
                }
            },
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={4,3,"E"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,1,"W"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,3,"W"}},
                }
            },
        },
    },
    recipe_init_limit = {ingredientsLimit = 10, resultsLimit = 10},
    recipe_max_limit = {ingredientsLimit = 10, resultsLimit = 10},
    power = "75kW",
    priority = "secondary",
    io_shelf = false,
}

prototype "修路站" {
    model = "prefabs/road-center.prefab",
    icon = "textures/building_pic/small_pic_road_center.texture",
    background = "textures/build_background/small_pic_goodsstation_input.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "2x2",
    capacity = 50,
    build_area = "30x30",
}

prototype "修管站" {
    model = "prefabs/pipe-center.prefab",
    icon = "textures/building_pic/small_pic_pipe_center.texture",
    background = "textures/build_background/small_pic_goodsstation_input.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "2x2",
    capacity = 50,
    build_area = "24x24",
}

--送货车站需要设置送货类型以及需求车辆
prototype "送货车站" {
    model = "prefabs/delivery-station-1.prefab",
    icon = "textures/building_pic/small_pic_goods_station1.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "station"},
    station_type = "station_producer",
    chest_type = "blue",
    area = "2x1",
    weights = 1,
    crossing = {
        connections = {
            {type="station", position={0,0,"S"}},
        },
    },
    endpoint = {
        {position={0, 0}, prototype = "砖石公路-L型", dir = "E", entrance_dir = "S", mask={"ROADNET_MASK_ROADNET_ONLY"}},
        {position={1, 0}, prototype = "砖石公路-L型", dir = "S", entrance_dir = "S", mask={"ROADNET_MASK_ROADNET_ONLY", "ROADNET_MASK_ENDPOINT", "ROADNET_MASK_NOLEFTTURN"}},
    },
    move = false,
}

--收货车站需要设置送货类型
prototype "收货车站" {
    model = "prefabs/receiving-station-1.prefab",
    icon = "textures/building_pic/small_pic_goods_station1.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "station"},
    station_type = "station_consumer",
    chest_type = "red",
    area = "2x1",
    weights = 1,
    crossing = {
        connections = {
            {type="station", position={0,0,"S"}},
        },
    },
    endpoint = {
        {position={0, 0}, prototype = "砖石公路-L型", dir = "E", entrance_dir = "S", mask={"ROADNET_MASK_ROADNET_ONLY"}},
        {position={1, 0}, prototype = "砖石公路-L型", dir = "S", entrance_dir = "S", mask={"ROADNET_MASK_ROADNET_ONLY", "ROADNET_MASK_ENDPOINT", "ROADNET_MASK_NOLEFTTURN"}},
    },
    move = false,
}