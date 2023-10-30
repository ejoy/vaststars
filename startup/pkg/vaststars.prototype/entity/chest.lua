local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "小铁制箱子I" {
    model = "glbs/small-chest.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    area = "1x1",
}

prototype "小铁制箱子II" {
    model = "glbs/small-chest.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "1x1",
}

prototype "大铁制箱子I" {
    model = "glbs/small-chest.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "2x2",
}

prototype "仓库I" {
    model = "glbs/depot.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest", "depot"},
    chest_style = "station",
    chest_type = "transit",
    area = "1x1",
    camera_distance = 30,
    max_slot = 4,
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
        "无人机I",
    },
    camera_distance = 35,
    sound = "building/drone",
}

prototype "无人机平台II" {
    model = "glbs/drone-depot2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_drone_depot.texture",
    construct_detector = {"exclusive"},
    type = {"building", "airport", "consumer"},
    priority = "secondary",
    power = "80kW",
    capacitance = "160kJ",
    area = "1x1",
    supply_area = "7x7",
    drone = {
        "无人机II",
        "无人机II",
    },
    camera_distance = 35,
    sound = "building/drone",
}

prototype "无人机平台III" {
    model = "glbs/drone-depot2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_drone_depot.texture",
    construct_detector = {"exclusive"},
    type = {"building", "airport", "consumer"},
    priority = "secondary",
    power = "240kW",
    capacitance = "480kJ",
    area = "1x1",
    supply_area = "9x9",
    drone = {
        "无人机III",
        "无人机III",
        "无人机III",
        "无人机III",
    },
    camera_distance = 35,
    sound = "building/drone",
}

--{ "无人机", 1 }, 表示一个无人机带一种货物1
--{ "无人机", 1 }, { "无人机", 2 },表示一个无人机带货物1，另外一个无人机带货物2
--{ "无人机", 1 }, { "无人机", 1 },表示两个无人机带货物1