local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "铁制电线杆" {
    model = "glbs/electric-pole-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/electric-pole-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building"},
    area = "1x1",
    camera_distance = 90,
}

prototype "远程电线杆" {
    model = "glbs/electric-pole-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/electric-pole-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building"},
    area = "2x2",
    camera_distance = 90,
}

prototype "广域电线杆" {
    model = "glbs/electric-pole-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/electric-pole-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building"},
    area = "2x2",
    camera_distance = 90,
}