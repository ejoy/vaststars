local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "蒸汽发电机I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/construct/turbine1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "generator", "fluidbox"},
    area = "2x3",
    power = "1MW",
    priority = "secondary",
    group = {"物流"},
    fluidbox = {
        capacity = 100,
        height = 200,
        base_level = -100,
        connections = {
            {type="input-output", position={1,0,"N"}},
            {type="input-output", position={1,2,"S"}},
        }
    }
}

prototype "风力发电机I" {
    model = "prefabs/wind-turbine-1.prefab",
    icon = "textures/construct/wind-turbine.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "generator"},
    area = "3x3",
    power = "1.2MW",
    priority = "primary",
    group = {"物流"},
}

prototype "太阳能板I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/construct/solar-panel.texture",
    construct_detector = {"exclusive"},
    type ={"entity","generator","solar_panel"},
    area = "3x3",
    power = "300kW",
    priority = "primary",
    group = {"物流"},
}

prototype "蓄电池I" {
    model = "prefabs/small-chest.prefab",
    icon = "textures/construct/grid-battery.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "accumulator"},
	power = "400kW",
	charge_power = "100kW",
	capacitance = "10MJ",
    area = "2x2",
    priority = "secondary",
    group = {"物流"},
}

prototype "核反应堆" {
    model = "prefabs/wind-turbine-1.prefab",
    icon = "textures/construct/solar-panel.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "generator", "burner"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
    group = {"物流"},
}