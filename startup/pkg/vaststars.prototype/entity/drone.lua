local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "无人机" {
    model = "prefabs/drone.prefab",
    type = {"drone"},
    speed = 150, --1000为1格/tick
    cost = "10kJ",
}
