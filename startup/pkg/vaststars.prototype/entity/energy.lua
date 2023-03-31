local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "蒸汽发电机I" {
    model = "prefabs/turbine-1.prefab",
    icon = "textures/building_pic/small_pic_turbine.texture",
    background = "textures/build_background/pic_turbine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "generator", "fluidbox"},
    area = "3x5",
    rotate_on_build = true,
    power = "1MW",
    priority = "secondary",
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
    icon = "textures/building_pic/small_pic_wind_turbine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "generator", "wind_turbine"},
    area = "3x3",
    power = "1.2MW",
    priority = "primary",
    power_pole = true,
    power_supply_area = "7x7",
    power_supply_distance = 7,
}

prototype "太阳能板I" {
    model = "prefabs/solar-panel-1.prefab",
    icon = "textures/building_pic/small_pic_solar_panel.texture",
    construct_detector = {"exclusive"},
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "300kW",
    priority = "primary",
}

prototype "蓄电池I" {
    model = "prefabs/accumulator-1.prefab",
    icon = "textures/building_pic/small_pic_accumulator.texture",
    construct_detector = {"exclusive"},
    type = {"building", "accumulator"},
	power = "400kW",
	charge_power = "100kW",
	capacitance = "10MJ",
    area = "2x2",
    priority = "secondary",
}

prototype "核反应堆" {
    model = "prefabs/wind-turbine-1.prefab",
    icon = "textures/construct/solar-panel.texture",
    construct_detector = {"exclusive"},
    type = {"building", "generator"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
}

prototype "换热器I" {
    model = "prefabs/distillery-1.prefab",
    icon = "textures/building_pic/small_pic_distillery.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "fluidboxes", "consumer"},
    power = "300kW",
    priority = "secondary",
    area = "3x2",
    rotate_on_build = true,
    craft_category = {"流体换热处理"},
    show_arc_menu = false,
    maxslot = "8",
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
    show_arc_menu = false,
    type = {"building"},
    area = "1x1",
}

prototype "锅炉I" {
    model = "prefabs/distillery-1.prefab",
    icon = "textures/building_pic/small_pic_distillery.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "fluidboxes", "consumer"},
    power = "300kW",
    priority = "secondary",
    area = "3x2",
    rotate_on_build = true,
    craft_category = {"流体换热处理"},
    maxslot = "8",
    fluidboxes = {
        input = {
            {
                capacity = 500,
                height = 150,
                base_level = -100,
                connections = {
                    {type="input-output", position={0,0,"W"}},
                    {type="input-output", position={2,0,"E"}},
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
        },
    },
}
