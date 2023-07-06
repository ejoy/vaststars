local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "蒸汽发电机I" {
    model = "prefabs/turbine-1.prefab",
    icon = "textures/building_pic/small_pic_turbine.texture",
    background = "textures/build_background/pic_turbine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "generator", "fluidboxes","assembling","auto_set_recipe"},
    area = "3x5",
    rotate_on_build = true,
    io_shelf = false,
    assembling_icon = false,
    building_menu = false,
    power = "900kW",
    priority = "secondary",
    -- recipe = "蒸汽发电",
    craft_category = {"流体发电"},
    maxslot = "8",
    power_supply_area = "3x5",
    power_supply_distance = 0,
    camera_distance = 95,
    fluidboxes = {
        input = {
            {
                capacity = 100,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input-output", position={1,0,"N"}},
                    {type="input-output", position={1,4,"S"}},
                }
            },
        },
        output = {
        },
    }
}

prototype "蒸汽发电机II" {
    model = "prefabs/turbine-1.prefab",
    icon = "textures/building_pic/small_pic_turbine.texture",
    background = "textures/build_background/pic_turbine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "generator", "fluidboxes","assembling","auto_set_recipe"},
    area = "3x5",
    rotate_on_build = true,
    io_shelf = false,
    assembling_icon = false,
    building_menu = false,
    power = "2.4MW",
    priority = "secondary",
    -- recipe = "蒸汽发电",
    craft_category = {"流体发电"},
    maxslot = "8",
    power_supply_area = "3x5",
    power_supply_distance = 0,
    camera_distance = 95,
    fluidboxes = {
        input = {
            {
                capacity = 100,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input-output", position={1,0,"N"}},
                    {type="input-output", position={1,4,"S"}},
                }
            },
        },
        output = {
        },
    }
}

prototype "蒸汽发电机III" {
    model = "prefabs/turbine-1.prefab",
    icon = "textures/building_pic/small_pic_turbine.texture",
    background = "textures/build_background/pic_turbine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "generator", "fluidboxes","assembling","auto_set_recipe"},
    area = "3x5",
    rotate_on_build = true,
    io_shelf = false,
    assembling_icon = false,
    building_menu = false,
    power = "6MW",
    priority = "secondary",
    -- recipe = "蒸汽发电",
    craft_category = {"流体发电"},
    maxslot = "8",
    power_supply_area = "3x5",
    power_supply_distance = 0,
    camera_distance = 95,
    fluidboxes = {
        input = {
            {
                capacity = 100,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input-output", position={1,0,"N"}},
                    {type="input-output", position={1,4,"S"}},
                }
            },
        },
        output = {
        },
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
    building_menu = false,
    power_network_link = true,
    power_supply_area = "11x11",
    power_supply_distance = 7,
    camera_distance = 120,
}

prototype "太阳能板I" {
    model = "prefabs/solar-panel-1.prefab",
    icon = "textures/building_pic/small_pic_solar_panel.texture",
    construct_detector = {"exclusive"},
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "300kW",
    priority = "primary",
    building_menu = false,
    power_supply_area = "3x3",
    power_supply_distance = 0,
    camera_distance = 70,
}

prototype "太阳能板II" {
    model = "prefabs/solar-panel-1.prefab",
    icon = "textures/building_pic/small_pic_solar_panel.texture",
    construct_detector = {"exclusive"},
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "450kW",
    priority = "primary",
    building_menu = false,
    power_supply_area = "3x3",
    power_supply_distance = 0,
    camera_distance = 70,
}

prototype "太阳能板III" {
    model = "prefabs/solar-panel-1.prefab",
    icon = "textures/building_pic/small_pic_solar_panel.texture",
    construct_detector = {"exclusive"},
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "600kW",
    priority = "primary",
    building_menu = false,
    power_supply_area = "3x3",
    power_supply_distance = 0,
    camera_distance = 70,
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
    building_menu = false,
    power_supply_area = "2x2",
    power_supply_distance = 0,
    camera_distance = 55,
}

