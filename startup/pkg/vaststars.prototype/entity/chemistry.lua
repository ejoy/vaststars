local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "化工厂I" {
    model = "glbs/chemical-plant-1.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_chemical_plant.texture",
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
    camera_distance = 75,
    craft_category = {"器件基础化工","流体基础化工"},
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

prototype "化工厂II" {
    model = "glbs/chemical-plant-1.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_chemical_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    power = "300kW",
    drain = "10kW",
    speed = "150%",
    rotate_on_build = true,
    sound = "building/hydro-plant",
    priority = "secondary",
    maxslot = 8,
    drone_height = 22,
    camera_distance = 75,
    craft_category = {"器件基础化工","流体基础化工"},
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

prototype "化工厂III" {
    model = "glbs/chemical-plant-1.glb|mesh.prefab",
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_chemical_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    power = "400kW",
    drain = "15kW",
    speed = "200%",
    rotate_on_build = true,
    sound = "building/hydro-plant",
    priority = "secondary",
    maxslot = 8,
    drone_height = 22,
    camera_distance = 75,
    craft_category = {"器件基础化工","流体基础化工"},
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

prototype "蒸馏厂I" {
    model = "glbs/distillery-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "240kW",
    speed = "75%",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/hydro-plant",
    craft_category = {"过滤"},
    maxslot = 8,
    drone_height = 22,
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

prototype "蒸馏厂II" {
    model = "glbs/distillery-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "450kW",
    speed = "200%",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/hydro-plant",
    craft_category = {"过滤"},
    maxslot = 8,
    drone_height = 22,
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

prototype "蒸馏厂III" {
    model = "glbs/distillery-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "900kW",
    speed = "400%",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/hydro-plant",
    craft_category = {"过滤"},
    maxslot = 8,
    drone_height = 22,
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


prototype "电解厂I" {
    model = "glbs/electrolyzer-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_electrolyzer.texture",
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
    craft_category = {"电解"},
    maxslot = 8,
    drone_height = 22,
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

prototype "电解厂II" {
    model = "glbs/electrolyzer-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_electrolyzer.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "3MW",
    drain = "100kW",
    speed = "150%",
    sound = "building/electricity",
    rotate_on_build = true,
    io_shelf = false,
    priority = "secondary",
    craft_category = {"电解"},
    maxslot = 8,
    drone_height = 22,
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

prototype "电解厂III" {
    model = "glbs/electrolyzer-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_electrolyzer.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "7.5MW",
    drain = "250kW",
    speed = "400%",
    sound = "building/electricity",
    rotate_on_build = true,
    io_shelf = false,
    priority = "secondary",
    craft_category = {"电解"},
    maxslot = 8,
    drone_height = 22,
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

prototype "水电站I" {
    model = "glbs/hydro-plant-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_hydro_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "150kW",
    speed = "100%",
    sound = "building/hydro-plant",
    rotate_on_build = true,
    priority = "secondary",
    craft_category = {"流体液体处理"},
    maxslot = 8,
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

prototype "水电站II" {
    model = "glbs/hydro-plant-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_hydro_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "300kW",
    speed = "200%",
    sound = "building/hydro-plant",
    rotate_on_build = true,
    priority = "secondary",
    craft_category = {"流体液体处理"},
    maxslot = 8,
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

prototype "水电站III" {
    model = "glbs/hydro-plant-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building-pic/small_pic_hydro_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "600kW",
    speed = "400%",
    sound = "building/hydro-plant",
    rotate_on_build = true,
    priority = "secondary",
    craft_category = {"流体液体处理"},
    maxslot = 8,
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