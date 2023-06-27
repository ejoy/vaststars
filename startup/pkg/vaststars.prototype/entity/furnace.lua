local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "熔炼炉I" {
    model = "prefabs/furnace-1.prefab",
    icon = "textures/building_pic/small_pic_furnace.texture",
    background = "textures/build_background/pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"building", "assembling", "consumer","fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "300kW",
    priority = "secondary",
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
    model = "prefabs/furnace-1.prefab",
    icon = "textures/building_pic/small_pic_furnace.texture",
    background = "textures/build_background/pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling","fluidboxes"},
    area = "3x3",
    speed = "200%",
    power = "600kW",
    priority = "secondary",
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
    model = "prefabs/furnace-1.prefab",
    icon = "textures/building_pic/small_pic_furnace.texture",
    background = "textures/build_background/pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling","fluidboxes"},
    area = "3x3",
    speed = "400%",
    power = "1MW",
    priority = "secondary",
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
    model = "prefabs/crusher-1.prefab",
    icon = "textures/building_pic/small_pic_crusher.texture",
    background = "textures/build_background/pic_crusher.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling"},
    area = "3x3",
    power = "100kW",
    speed = "100%",
    drain = "3kW",
    priority = "secondary",
    allow_set_recipt = true,
    craft_category = {"矿石粉碎"},
    camera_distance = 65,
    maxslot = "8",
}

prototype "粉碎机II" {
    model = "prefabs/crusher-1.prefab",
    icon = "textures/building_pic/small_pic_crusher.texture",
    background = "textures/build_background/pic_crusher.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    speed = "200%",
    priority = "secondary",
    allow_set_recipt = true,
    craft_category = {"矿石粉碎"},
    camera_distance = 65,
    maxslot = "8",
}

prototype "粉碎机III" {
    model = "prefabs/crusher-1.prefab",
    icon = "textures/building_pic/small_pic_crusher.texture",
    background = "textures/build_background/pic_crusher.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling"},
    area = "3x3",
    power = "360kW",
    speed = "400%",
    priority = "secondary",
    allow_set_recipt = true,
    craft_category = {"矿石粉碎"},
    camera_distance = 65,
    maxslot = "8",
}

prototype "浮选器I" {
    model = "prefabs/flotation-cell-1.prefab",
    icon = "textures/building_pic/small_pic_flotation_cell.texture",
    background = "textures/build_background/pic_flotation_cell.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "200kW",
    drain = "6kW",
    speed = "100%",
    priority = "secondary",
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
    model = "prefabs/flotation-cell-1.prefab",
    icon = "textures/building_pic/small_pic_flotation_cell.texture",
    background = "textures/build_background/pic_flotation_cell.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "400kW",
    drain = "12kW",
    speed = "200%",
    priority = "secondary",
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
    model = "prefabs/flotation-cell-1.prefab",
    icon = "textures/building_pic/small_pic_flotation_cell.texture",
    background = "textures/build_background/pic_flotation_cell.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "4x4",
    power = "800kW",
    drain = "24kW",
    speed = "400%",
    priority = "secondary",
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