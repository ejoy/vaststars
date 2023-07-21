local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "液罐I" {
    model = "prefabs/gas-tank-1.prefab",
    icon = "textures/building_pic/small_pic_gas_tank.texture",
    construct_detector = {"exclusive"},
    storage_tank = true,
    building_menu = false,
    type = {"building", "fluidbox"},
    area = "3x3",
    camera_distance = 72,
    fluidbox = {
        capacity = 15000,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={1,0,"N"}},
            {type="input-output", position={2,1,"E"}},
            {type="input-output", position={1,2,"S"}},
            {type="input-output", position={0,1,"W"}},
        }
    }
}

prototype "液罐II" {
    model = "prefabs/gas-tank-1.prefab",
    icon = "textures/building_pic/small_pic_gas_tank.texture",
    construct_detector = {"exclusive"},
    storage_tank = true,
    building_menu = false,
    type = {"building", "fluidbox"},
    area = "3x3",
    camera_distance = 72,
    fluidbox = {
        capacity = 30000,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={1,0,"N"}},
            {type="input-output", position={2,1,"E"}},
            {type="input-output", position={1,2,"S"}},
            {type="input-output", position={0,1,"W"}},
        }
    }
}

prototype "液罐III" {
    model = "prefabs/gas-tank-1.prefab",
    icon = "textures/building_pic/small_pic_gas_tank.texture",
    construct_detector = {"exclusive"},
    storage_tank = true,
    building_menu = false,
    type = {"building", "fluidbox"},
    area = "3x3",
    camera_distance = 72,
    fluidbox = {
        capacity = 60000,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={1,0,"N"}},
            {type="input-output", position={2,1,"E"}},
            {type="input-output", position={1,2,"S"}},
            {type="input-output", position={0,1,"W"}},
        }
    }
}

prototype "气罐I" {
    model = "prefabs/gas-tank-1.prefab",
    icon = "textures/building_pic/small_pic_tank.texture",
    construct_detector = {"exclusive"},
    storage_tank = true,
    building_menu = false,
    type = {"building", "fluidbox"},
    area = "3x3",
    camera_distance = 72,
    fluidbox = {
        capacity = 15000,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={1,0,"N"}},
            {type="input-output", position={2,1,"E"}},
            {type="input-output", position={1,2,"S"}},
            {type="input-output", position={0,1,"W"}},
        }
    }
}

prototype "地下水挖掘机I" {
    model = "prefabs/mars-pumpjack.prefab",
    icon = "textures/building_pic/small_pic_offshore.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    rotate_on_build = true,
    power = "50kW",
    speed = "100%",
    assembling_icon = false,
    priority = "secondary",
    recipe = "离岸抽水",
    building_menu = false,
    io_shelf = false,
    building_base = false,
    maxslot = "8",
    camera_distance = 72,
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 1200,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,1,"E"}},
                }
            }
        }
    }
}

prototype "地下水挖掘机II" {
    model = "prefabs/mars-pumpjack.prefab",
    icon = "textures/building_pic/small_pic_offshore.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    rotate_on_build = true,
    power = "200kW",
    speed = "400%",
    assembling_icon = false,
    priority = "secondary",
    recipe = "离岸抽水",
    building_menu = false,
    io_shelf = false,
    building_base = false,
    maxslot = "8",
    camera_distance = 72,
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 1200,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,1,"E"}},
                }
            }
        }
    }
}

prototype "核子挖掘机" {
    model = "prefabs/mars-pumpjack.prefab",
    icon = "textures/building_pic/small_pic_offshore.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    rotate_on_build = true,
    power = "2MW",
    assembling_icon = false,
    priority = "secondary",
    recipe = "离岸抽水",
    building_menu = false,
    io_shelf = false,
    building_base = false,
    maxslot = "8",
    camera_distance = 72,
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 1200,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={2,1,"E"}},
                }
            }
        }
    }
}

prototype "压力泵I" {
    model = "prefabs/pump-1.prefab",
    icon = "textures/building_pic/small_pic_pump.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "fluidbox", "pump"},
    area = "1x2",
    rotate_on_build = true,
    building_menu = false,
    power = "10kW",
    drain = "300W",
    camera_distance = 100,
    priority = "secondary",
    fluidbox = {
        capacity = 500,
        height = 300,
        base_level = 0,
        pumping_speed = 1200,
        connections = {
            {type="output", position={0,0,"N"}},
            {type="input", position={0,1,"S"}},
        }
    }
}

prototype "烟囱I" {
    model = "prefabs/chimney-1.prefab",
    icon = "textures/building_pic/small_pic_pump.texture",
    construct_detector = {"exclusive"},
    type = {"building", "fluidbox", "chimney"},
    area = "2x2",
    rotate_on_build = true,
    craft_category = {"流体气体排泄"},
    speed = "100%",
    camera_distance = 70,
    building_menu = false,
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={1,1,"S"}},
        }
    }
}

prototype "烟囱II" {
    model = "prefabs/chimney-1.prefab",
    icon = "textures/building_pic/small_pic_pump.texture",
    construct_detector = {"exclusive"},
    type = {"building", "fluidbox", "chimney"},
    area = "2x2",
    rotate_on_build = true,
    craft_category = {"流体气体排泄"},
    speed = "500%",
    camera_distance = 70,
    building_menu = false,
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={1,1,"S"}},
        }
    }
}

prototype "排水口I" {
    model = "prefabs/mars-outfall.prefab",
    icon = "textures/building_pic/small_pic_mars_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "fluidbox", "chimney"},
    area = "3x3",
    rotate_on_build = true,
    craft_category = {"流体液体排泄"},
    speed = "100%",
    building_base = false,
    camera_distance = 89,
    building_menu = false,
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={1,2,"S"}},
        }
    }
}

