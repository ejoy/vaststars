local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "熔炼炉I" {
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
    craft_category = {"金属冶炼"},
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
    maxslot = "8",
}

prototype "熔炼炉II" {
    model = "glbs/furnace-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling","fluidboxes"},
    area = "3x3",
    speed = "200%",
    power = "600kW",
    priority = "secondary",
    sound = "building/furnace",
    allow_set_recipt = true,
    craft_category = {"金属冶炼"},
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
    maxslot = "8",
}

prototype "熔炼炉III" {
    model = "glbs/furnace-1.glb|mesh.prefab",
    model_status = {work = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling","fluidboxes"},
    area = "3x3",
    speed = "400%",
    power = "1MW",
    priority = "secondary",
    sound = "building/furnace",
    allow_set_recipt = true,
    craft_category = {"金属冶炼"},
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
    maxslot = "8",
}

prototype "粉碎机I" {
    model = "glbs/crusher-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_crusher.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling"},
    area = "3x3",
    power = "100kW",
    speed = "100%",
    drain = "3kW",
    drone_height = 22,
    priority = "secondary",
    sound = "building/crusher",
    allow_set_recipt = true,
    craft_category = {"矿石粉碎"},
    camera_distance = 65,
    maxslot = "8",
}

prototype "粉碎机II" {
    model = "glbs/crusher-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_crusher.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    drone_height = 22,
    speed = "200%",
    priority = "secondary",
    sound = "building/crusher",
    allow_set_recipt = true,
    craft_category = {"矿石粉碎"},
    camera_distance = 65,
    maxslot = "8",
}

prototype "粉碎机III" {
    model = "glbs/crusher-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_crusher.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling"},
    area = "3x3",
    power = "360kW",
    drone_height = 22,
    speed = "400%",
    priority = "secondary",
    sound = "building/crusher",
    allow_set_recipt = true,
    craft_category = {"矿石粉碎"},
    camera_distance = 65,
    maxslot = "8",
}

prototype "浮选器I" {
    model = "glbs/flotation-cell-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_flotation_cell.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "200kW",
    drone_height = 22,
    drain = "6kW",
    speed = "100%",
    priority = "secondary",
    sound = "building/hydro-plant",
    allow_set_recipt = true,
    craft_category = {"矿石浮选"},
    camera_distance = 40,
    maxslot = "8",
    fluidboxes = {
        input = {
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={1,0,"N"}},
                }
            },
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={2,3,"S"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,2,"W"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={3,1,"E"}},
                }
            },
        },
    },
}

prototype "浮选器II" {
    model = "glbs/flotation-cell-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_flotation_cell.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "400kW",
    drone_height = 22,
    drain = "12kW",
    speed = "200%",
    priority = "secondary",
    sound = "building/hydro-plant",
    allow_set_recipt = true,
    craft_category = {"矿石浮选"},
    camera_distance = 40,
    maxslot = "8",
    fluidboxes = {
        input = {
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={1,0,"N"}},
                }
            },
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={2,3,"S"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,2,"W"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={3,1,"E"}},
                }
            },
        },
    },
}

prototype "浮选器III" {
    model = "glbs/flotation-cell-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_flotation_cell.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "800kW",
    drone_height = 22,
    drain = "24kW",
    speed = "400%",
    priority = "secondary",
    sound = "building/hydro-plant",
    allow_set_recipt = true,
    craft_category = {"矿石浮选"},
    camera_distance = 40,
    maxslot = "8",
    fluidboxes = {
        input = {
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={1,0,"N"}},
                }
            },
            {
                capacity = 3000,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={2,3,"S"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,2,"W"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={3,1,"E"}},
                }
            },
        },
    },
}