local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "组装机I" {
    model = "prefabs/mars-assembling-machine.prefab",
    icon = "textures/building_pic/small_pic_mars_assembling_machine.texture",
    background = "textures/build_background/pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "60kW",
    priority = "secondary",
    maxslot = "8",
    craft_category = {"金属小型制造","物流小型制造","物流中型制造","物流大型制造","生产中型制造","生产大型制造","生产手工制造","器件小型制造","器件中型制造","框架打印"},
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

prototype "组装机II" {
    model = "prefabs/mars-assembling-machine.prefab",
    icon = "textures/building_pic/small_pic_mars_assembling_machine.texture",
    background = "textures/build_background/pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "150%",
    power = "150kW",
    priority = "secondary",
    maxslot = "8",
    craft_category = {"金属小型制造","物流小型制造","物流中型制造","物流大型制造","生产中型制造","生产大型制造","生产手工制造","器件小型制造","器件中型制造","框架打印"},
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
    model = "prefabs/mars-assembling-machine.prefab",
    icon = "textures/building_pic/small_pic_assemble.texture",
    background = "textures/build_background/pic_assemble.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
    craft_category = {"金属锻造"},
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
