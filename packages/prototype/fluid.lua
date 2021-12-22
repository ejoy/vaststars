local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "空气" {
    type = {"fluid"},
    heat_capacity = "0.08KJ",
    fuel_value = "32KJ",
    default_temperature = 50,
    max_temperature = 100,
    des = "大气层中的基本气体",
}