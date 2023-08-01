local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "机身残骸" {
    model = "prefabs/broken-assembling-3x3.prefab",
    icon = "ui/textures/building_pic/small_pic_assemble.texture",
    background = "ui/textures/build_background/pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    area = "5x5",
    slots = 21,
    building_base = false,
}

prototype "机翼残骸" {
    model = "prefabs/broken-outfall-2x2.prefab",
    icon = "ui/textures/building_pic/small_pic_outfall.texture",
    background = "ui/textures/build_background/pic_mars_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    area = "3x3",
    slots = 39,
    building_base = false,
}

prototype "机头残骸" {
    model = "prefabs/broken-outfall-2x2.prefab",
    icon = "ui/textures/building_pic/small_pic_outfall.texture",
    background = "ui/textures/build_background/pic_mars_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    area = "3x3",
    slots = 39,
    building_base = false,
}

prototype "机尾残骸" {
    model = "prefabs/broken-pump-2x2.prefab",
    icon = "ui/textures/building_pic/small_pic_pumpjack.texture",
    background = "ui/textures/build_background/pic_pumpjack.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    area = "3x3",
    slots = 11,
    building_base = false,
}
