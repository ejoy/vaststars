local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "熔炼炉I" {
    model = "prefabs/furnace-1.prefab",
    icon = "textures/building_pic/small_pic_furnace.texture",
    background = "textures/build_background/pic_furnace.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "50%",
    power = "75kW",
    priority = "secondary",
    group = {"加工"},
    craft_category = {"金属冶炼"},
    fluidboxes = {
        input = {
        },
        output = {
        },
    }
}

prototype "粉碎机I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/building_pic/small_pic_furnace.texture",
    background = "textures/build_background/pic_furnace.texture",
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
    model = "prefabs/distillery-1.prefab",
    icon = "textures/building_pic/small_pic_distillery.texture",
    background = "textures/build_background/pic_distillery.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer"},
    area = "5x5",
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
                    {type="input", position={3,0,"N"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={1,4,"S"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={3,4,"S"}},
                }
            },
        },
    },
}