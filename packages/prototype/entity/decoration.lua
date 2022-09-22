local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "组装机残骸" {
    model = "prefabs/broken-assembling-3X3.prefab",
    icon = "textures/construct/broken-assembler.texture",
    background = "textures/build_background/pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "默认"},
    area = "3x3",
    slots = 9,
}

prototype "排水口残骸" {
    model = "prefabs/broken-outfall-2X2.prefab",
    icon = "textures/construct/broken-hydroplant.texture",
    background = "textures/build_background/pic_mars_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "默认"},
    area = "2x2",
    slots = 8,
}

prototype "抽水泵残骸" {
    model = "prefabs/broken-pump-2X2.prefab",
    icon = "textures/construct/broken-pump.texture",
    background = "textures/build_background/pic_pumpjack.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "chest"},
    group = {"物流" , "默认"},
    area = "2x2",
    slots = 13,
}