prototype "排水口II" {
    model = "prefabs/mars-outfall.prefab",
    icon = "textures/building_pic/small_pic_mars_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "fluidbox", "chimney"},
    area = "3x3",
    rotate_on_build = true,
    craft_category = {"流体液体排泄"},
    speed = "500%",
    building_base = false,
    camera_distance = 89,
    building_menu = false,
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={1,2,"S"}},
        }
    }
}

prototype "空气过滤器I" {
    model = "prefabs/chimney-1.prefab",
    icon = "textures/building_pic/small_pic_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "2x2",
    rotate_on_build = true,
    io_shelf = false,
    power = "50kW",
    drain = "1.5kW",
    speed = "100%",
    priority = "secondary",
    recipe = "空气过滤",
    maxslot = "8",
    camera_distance = 100,
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 100,
                height = 200,
                base_level = 150,
                connections = {
                    {type="output", position={1,1,"S"}},
                }
            }
        },
    }
}

prototype "空气过滤器II" {
    model = "prefabs/chimney-1.prefab",
    icon = "textures/building_pic/small_pic_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "2x2",
    rotate_on_build = true,
    io_shelf = false,
    power = "150kW",
    speed = "300%",
    priority = "secondary",
    recipe = "空气过滤",
    maxslot = "8",
    camera_distance = 100,
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 100,
                height = 200,
                base_level = 150,
                connections = {
                    {type="output", position={1,1,"S"}},
                }
            }
        },
    }
}

prototype "空气过滤器III" {
    model = "prefabs/chimney-1.prefab",
    icon = "textures/building_pic/small_pic_outfall.texture",
    construct_detector = {"exclusive"},
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "2x2",
    rotate_on_build = true,
    io_shelf = false,
    power = "500kW",
    speed = "800%",
    priority = "secondary",
    recipe = "空气过滤",
    maxslot = "8",
    camera_distance = 100,
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 100,
                height = 200,
                base_level = 150,
                connections = {
                    {type="output", position={1,1,"S"}},
                }
            }
        },
    }
}

prototype "管道1-I型" {
    model = "prefabs/pipe/pipe_I.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    building_category = 1,
    camera_distance = 30,
    building_direction = {"N", "E"},
    building_menu = false,
    type = {"building","fluidbox","pipe"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"S"}},
        },
    },
    building_base = false,
}

prototype "管道1-L型" {
    model = "prefabs/pipe/pipe_L.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    building_category = 1,
    building_direction = {"N", "E", "S", "W"},
    building_menu = false,
    type = {"building","fluidbox","pipe"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
        },
    },
    building_base = false,
}

prototype "管道1-T型" {
    model = "prefabs/pipe/pipe_T.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    building_category = 1,
    building_direction = {"N", "E", "S", "W"},
    building_menu = false,
    type = {"building","fluidbox","pipe"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        },
    },
    building_base = false,
}

prototype "管道1-X型" {
    show_prototype_name = "管道I",
    model = "prefabs/pipe/pipe_X.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    building_category = 1,
    building_direction = {"N"},
    building_menu = false,
    type = {"building","fluidbox","pipe"},
    area = "1x1",
    camera_distance = 30,
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        },
    },
    building_base = false,
}

prototype "管道1-O型" {
    model = "prefabs/pipe/pipe_O.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    building_category = 1,
    building_direction = {"N"},
    building_menu = false,
    type = {"building","fluidbox","pipe"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
        },
    },
    building_base = false,
}

prototype "管道1-U型" {
    model = "prefabs/pipe/pipe_U.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    building_category = 1,
    building_direction = {"N", "E", "S", "W"},
    building_menu = false,
    type = {"building","fluidbox","pipe"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
        },
    },
    building_base = false,
}

prototype "地下管1-JU型" {
    model = "prefabs/pipe/pipe_JU.prefab",
    icon = "textures/construct/underground-pipe1.texture",
    construct_detector = {"exclusive"},
    building_menu = false,
    building_category = 2,
    building_direction = {"N", "E", "S", "W"},
    type = {"building","fluidbox","pipe_to_ground"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}, ground = 10},
        },
    },
    building_base = false,
}

prototype "地下管1-JI型" {
    show_prototype_name = "地下管I",
    model = "prefabs/pipe/pipe_JI.prefab",
    icon = "textures/construct/underground-pipe1.texture",
    construct_detector = {"exclusive"},
    building_menu = false,
    building_category = 2,
    building_direction = {"N", "E", "S", "W"},
    type = {"building","fluidbox","pipe_to_ground"},
    area = "1x1",
    camera_distance = 25,
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"N"}, ground = 10},
        },
    },
    building_base = false,
}

prototype "地下管2-JU型" {
    model = "prefabs/pipe/pipe_JU.prefab",
    icon = "textures/construct/underground-pipe1.texture",
    construct_detector = {"exclusive"},
    building_menu = false,
    building_category = 3,
    building_direction = {"N", "E", "S", "W"},
    type = {"building","fluidbox","pipe_to_ground"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}, ground = 14},
        },
    },
    building_base = false,
}

prototype "地下管2-JI型" {
    show_prototype_name = "地下管II",
    model = "prefabs/pipe/pipe_JI.prefab",
    icon = "textures/construct/underground-pipe1.texture",
    construct_detector = {"exclusive"},
    building_menu = false,
    building_category = 3,
    building_direction = {"N", "E", "S", "W"},
    type = {"building","fluidbox","pipe_to_ground"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"N"}, ground = 14},
        },
    },
    building_base = false,
}