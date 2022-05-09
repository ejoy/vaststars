local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "化工厂I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/construct/chemistry1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer","fluidboxes"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    priority = "secondary",
    group = {"化工"},
    craft_category = {"化工小型制造","化工中型制造","化工大型制造","器件基础化工","流体基础化工"},
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
        },
    }
}

prototype "蒸馏厂I" {
    model = "prefabs/distillery-1.prefab",
    icon = "textures/construct/distillery.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer", "fluidboxes"},
    area = "5x5",
    power = "240kW",
    priority = "secondary",
    craft_category = {"过滤"},
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
                    {type="output", position={2,4,"S"}},
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
        },
    }
}

prototype "电解厂I" {
    model = "prefabs/distillery-1.prefab",
    icon = "textures/construct/electrolysis1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer", "fluidboxes"},
    area = "5x5",
    power = "1MW",
    drain = "30kW",
    priority = "secondary",
    craft_category = {"电解"},
    fluidboxes = {
        input = {
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
                    {type="output", position={0,4,"S"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,4,"S"}},
                }
            },
            {
                capacity = 500,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={4,4,"S"}},
                }
            },
        },
    }
}

prototype "水电站I" {
    model = "prefabs/distillery-1.prefab",
    icon = "textures/construct/hydroplant.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "assembling", "consumer", "fluidboxes"},
    area = "5x5",
    power = "150kW",
    priority = "secondary",
    craft_category = {"流体液体处理"},
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