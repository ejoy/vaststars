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
    show_arc_menu = false,
}