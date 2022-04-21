local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "熔炼炉1" {
    model = "prefabs/furnace-1.prefab",
    icon = "construct/furnace2.png",
    construct_detector = {"exclusive"},
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "50%",
    power = "75kW",
    priority = "secondary",
}

prototype "粉碎机1" {
    model = "prefabs/assembling-1.prefab",
    icon = "construct/crusher1.png",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer"},
    area = "3x3",
    power = "100kW",
    drain = "3kW",
    priority = "secondary",
}
