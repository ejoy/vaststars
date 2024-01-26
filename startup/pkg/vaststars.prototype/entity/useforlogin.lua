local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "特殊组装机" {
    model = "glbs/mars-assembling-machine.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-assembling-machine.glb|mesh.prefab config:s,1,3",
    check_coord = {"exclusive"},
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "75%",
    power = "60kW",
    rotate_on_build = true,
    priority = "secondary",
    -- sound = "building/assembling-machine",
    maxslot = 8,
    ingredients_details = false,
    drone_height = 22,
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
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/electrolyzer-1.glb|mesh.prefab config:s,1,3",
    check_coord = {"exclusive"},
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "1MW",
    drain = "30kW",
    speed = "50%",
    -- sound = "building/electricity",
    rotate_on_build = true,
    io_shelf = false,
    priority = "secondary",
    craft_category = {"登录配方"},
    maxslot = 8,
    ingredients_details = false,
    drone_height = 22,
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
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/distillery-1.glb|mesh.prefab config:s,1,3",
    check_coord = {"exclusive"},
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "240kW",
    speed = "75%",
    rotate_on_build = true,
    priority = "secondary",
    -- sound = "building/hydro-plant",
    craft_category = {"登录配方"},
    maxslot = 8,
    ingredients_details = false,
    drone_height = 22,
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
    work_status = {work_start = true, idle_start = true, work = true, idle = true},
    icon = "mem:/pkg/vaststars.resources/glbs/chemical-plant-1.glb|mesh.prefab config:s,1,3,1.6",
    check_coord = {"exclusive"},
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    speed = "75%",
    rotate_on_build = true,
    -- sound = "building/hydro-plant",
    priority = "secondary",
    maxslot = 8,
    ingredients_details = false,
    drone_height = 22,
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
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/hydro-plant-1.glb|mesh.prefab config:s,1,3",
    check_coord = {"exclusive"},
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "5x5",
    power = "150kW",
    speed = "100%",
    -- sound = "building/hydro-plant",
    rotate_on_build = true,
    priority = "secondary",
    craft_category = {"登录配方"},
    maxslot = 8,
    ingredients_details = false,
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
    work_status = {work = true, work_start = true, idle_start = true},
    icon = "mem:/pkg/vaststars.resources/glbs/furnace-1.glb|mesh.prefab config:s,1,3",
    check_coord = {"exclusive"},
    builder = "normal",
    type = {"building", "assembling", "consumer","fluidboxes"},
    area = "3x3",
    speed = "75%",
    power = "300kW",
    ingredients_details = false,
    priority = "secondary",
    -- sound = "building/furnace",
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
    maxslot = 8,
}

prototype "特殊采矿机" {
    model = "glbs/miner-1.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/miner-1.glb|mesh.prefab config:s,1,3",
    check_coord = {"miner"},
    builder = "normal",
    type = {"building", "consumer", "assembling", "mining"},
    area = "3x3",
    drone_height = 42,
    assembling_icon = false,
    power = "150kW",
    ingredients_details = false,
    priority = "secondary",
    mining_area = "5x5",
    -- sound = "building/miner",
    craft_category = {"矿石开采"},
    speed = "200%",
    maxslot = 8,
    bulk_move = false,
}

prototype "特殊浮选器" {
    model = "glbs/flotation-cell-1.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/flotation-cell-1.glb|mesh.prefab config:s,1,3",
    check_coord = {"exclusive"},
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "200kW",
    drone_height = 22,
    rotate_on_build = true,
    drain = "6kW",
    speed = "100%",
    priority = "secondary",
    -- sound = "building/hydro-plant",
    craft_category = {"登录配方"},
    maxslot = 8,
    ingredients_details = false,
    fluidboxes = {
        input = {
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={0,0,"N"}},
                }
            },
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={0,0,"W"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={3,3,"S"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={3,3,"E"}},
                }
            },
        },
    },
}