local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "小铁制箱子I" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    area = "1x1",
    slots = 10,
}

prototype "建材箱" {
    model = "prefabs/drop-box.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    area = "1x1",
    slots = 10,
}

prototype "小铁制箱子II" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "1x1",
    slots = 20,
}

prototype "大铁制箱子I" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "2x2",
    slots = 30,
}

prototype "仓库" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building"},
    area = "5x5",
    slots = 60,
}

prototype "无人机仓库I" {
    model = "prefabs/drone-depot.prefab",
    icon = "textures/building_pic/small_pic_drone_depot.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "hub"},
    area = "2x2",
    supply_area = "6x6",
    slots = 1,
    drone_entity = "无人机",
    drone_count = 1,
    power_supply_area = "6x6",
    power_supply_distance = 8,
    camera_distance = 45,
}

prototype "无人机仓库II" {
    model = "prefabs/drone-depot.prefab",
    icon = "textures/building_pic/small_pic_drone_depot.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "hub"},
    area = "2x2",
    supply_area = "8x8",
    slots = 1,
    drone_entity = "无人机",
    drone_count = 2,
    power_supply_area = "6x6",
    power_supply_distance = 8,
    camera_distance = 45,
}

prototype "无人机仓库III" {
    model = "prefabs/drone-depot.prefab",
    icon = "textures/building_pic/small_pic_drone_depot.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"building", "hub"},
    area = "2x2",
    supply_area = "8x8",
    slots = 1,
    drone_entity = "无人机",
    drone_count = 4,
    power_supply_area = "6x6",
    power_supply_distance = 8,
    camera_distance = 45,
}