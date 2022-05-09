local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "组装机I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/construct/assembler.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "assembling", "consumer", "fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
    group = {"加工"},
    craft_category = {"物流小型制造","物流中型制造","物流大型制造","生产中型制造","生产大型制造","生产手工制造","器件小型制造","器件中型制造"},
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
    }
}

prototype "铸造厂I" {
    model = "prefabs/assembling-1.prefab",
    icon = "textures/construct/assembler.texture",
    construct_detector = {"exclusive"},
    type = {"entity", "assembling", "consumer", "fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
    group = {"加工"},
    craft_category = {"金属锻造"},
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
    }
}