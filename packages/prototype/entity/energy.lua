local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "蒸汽发电机I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/construct/turbine1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "generator", "fluidbox"},
    area = "3x5",
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
    model = "prefabs/solar-panel-1.prefab",
    icon = "textures/building_pic/small_pic_solar_panel.texture",
    construct_detector = {"exclusive"},
    type ={"entity","generator","solar_panel"},
    area = "3x3",
    power = "300kW",
    priority = "primary",
    group = {"物流"},
}

prototype "蓄电池I" {
    model = "prefabs/accumulator-1.prefab",
    icon = "textures/building_pic/small_pic_accumulator.texture",
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

prototype "换热器I" {
    model = "prefabs/distillery-1.prefab",
    icon = "textures/building_pic/small_pic_distillery.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "fluidboxes"},
    area = "3x2",
    craft_category = {"流体换热处理"},
    fluidboxes = {
        input = {
            {
                capacity = 200,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={0,0,"W"}},
                }
            },
        },
        output = {
            {
                capacity = 1000,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={1,1,"S"}},
                }
            },
            {
                capacity = 200,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,0,"E"}},
                }
            },
        },
    },
}

prototype "热管1-X型" {
    model = "prefabs/pipe/pipe_I.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    show_build_function = false,
    type = {"entity"},
    area = "1x1",
    group = {"物流"},
}