local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "组装机I" {
    model = "glbs/mars-assembling-machine.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-assembling-machine.glb|mesh.prefab config:s,3,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "75%",
    power = "60kW",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/assembling-machine",
    maxslot = 8,
    fluid_indicators = false, ---------不显示液口
    drone_height = 22,
    camera_distance = 62,
    craft_category = {"金属小型制造","物流小型制造","物流中型制造","物流大型制造","生产中型制造","生产大型制造","生产手工制造","器件小型制造","器件中型制造","建筑打印"},
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
    model = "glbs/mars-assembling-machine.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-assembling-machine.glb|mesh.prefab config:s,3,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "200%",
    power = "200kW",
    priority = "secondary",
    sound = "building/assembling-machine",
    maxslot = 8,
    fluid_indicators = false,
    drone_height = 22,
    camera_distance = 62,
    craft_category = {"金属小型制造","物流小型制造","物流中型制造","物流大型制造","生产中型制造","生产大型制造","生产手工制造","器件小型制造","器件中型制造","建筑打印"},
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

prototype "组装机III" {
    model = "glbs/mars-assembling-machine.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-assembling-machine.glb|mesh.prefab config:s,3,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "400%",
    power = "400kW",
    priority = "secondary",
    sound = "building/assembling-machine",
    maxslot = 8,
    fluid_indicators = false,
    drone_height = 22,
    camera_distance = 62,
    craft_category = {"金属小型制造","物流小型制造","物流中型制造","物流大型制造","生产中型制造","生产大型制造","生产手工制造","器件小型制造","器件中型制造","建筑打印"},
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
    model = "glbs/mars-assembling-machine.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-assembling-machine.glb|mesh.prefab config:s,3,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
    craft_category = {"金属锻造"},
    maxslot = 8,
    fluid_indicators = false,
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
