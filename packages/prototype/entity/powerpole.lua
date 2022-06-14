local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "铁制电线杆" {
    model = "prefabs/electric-pole-1.prefab",
    icon = "textures/building_pic/small_pic_electricpole.texture",
    construct_detector = {"exclusive"},
    type = {"entity"},
    area = "1x1",
    supply_area = "5x5",
    group = {"物流","自定义"},
}