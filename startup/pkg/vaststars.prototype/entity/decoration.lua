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
    area = "5x5",
    camera_distance = 93,
    maxslot = 4,
}

prototype "机翼残骸" {
    model = "glbs/broken-outfall-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x3",
    maxslot = 4,
}

prototype "机头残骸" {
    model = "glbs/broken-outfall-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x3",
    maxslot = 4,
}

prototype "机尾残骸" {
    model = "glbs/broken-pump-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x3",
    camera_distance = 55,
    maxslot = 4,
}

prototype "建筑物残骸" {
    model = "glbs/broken-building.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_debris.texture",
    construct_detector = {"exclusive"},
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "1x1",
    camera_distance = 55,
}