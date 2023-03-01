local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "无人机" {
    model = "prefabs/drone.prefab",
    type = {"drone"},
}