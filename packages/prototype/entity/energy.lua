local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "蒸汽发电机1" {
    model = "prefabs/assembling-1.prefab",
    type ={"entity", "generator", "fluidbox"},
    area = "2x3",
    power = "1MW",
    priority = "secondary",
    fluidbox = {
        capacity = 100,
        height = 200,
        base_level = -100,
        connections = {
            {type="input-output", position={0,1,"W"}},
            {type="input-output", position={2,1,"E"}},
        }
    }
}

prototype "风力发电机1" {
    model = "prefabs/wind-turbine-1.prefab",
    type ={"entity", "generator"},
    area = "3x3",
    power = "1.2MW",
    priority = "primary",
}

prototype "太阳能板1" {
    model = "prefabs/assembling-1.prefab",
    type ={"entity","generator"},
    area = "3x3",
    power = "100kW",
    priority = "primary",
}

prototype "蓄电池1" {
    model = "prefabs/small-chest.prefab",
    type ={"entity"},
    area = "2x2",
    priority = "secondary",
}

prototype "核反应堆" {
    model = "prefabs/wind-turbine-1.prefab",
    type = {"entity", "generator", "burner"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
}