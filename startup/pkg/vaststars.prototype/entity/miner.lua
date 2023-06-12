local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "采矿机I" {
    model = "prefabs/miner-1.prefab",
    icon = "textures/building_pic/small_pic_miner.texture",
    background = "textures/build_background/pic_miner.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "mining"},
    area = "3x3",
    assembling_icon = false,
    power = "75kW",
    priority = "secondary",
    mining_area = "5x5",
    mining_category = {"矿石开采"},
    speed = "100%",
    building_base = false,
    maxslot = "8",
    camera_distance = 100,
}

prototype "采矿机II" {
    model = "prefabs/miner-1.prefab",
    icon = "textures/building_pic/small_pic_miner.texture",
    background = "textures/build_background/pic_miner.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "mining"},
    area = "3x3",
    assembling_icon = false,
    power = "150kW",
    priority = "secondary",
    mining_area = "5x5",
    mining_category = {"矿石开采"},
    speed = "150%",
    building_base = false,
    maxslot = "8",
    camera_distance = 100,
}