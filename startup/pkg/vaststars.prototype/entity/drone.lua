local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "无人机I" {
    model = "prefabs/drone.prefab",
    type = {"drone"},
    speed = 150, --1000为1格/tick
    cost = "20kJ",
}

prototype "无人机II" {
    model = "prefabs/drone.prefab",
    type = {"drone"},
    speed = 150, --1000为1格/tick
    cost = "40kJ",
}

prototype "无人机III" {
    model = "prefabs/drone.prefab",
    type = {"drone"},
    speed = 150, --1000为1格/tick
    cost = "60kJ",
}