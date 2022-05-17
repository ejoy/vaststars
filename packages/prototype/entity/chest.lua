local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "小型铁制箱子" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "自定义"},
    area = "1x1",
    slots = 10,
}