local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "铁制电线杆" {
    model = "prefabs/electric-pole-1.prefab",
    icon = "textures/building_pic/small_pic_electricpole.texture",
    construct_detector = {"exclusive"},
    power_network_link = true,
    type = {"building"},
    area = "1x1",
    power_supply_area = "5x5",
    power_supply_distance = 9,
    building_menu = false,
    camera_distance = 75,
}

prototype "远程电线杆" {
    model = "prefabs/electric-pole-1.prefab",
    icon = "textures/building_pic/small_pic_electricpole.texture",
    construct_detector = {"exclusive"},
    power_network_link = true,
    type = {"building"},
    area = "2x2",
    power_supply_area = "4x4",
    power_supply_distance = 36,
    building_menu = false,
    camera_distance = 75,
}

prototype "广域电线杆" {
    model = "prefabs/electric-pole-1.prefab",
    icon = "textures/building_pic/small_pic_electricpole.texture",
    construct_detector = {"exclusive"},
    power_network_link = true,
    type = {"building"},
    area = "2x2",
    power_supply_area = "12x12",
    power_supply_distance = 24,
    building_menu = false,
    camera_distance = 75,
}