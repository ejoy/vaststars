local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "铁制电线杆" {
    model = "prefabs/electric-pole-1.prefab",
    icon = "textures/building_pic/small_pic_electricpole.texture",
    construct_detector = {"exclusive"},
    power_pole = true,
    type = {"building"},
    area = "1x1",
    supply_area = "5x5",
    supply_distance = 9,
    group = {"电力","默认"},
}