local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "蒸汽发电机I" {
    model = "glbs/turbine-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/turbine-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "generator", "fluidboxes","assembling","auto_set_recipe"},
    area = "3x5",
    rotate_on_build = true,
    io_shelf = false,
    assembling_icon = false,
    power = "900kW",
    priority = "secondary",
    sound = "building/steam-turbine",
    -- recipe = "蒸汽发电",
    craft_category = {"流体发电"},
    maxslot = 8,
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
    model = "glbs/turbine-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/turbine-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "generator", "fluidboxes","assembling","auto_set_recipe"},
    area = "3x5",
    rotate_on_build = true,
    io_shelf = false,
    assembling_icon = false,
    power = "2.4MW",
    priority = "secondary",
    sound = "building/steam-turbine",
    -- recipe = "蒸汽发电",
    craft_category = {"流体发电"},
    maxslot = 8,
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
    model = "glbs/turbine-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/turbine-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "generator", "fluidboxes","assembling","auto_set_recipe"},
    area = "3x5",
    rotate_on_build = true,
    io_shelf = false,
    assembling_icon = false,
    power = "6MW",
    priority = "secondary",
    sound = "building/steam-turbine",
    -- recipe = "蒸汽发电",
    craft_category = {"流体发电"},
    maxslot = 8,
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

prototype "轻型风力发电机" {
    model = "glbs/wind-turbine-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/wind-turbine-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "generator", "wind_turbine"},
    area = "3x3",
    power = "450kW",
    priority = "primary",
}

prototype "风力发电机I" {
    model = "glbs/wind-turbine-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/wind-turbine-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "generator", "wind_turbine"},
    area = "3x3",
    power = "1.2MW",
    priority = "primary",
}

prototype "太阳能板I" {
    model = "glbs/solar-panel-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/solar-panel-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "300kW",
    priority = "primary",
}

prototype "太阳能板II" {
    model = "glbs/solar-panel-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/solar-panel-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "450kW",
    priority = "primary",
}

prototype "太阳能板III" {
    model = "glbs/solar-panel-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/solar-panel-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "600kW",
    priority = "primary",
}

prototype "轻型太阳能板" {
    model = "glbs/solar-panel-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/solar-panel-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building","generator","solar_panel"},
    area = "3x3",
    power = "60kW",
    priority = "primary",
}

prototype "蓄电池I" {
    model = "glbs/accumulator-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/accumulator-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "accumulator"},
	power = "400kW",
	charge_power = "100kW",
	capacitance = "10MJ",
    area = "2x2",
    sound = "building/electricity",
}

prototype "蓄电池II" {
    model = "glbs/accumulator-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/accumulator-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "accumulator"},
	power = "600kW",
	charge_power = "200kW",
	capacitance = "30MJ",
    area = "2x2",
    sound = "building/electricity",
}

prototype "蓄电池III" {
    model = "glbs/accumulator-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/accumulator-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "accumulator"},
	power = "800kW",
	charge_power = "250kW",
	capacitance = "60MJ",
    area = "2x2",
    sound = "building/electricity",
}

prototype "核反应堆" {
    model = "glbs/wind-turbine-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/wind-turbine-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "generator"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
}

prototype "换热器I" {
    model = "glbs/boiler.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/boiler.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    power = "1.8MW",
    priority = "secondary",
    area = "3x2",
    io_shelf = false,
    rotate_on_build = true,
    craft_category = {"流体换热处理"},
    maxslot = 8,
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
    model = "glbs/pipe/I.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/I.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building"},
    area = "1x1",
}

prototype "锅炉I" {
    model = "glbs/boiler.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/boiler.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "assembling", "fluidboxes"},
    priority = "secondary",
    area = "3x2",
    rotate_on_build = true,
    io_shelf = false,
    craft_category = {"流体换热处理"},
    maxslot = 8,
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
    model = "glbs/geothermal-plant.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/geothermal-plant.glb|mesh.prefab config:s,1,3",
    check_coord = "mining",
    builder = "normal",
    type = {"building", "assembling", "fluidboxes","mining"},
    priority = "secondary",
    area = "5x5",
    rotate_on_build = true,
    io_shelf = false,
    sound = "building/geothermal",
    mining_category = {"地热处理"},
    maxslot = 8,
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
    model = "glbs/geothermal-plant.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/geothermal-plant.glb|mesh.prefab config:s,1,3",
    check_coord = "mining",
    builder = "normal",
    type = {"building", "assembling", "fluidboxes","mining"},
    priority = "secondary",
    area = "5x5",
    rotate_on_build = true,
    io_shelf = false,
    sound = "building/geothermal",
    mining_category = {"地热处理"},
    maxslot = 8,
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
    model = "glbs/geothermal-plant.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/geothermal-plant.glb|mesh.prefab config:s,1,3",
    check_coord = "mining",
    builder = "normal",
    type = {"building", "assembling", "fluidboxes","mining"},
    priority = "secondary",
    area = "5x5", 
    rotate_on_build = true,
    io_shelf = false,
    sound = "building/geothermal",
    mining_category = {"地热处理"},
    maxslot = 8,
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