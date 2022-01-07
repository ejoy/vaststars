local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "采矿机1" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}