local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "机身残骸" {
    model = "glbs/broken-assembling-3x3.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
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
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x3",
    maxslot = 4,
}

prototype "机头残骸" {
    model = "glbs/broken-outfall-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x3",
    maxslot = 4,
}

prototype "机尾残骸" {
    model = "glbs/broken-pump-2x2.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x3",
    camera_distance = 55,
    maxslot = 4,
}

prototype "建筑物残骸 1x1" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "1x1",
    camera_distance = 55,
}

prototype "建筑物残骸 1x2" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "1x2",
    camera_distance = 55,
}

prototype "建筑物残骸 2x1" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "2x1",
    camera_distance = 55,
}

prototype "建筑物残骸 2x2" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "2x2",
    camera_distance = 55,
}

prototype "建筑物残骸 3x3" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x3",
    camera_distance = 55,
}

prototype "建筑物残骸 3x5" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "3x5",
    camera_distance = 55,
}

prototype "建筑物残骸 4x2" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "4x2",
    camera_distance = 55,
}

prototype "建筑物残骸 4x4" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "4x4",
    camera_distance = 55,
}

prototype "建筑物残骸 5x3" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "5x3",
    camera_distance = 55,
}

prototype "建筑物残骸 5x5" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "5x5",
    camera_distance = 55,
}

prototype "建筑物残骸 6x6" {
    display_name = "建筑物残骸",
    model = "",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_debris.texture",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "6x6",
    camera_distance = 55,
}