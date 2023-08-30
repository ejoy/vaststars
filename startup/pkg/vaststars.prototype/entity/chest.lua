local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "小铁制箱子I" {
    model = "glbs/small-chest.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    area = "1x1",
    slots = 10,
}

prototype "建材箱" {
    model = "glbs/drop-box.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    area = "1x1",
    slots = 10,
}

prototype "小铁制箱子II" {
    model = "glbs/small-chest.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "1x1",
    slots = 20,
}

prototype "大铁制箱子I" {
    model = "glbs/small-chest.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "2x2",
    slots = 30,
}

prototype "仓库I" {
    model = "glbs/depot.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "transit",
    area = "1x1",
    slots = 4,
    camera_distance = 30,
}

prototype "无人机平台I" {
    model = "glbs/drone-depot2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_drone_depot.texture",
    construct_detector = {"exclusive"},
    type = {"building", "airport", "consumer"},
    priority = "secondary",
    power = "20kW",
    capacitance = "40kJ",
    area = "1x1",
    supply_area = "5x5",
    drone = {
        { "无人机I", 1 },
    },
    power_supply_area = "5x5",
    power_supply_distance = 8,
    camera_distance = 35,
    sound = "building/drone",
}


--{ "无人机", 1 }, 表示一个无人机带一种货物1
--{ "无人机", 1 }, { "无人机", 2 },表示一个无人机带货物1，另外一个无人机带货物2
--{ "无人机", 1 }, { "无人机", 1 },表示两个无人机带货物1

prototype "无人机仓库I" {
    model = "glbs/drone-depot.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_drone_depot.texture",
    construct_detector = {"exclusive"},
    type = {"building", "airport", "consumer"},
    priority = "secondary",
    power = "20kW",
    capacitance = "40kJ",
    area = "2x2",
    supply_area = "6x6",
    drone = {
        { "无人机I", 1 },
    },
    power_supply_area = "6x6",
    power_supply_distance = 8,
    camera_distance = 45,
    sound = "building/drone",
}

prototype "无人机仓库II" {
    model = "glbs/drone-depot.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_drone_depot.texture",
    construct_detector = {"exclusive"},
    type = {"building", "airport", "consumer"},
    priority = "secondary",
    power = "80kW",
    capacitance = "160kJ",
    area = "2x2",
    supply_area = "8x8",
    drone = {
        { "无人机II", 1 },
        { "无人机II", 2 },
    },
    power_supply_area = "6x6",
    power_supply_distance = 8,
    camera_distance = 45,
    sound = "building/drone",
}

prototype "无人机仓库III" {
    model = "glbs/drone-depot.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_drone_depot.texture",
    construct_detector = {"exclusive"},
    type = {"building", "airport", "consumer"},
    priority = "secondary",
    power = "240kW",
    capacitance = "480kJ",
    area = "2x2",
    supply_area = "10x10",
    drone = {
        { "无人机III", 1 },
        { "无人机III", 1 },
        { "无人机III", 2 },
        { "无人机III", 2 },
    },
    power_supply_area = "6x6",
    power_supply_distance = 8,
    camera_distance = 45,
    sound = "building/drone",
}