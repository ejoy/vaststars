local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "熔炼炉I" {
    model = "prefabs/furnace-1.prefab",
    icon = "textures/building_pic/small_pic_furnace.texture",
    background = "textures/build_background/pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "25%",
    power = "75kW",
    priority = "secondary",
    group = {"加工"},
    craft_category = {"金属冶炼"},
    fluidboxes = {
        input = {
        },
        output = {
        },
    },
    crossing = {
        connections = {
            {type="assembling", position={1,2,"S"}, roadside = true},
        },
    }
}

prototype "熔炼炉II" {
    model = "prefabs/furnace-1.prefab",
    icon = "textures/building_pic/small_pic_furnace.texture",
    background = "textures/build_background/pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "50%",
    power = "150kW",
    priority = "secondary",
    group = {"加工"},
    craft_category = {"金属冶炼"},
    fluidboxes = {
        input = {
        },
        output = {
        },
    },
    crossing = {
        connections = {
            {type="assembling", position={1,2,"S"}, roadside = true},
        },
    }
}

prototype "粉碎机I" {
    model = "prefabs/crusher-1.prefab",
    icon = "textures/building_pic/small_pic_crusher.texture",
    background = "textures/build_background/pic_crusher.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer"},
    area = "3x3",
    power = "100kW",
    drain = "3kW",
    priority = "secondary",
    group = {"加工"},
    craft_category = {"矿石粉碎"},
    fluidboxes = {
        input = {
        },
        output = {
        },
    }
}

prototype "浮选器I" {
    model = "prefabs/flotation-cell-1.prefab",
    icon = "textures/building_pic/small_pic_flotation_cell.texture",
    background = "textures/build_background/pic_flotation_cell.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer"},
    area = "4x4",
    power = "200kW",
    drain = "6kW",
    priority = "secondary",
    group = {"加工"},
    craft_category = {"矿石浮选"},
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