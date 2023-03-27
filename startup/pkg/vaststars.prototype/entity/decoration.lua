local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "组装机残骸" {
    model = "prefabs/broken-assembling-3x3.prefab",
    icon = "textures/building_pic/small_pic_assemble.texture",
    background = "textures/build_background/pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    show_detail = "false",
    area = "5x5",
    slots = 21,
    building_base = false,
}

prototype "排水口残骸" {
    model = "prefabs/broken-outfall-2x2.prefab",
    icon = "textures/building_pic/small_pic_outfall.texture",
    background = "textures/build_background/pic_mars_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    show_detail = "false",
    area = "3x3",
    slots = 38,
    building_base = false,
}

prototype "抽水泵残骸" {
    model = "prefabs/broken-pump-2x2.prefab",
    icon = "textures/building_pic/small_pic_pumpjack.texture",
    background = "textures/build_background/pic_pumpjack.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "red",
    show_detail = "false",
    area = "3x3",
    slots = 20,
    building_base = false,
}
