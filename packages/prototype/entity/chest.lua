local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "小铁制箱子I" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "自定义"},
    area = "1x1",
    slots = 7,
}

prototype "小铁制箱子II" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "自定义"},
    area = "1x1",
    slots = 21,
}

prototype "大铁制箱子I" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/building_pic/small_pic_chest.texture",
    background = "textures/build_background/pic_chest.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "自定义"},
    area = "2x2",
    slots = 35,
}