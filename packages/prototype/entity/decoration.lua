local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "组装机残骸" {
    model = "prefabs/broken-assembling-3X3.prefab",
    icon = "textures/construct/broken-assembler.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "自定义"},
    area = "3x3",
    slots = 10,
}

prototype "排水口残骸" {
    model = "prefabs/broken-outfall-2X2.prefab",
    icon = "textures/construct/broken-hydroplant.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "自定义"},
    area = "2x2",
    slots = 10,
}

prototype "抽水泵残骸" {
    model = "prefabs/broken-pump-2X2.prefab",
    icon = "textures/construct/broken-pump.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "自定义"},
    area = "2x2",
    slots = 10,
}