prototype "蓄电池II" {
    model = "prefabs/accumulator-1.prefab",
    icon = "textures/building_pic/small_pic_accumulator.texture",
    construct_detector = {"exclusive"},
    type = {"building", "accumulator"},
	power = "600kW",
	charge_power = "200kW",
	capacitance = "30MJ",
    area = "2x2",
    priority = "secondary",
    building_menu = false,
    power_supply_area = "2x2",
    power_supply_distance = 0,
    camera_distance = 55,
}

prototype "蓄电池III" {
    model = "prefabs/accumulator-1.prefab",
    icon = "textures/building_pic/small_pic_accumulator.texture",
    construct_detector = {"exclusive"},
    type = {"building", "accumulator"},
	power = "800kW",
	charge_power = "250kW",
	capacitance = "60MJ",
    area = "2x2",
    priority = "secondary",
    building_menu = false,
    power_supply_area = "2x2",
    power_supply_distance = 0,
    camera_distance = 55,
}

prototype "核反应堆" {
    model = "prefabs/wind-turbine-1.prefab",
    icon = "textures/construct/solar-panel.texture",
    construct_detector = {"exclusive"},
    type = {"building", "generator"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
    camera_distance = 100,
}

prototype "换热器I" {
    model = "prefabs/boiler.prefab",
    icon = "textures/building_pic/small_pic_boiler.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    power = "1.8MW",
    priority = "secondary",
    area = "3x2",
    io_shelf = false,
    rotate_on_build = true,
    craft_category = {"流体换热处理"},
    building_menu = false,
    maxslot = "8",
    camera_distance = 100,
    fluidboxes = {
        input = {
            {
                capacity = 200,
                height = 100,
                base_level = -50,
                connections = {
                    {type="input-output", position={0,0,"W"}},
                }
            },
            {
                capacity = 200,
                height = 100,
                base_level = -50,
                connections = {
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

prototype "热管1-X型" {
    model = "prefabs/pipe/pipe_I.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    building_menu = false,
    type = {"building"},
    area = "1x1",
    camera_distance = 100,
}

prototype "锅炉I" {
    model = "prefabs/boiler.prefab",
    icon = "textures/building_pic/small_pic_boiler.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "fluidboxes"},
    priority = "secondary",
    area = "3x2",
    rotate_on_build = true,
    io_shelf = false,
    craft_category = {"流体换热处理"},
    maxslot = "8",
    allow_set_recipt = true,
    camera_distance = 65,
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

prototype "地热井I" {
    model = "prefabs/geothermal-plant.prefab",
    icon = "textures/building_pic/small_pic_geothermal_plant.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "fluidboxes","mining"},
    priority = "secondary",
    area = "5x5",
    rotate_on_build = true,
    io_shelf = false,
    building_menu = false,
    building_base = false,
    mining_category = {"地热处理"},
    maxslot = "8",
    camera_distance = 96,
    fluidboxes = {
        input = {
        },
        output = {
            {
                capacity = 1000,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,4,"S"}},
                }
            },
        },
    },
}

prototype "地热井II" {
    model = "prefabs/geothermal-plant.prefab",
    icon = "textures/building_pic/small_pic_geothermal_plant.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "fluidboxes","mining"},
    priority = "secondary",
    area = "5x5",
    rotate_on_build = true,
    io_shelf = false,
    building_menu = false,
    building_base = false,
    mining_category = {"地热处理"},
    maxslot = "8",
    camera_distance = 96,
    fluidboxes = {
        input = {
        },
        output = {
            {
                capacity = 1000,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,4,"S"}},
                }
            },
        },
    },
}

prototype "地热井III" {
    model = "prefabs/geothermal-plant.prefab",
    icon = "textures/building_pic/small_pic_geothermal_plant.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "fluidboxes","mining"},
    priority = "secondary",
    area = "5x5",
    rotate_on_build = true,
    io_shelf = false,
    building_menu = false,
    building_base = false,
    mining_category = {"地热处理"},
    maxslot = "8",
    camera_distance = 96,
    fluidboxes = {
        input = {
        },
        output = {
            {
                capacity = 1000,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,4,"S"}},
                }
            },
        },
    },
}