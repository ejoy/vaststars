local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁矿石" {
    model = "prefabs/rock.prefab",
    construct_detector = {"exclusive"},
    type = {"entity"},
    area = "1x1",
}