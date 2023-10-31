local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "特殊组装机" {
    model = "glbs/mars-assembling-machine.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "75%",
    power = "60kW",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/assembling-machine",
    maxslot = 8,
    drone_height = 22,
    allow_set_recipt = true,
    camera_distance = 62,
    craft_category = {"登录配方"},
    fluidboxes = {
        input = {
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={1,0,"N"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 100,
                connections = {
                    {type="output", position={1,2,"S"}},
                }
            },
        },
    },
}

prototype "特殊电解厂" {
    model = "glbs/electrolyzer-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_electrolyzer.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "1MW",
    drain = "30kW",
    speed = "50%",
    sound = "building/electricity",
    rotate_on_build = true,
    io_shelf = false,
    priority = "secondary",
    craft_category = {"登录配方"},
    maxslot = 8,
    drone_height = 22,
    allow_set_recipt = true,
    camera_distance = 100,
    fluidboxes = {
        input = {
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={3,3,"S"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={3,0,"N"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,0,"N"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,3,"S"}},
                }
            },
        },
    }
}

prototype "特殊蒸馏厂" {
    model = "glbs/distillery-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "240kW",
    speed = "75%",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/hydro-plant",
    craft_category = {"登录配方"},
    maxslot = 8,
    drone_height = 22,
    allow_set_recipt = true,
    camera_distance = 100,
    fluidboxes = {
        input = {
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={1,0,"N"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={3,0,"N"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 100,
                connections = {
                    {type="output", position={0,4,"S"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 100,
                connections = {
                    {type="output", position={4,4,"S"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 100,
                connections = {
                    {type="output", position={2,4,"S"}},
                }
            },

        },
    }
}

prototype "特殊化工厂" {
    model = "glbs/chemical-plant-1.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_chemical_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    speed = "75%",
    rotate_on_build = true,
    sound = "building/hydro-plant",
    priority = "secondary",
    maxslot = 8,
    drone_height = 22,
    allow_set_recipt = true,
    camera_distance = 75,
    craft_category = {"登录配方"},
    fluidboxes = {
        input = {
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={0,0,"N"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={2,0,"N"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,2,"S"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,2,"S"}},
                }
            },
            {
                capacity = 500,
                height = 150,
                base_level = -100,
                connections = {
                    {type="input-output", position={0,1,"W"}},
                    {type="input-output", position={2,1,"E"}},
                }
            },
        },
    }
}

prototype "特殊水电站" {
    model = "glbs/hydro-plant-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_hydro_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "150kW",
    speed = "100%",
    sound = "building/hydro-plant",
    rotate_on_build = true,
    priority = "secondary",
    craft_category = {"登录配方"},
    maxslot = 8,
    allow_set_recipt = true,
    camera_distance = 100,
    fluidboxes = {
        input = {
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={4,1,"E"}},
                }
            },
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={4,3,"E"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,1,"W"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,3,"W"}},
                }
            },
        },
    },
}

prototype "特殊熔炼炉" {
    model = "glbs/furnace-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "consumer","fluidboxes"},
    area = "3x3",
    speed = "75%",
    power = "300kW",
    priority = "secondary",
    sound = "building/furnace",
    allow_set_recipt = true,
    craft_category = {"登录配方"},
    camera_distance = 62,
    fluidboxes = {
        input = {
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={1,0,"N"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 100,
                connections = {
                    {type="output", position={1,2,"S"}},
                }
            },
        },
    },
    maxslot = 8,
}