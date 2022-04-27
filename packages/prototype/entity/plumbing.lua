local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "液罐1" {
    model = "prefabs/storage-tank-1.prefab",
    icon = "textures/construct/tank1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "fluidbox"},
    area = "3x3",
    fluidbox = {
        capacity = 15000,
        height = 200,
        base_level = 0,
        connections = {
            {type="input-output", position={1,0,"N"}},
            {type="input-output", position={2,1,"E"}},
            {type="input-output", position={1,2,"S"}},
            {type="input-output", position={0,1,"W"}},
        }
    }
}

prototype "抽水泵" {
    model = "prefabs/offshore-pump-1.prefab",
    icon = "textures/construct/offshore-pump.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer", "assembling", "fluidboxes"},
    area = "1x2",
    power = "6kW",
    priority = "secondary",
    recipe = "离岸抽水",
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 1200,
                height = 100,
                base_level = 150,
                connections = {
                    {type="output", position={0,1,"S"}},
                }
            }
        }
    }
}

prototype "压力泵1" {
    model = "prefabs/pump-1.prefab",
    icon = "textures/construct/pump1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer", "fluidbox", "pump"},
    area = "1x2",
    power = "10kW",
    drain = "300W",
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

prototype "烟囱1" {
    model = "prefabs/chimney-1.prefab",
    icon = "textures/construct/chimney2.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "fluidbox"},
    area = "2x2",
    craft_category = {"流体气体排泄"},
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={0,0,"N"}},
        }
    }
}

prototype "排水口1" {
    model = "prefabs/outfall-1.prefab",
    icon = "textures/construct/outfall.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "fluidbox"},
    area = "3x3",
    craft_category = {"流体液体排泄"},
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={1,0,"N"}},
        }
    }
}

prototype "空气过滤器1" {
    model = "prefabs/chimney-1.prefab",
    icon = "textures/construct/air-filter1.texture",
    construct_detector = {"exclusive"},
    type ={"entity", "consumer","assembling","fluidboxes"},
    area = "2x2",
    power = "50kW",
    drain = "1.5kW",
    priority = "secondary",
    recipe = "空气过滤",
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 1000,
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
    pipe = true,
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"S"}},
        }
    }
}

prototype "管道1-J型" {
    model = "prefabs/pipe/pipe_J.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    pipe = true,
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"S"}},
        }
    }
}

prototype "管道1-L型" {
    model = "prefabs/pipe/pipe_L.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    pipe = true,
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
        }
    }
}

prototype "管道1-T型" {
    model = "prefabs/pipe/pipe_T.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    pipe = true,
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        }
    }
}

prototype "管道1-X型" {
    model = "prefabs/pipe/pipe_X.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    pipe = true,
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={0,0,"E"}},
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"W"}},
        }
    }
}

prototype "管道1-O型" {
    model = "prefabs/pipe/pipe_O.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    pipe = true,
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
        }
    }
}

prototype "管道1-U型" {
    model = "prefabs/pipe/pipe_U.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    pipe = true,
    type = {"entity","fluidbox"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
        }
    }
}

prototype "地下管1" {
    model = "prefabs/pipe/pipe_J.prefab",
    icon = "textures/construct/pipe.texture",
    construct_detector = {"exclusive"},
    pipe = true,
    type ={"entity","pipe-to-ground","fluidbox"},
    area = "1x1",
    max_distance = 10,
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"S"}},
        }
    }
}