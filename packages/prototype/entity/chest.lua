local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "小型铁制箱子" {
    type = {"entity", "chest"},
    area = "1x1",
    slots = 10,
}