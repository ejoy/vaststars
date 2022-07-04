local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "采矿机I" {
    model = "prefabs/miner.prefab",
    icon = "textures/building_pic/small_pic_miner.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer", "mining", "chimney", "fluidbox"},
    area = "3x3",
    power = "75kW",
    priority = "secondary",
    mining_area = "5x5",
    speed = "50%",
    group = {"加工"},
    craft_category = {"矿石开采"},
    minerals = {"铁矿石", "碎石"},
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
        },
    }
}

prototype "采矿机II" {
    model = "prefabs/miner.prefab",
    icon = "textures/building_pic/small_pic_miner.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer", "mining", "chimney", "fluidbox"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
    mining_area = "5x5",
    speed = "100%",
    group = {"加工"},
    craft_category = {"矿石开采"},
    minerals = {"铁矿石", "碎石"},
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
        },
    }
}