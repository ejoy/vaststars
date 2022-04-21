local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "采矿机1" {
    model = "prefabs/assembling-1.prefab",
    icon = "construct/miner1.png",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer", "mining"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",

    mining_area = "5x5",
    speed = "100%",
}
