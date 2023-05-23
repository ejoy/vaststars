local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "化工厂I" {
    model = "prefabs/chemical-plant-1.prefab",
    icon = "textures/building_pic/small_pic_chemical_plant.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    rotate_on_build = true,
    priority = "secondary",
    maxslot = "8",
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
    model = "prefabs/distillery-1.prefab",
    icon = "textures/building_pic/small_pic_distillery.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "240kW",
    rotate_on_build = true,
    priority = "secondary",
    craft_category = {"过滤"},
    maxslot = "8",
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
    model = "prefabs/electrolyzer-1.prefab",
    icon = "textures/building_pic/small_pic_electrolyzer.texture",
    background = "textures/build_background/pic_electrolyzer.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "1MW",
    drain = "30kW",
    rotate_on_build = true,
    io_shelf = false,
    priority = "secondary",
    craft_category = {"电解"},
    maxslot = "8",
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
    model = "prefabs/hydro-plant-1.prefab",
    icon = "textures/building_pic/small_pic_hydro_plant.texture",
    background = "textures/build_background/pic_hydro_plant.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "150kW",
    rotate_on_build = true,
    priority = "secondary",
    craft_category = {"流体液体处理"},
    maxslot = "8",
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