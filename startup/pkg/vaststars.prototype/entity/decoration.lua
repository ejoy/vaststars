local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "机身残骸" {
    model = "glbs/broken-assembling-3x3.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/broken-assembling-3x3.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/glbs/broken-outfall-2x2.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/glbs/broken-outfall-2x2.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/glbs/broken-pump-2x2.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/1x1.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/1x2.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/2x1.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/2x2.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/3x3.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/3x5.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/4x2.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/4x4.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/5x3.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/5x5.glb|mesh.prefab config:s,1,3",
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
    icon = "mem:/pkg/vaststars.resources/vaststars.resources/glbs/scaffold/6x6.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "chest", "debris"},
    chest_type = "supply",
    chest_style = "chest",
    chest_destroy = true,
    area = "6x6",
    camera_distance = 55,
}