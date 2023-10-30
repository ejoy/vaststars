local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "特殊组装机" {
    model = "glbs/mars-assembling-machine.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "75%",
    power = "60kW",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/assembling-machine",
    maxslot = 8,
    drone_height = 22,
    allow_set_recipt = true,
    camera_distance = 62,
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

prototype "特殊科研中心" {
    model = "glbs/lab-1.glb|mesh.prefab",
    model_status = {work = true, low_power = true},
    icon = "/pkg/vaststars.resources/ui/textures/building_pic/small_pic_mars_assembling_machine.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    speed = "75%",
    power = "60kW",
    rotate_on_build = true,
    priority = "secondary",
    sound = "building/assembling-machine",
    maxslot = 8,
    drone_height = 22,
    allow_set_recipt = true,
    camera_distance = 62,
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

