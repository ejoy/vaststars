local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    model = "glbs/headquater-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/headquater-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "base", "chest"},
    chest_type = "supply",
    maxslot = 16,
    speed = "50%",
    area = "6x6",
    sound = "building/headquarter",
}

prototype "物流中心" {
    model = "glbs/factory-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/factory-1.glb|mesh.prefab config:s,1,3",
    check_coord = "",   -- factory builder special
    builder = "factory",
    check_pos = {0,2,"N"},  -- factory builder special
    check_area = "4x2", -- factory builder special
    inner_building = {  -- factory builder special
        {0,4,"S","停车站"},
    },
    lorry_track = {
        {0,4,"4x2","factory"},
    },
    craft_category = {"基地制造"},
    item = "运输车辆I",
    type = {"building", "factory"},
    amount = "0",
    speed = "50%",
    maxslot = 20,
    area = "4x6",
    sound = "building/logistics-center",
    crossing = {
        connections = {
            {type="factory", position={2,4,"S"}},
        },
    },
    starting = "0,0",
    road = {
        "0,0,║",
        "0,2,╨",
    },
}

prototype "科研中心I" {
    type = {"building", "consumer","laboratory"},
    chest_style = "chest",
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/lab-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    area = "3x3",
    power = "100kW",
    speed = "100%",
    sound = "building/lab",
    drone_height = 42,
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
        "电子科技包",
        "化学科技包",
        "物理科技包",
    },
}

prototype "地质科研中心" {
    type = {"building", "consumer","laboratory"},
    chest_style = "chest",
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/lab-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    area = "3x3",
    power = "1MW",
    speed = "100%",
    sound = "building/lab",
    drone_height = 42,
    priority = "secondary",
    inputs = {
        "地质科技包",
    },
}

prototype "科研中心II" {
    type = {"building", "consumer","laboratory"},
    chest_style = "chest",
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/lab-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    area = "3x3",
    power = "250kW",
    speed = "200%",
    sound = "building/lab",
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
}

prototype "科研中心III" {
    type = {"building", "consumer","laboratory"},
    chest_style = "chest",
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/lab-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    area = "3x3",
    power = "500kW",
    speed = "400%",
    sound = "building/lab",
    priority = "secondary",
    inputs = {
        "地质科技包",
        "气候科技包",
        "机械科技包",
    },
}


prototype "砖石公路-I型" {
    building_category = 4,
    display_name = "砖石公路",
    item_name = "砖石公路-X型",
    model = "glbs/road/I.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/road/I.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "road",
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
}

prototype "砖石公路-L型" {
    building_category = 4,
    display_name = "砖石公路",
    item_name = "砖石公路-X型",
    model = "glbs/road/L.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/road/L.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "road",
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
}

prototype "砖石公路-T型" {
    building_category = 4,
    display_name = "砖石公路",
    item_name = "砖石公路-X型",
    model = "glbs/road/T.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/road/T.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "road",
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
}

prototype "砖石公路-O型" {
    building_category = 4,
    display_name = "砖石公路",
    item_name = "砖石公路-X型",
    model = "glbs/road/I.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/road/I.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "road",
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
}

prototype "砖石公路-U型" {
    building_category = 4,
    display_name = "砖石公路",
    item_name = "砖石公路-X型",
    model = "glbs/road/I.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/road/I.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "road",
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
}

prototype "砖石公路-X型" {
    building_category = 4,
    display_name = "砖石公路",
    item_name = "砖石公路-X型",
    model = "glbs/road/X.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/road/X.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "road",
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
}

prototype "物流站" {
    model = "glbs/goods-station-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/goods-station-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "station",
    type = {"building", "station"},
    lorry_track = {
        {0, 0, "4x2", "station"},
    },
    chest_style = "station",
    rotate_on_build = true,
    area = "4x2",
    drone_height = 24,
    sound = "building/logistics-center",
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
    maxslot = 8,
}

prototype "停车站" {
    model = "", -- inner_building special
    icon = "",
    check_coord = "",
    builder = "",
    type = {"building","park","inner_building"},
    area = "4x2",
    endpoint = "2,0",
    road = {
        "0,0,╔╗",
        "0,2,╨╨",
    },
}

prototype "广播塔I" {
    type = {"building", "consumer"},
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/lab-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    area = "3x3",
    power = "1MW",
    speed = "100%",
    module_slot = 1,
    module_supply_area = "9x9",
    priority = "secondary",
}

prototype "广播塔II" {
    type = {"building", "consumer"},
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/lab-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    area = "3x3",
    power = "2MW",
    speed = "100%",
    module_slot = 2,
    module_supply_area = "13x13",
    priority = "secondary",
}

prototype "广播塔III" {
    type = {"building", "consumer"},
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/lab-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    area = "3x3",
    power = "4MW",
    speed = "125%",
    module_slot = 3,
    module_supply_area = "13x13",
    priority = "secondary",
}