local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "采矿机I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/construct/miner1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer", "mining"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",

    mining_area = "5x5",
    speed = "100%",
    group = {"加工"},
}