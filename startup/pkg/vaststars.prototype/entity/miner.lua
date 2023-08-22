local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "采矿机I" {
    model = "glbs/miner-1.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_miner.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "mining"},
    area = "3x3",
    drone_height = 42,
    assembling_icon = false,
    power = "150kW",
    priority = "secondary",
    mining_area = "5x5",
    sound = "building/miner",
    mining_category = {"矿石开采"},
    speed = "100%",
    building_base = false,
    maxslot = "8",
    camera_distance = 95,
}

prototype "采矿机II" {
    model = "glbs/miner-1.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_miner.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "mining"},
    area = "3x3",
    drone_height = 42,
    assembling_icon = false,
    power = "300kW",
    priority = "secondary",
    mining_area = "5x5",
    sound = "building/miner",
    mining_category = {"矿石开采"},
    speed = "200%",
    building_base = false,
    maxslot = "8",
    camera_distance = 95,
}

prototype "采矿机III" {
    model = "glbs/miner-1.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_miner.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "mining"},
    area = "3x3",
    drone_height = 42,
    assembling_icon = false,
    power = "600kW",
    priority = "secondary",
    mining_area = "5x5",
    sound = "building/miner",
    mining_category = {"矿石开采"},
    speed = "300%",
    building_base = false,
    maxslot = "8",
    camera_distance = 95,
}