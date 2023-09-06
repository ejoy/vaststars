local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "机身残骸" {
    model = "glbs/broken-assembling-3x3.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    set_item = false,
    area = "5x5",
    building_base = false,
}

prototype "机翼残骸" {
    model = "glbs/broken-outfall-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    set_item = false,
    area = "3x3",
    building_base = false,
}

prototype "机头残骸" {
    model = "glbs/broken-outfall-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    set_item = false,
    area = "3x3",
    building_base = false,
}

prototype "机尾残骸" {
    model = "glbs/broken-pump-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    set_item = false,
    area = "3x3",
    building_base = false,
}
