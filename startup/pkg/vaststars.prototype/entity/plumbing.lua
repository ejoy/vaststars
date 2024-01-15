local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "液罐I" {
    model = "glbs/storage-tank-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/storage-tank-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    storage_tank = true,
    type = {"building", "fluidbox"},
    area = "3x3",
    -- sound = "building/hydro-plant",
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
    model = "glbs/storage-tank-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/storage-tank-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    storage_tank = true,
    type = {"building", "fluidbox"},
    area = "3x3",
    -- sound = "building/hydro-plant",
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
    model = "glbs/storage-tank-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/storage-tank-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    storage_tank = true,
    type = {"building", "fluidbox"},
    area = "3x3",
    -- sound = "building/hydro-plant",
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
    model = "glbs/storage-tank-1.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/storage-tank-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    storage_tank = true,
    type = {"building", "fluidbox"},
    area = "3x3",
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
    model = "glbs/mars-pumpjack.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-pumpjack.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    rotate_on_build = true,
    power = "50kW",
    speed = "100%",
    -- sound = "building/hydro-plant",
    assembling_icon = false,
    priority = "secondary",
    recipe = "离岸抽水",
    io_shelf = false,
    maxslot = 8,
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
    model = "glbs/mars-pumpjack.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-pumpjack.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    rotate_on_build = true,
    power = "200kW",
    speed = "400%",
    -- sound = "building/hydro-plant",
    assembling_icon = false,
    priority = "secondary",
    recipe = "离岸抽水",
    io_shelf = false,
    maxslot = 8,
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
    model = "glbs/mars-pumpjack.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-pumpjack.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "3x3",
    rotate_on_build = true,
    power = "2MW",
    assembling_icon = false,
    priority = "secondary",
    recipe = "离岸抽水",
    io_shelf = false,
    maxslot = 8,
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
    model = "glbs/pump-1.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/pump-1.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "fluidbox", "pump"},
    area = "1x2",
    rotate_on_build = true,
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

prototype "烟囱I" {
    model = "glbs/chimney-1.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/chimney-1.glb|mesh.prefab config:s,1,3",
    check_coord = "chimney",
    builder = "normal",
    type = {"building", "fluidbox", "chimney", "auto_set_recipe"},
    area = "2x2",
    rotate_on_build = true,
    craft_category = {"流体气体排泄"},
    speed = "100%",
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = -10,
        connections = {
            {type="input", position={1,1,"S"}},
        }
    }
}

prototype "烟囱II" {
    model = "glbs/chimney-1.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/chimney-1.glb|mesh.prefab config:s,1,3",
    check_coord = "chimney",
    builder = "normal",
    type = {"building", "fluidbox", "chimney", "auto_set_recipe"},
    area = "2x2",
    rotate_on_build = true,
    craft_category = {"流体气体排泄"},
    speed = "500%",
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = -10,
        connections = {
            {type="input", position={1,1,"S"}},
        }
    }
}

prototype "排水口I" {
    model = "glbs/mars-outfall.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-outfall.glb|mesh.prefab config:s,1,3",
    check_coord = "outfall",
    builder = "normal",
    type = {"building", "fluidbox", "chimney", "auto_set_recipe"},
    area = "3x3",
    rotate_on_build = true,
    craft_category = {"流体液体排泄"},
    speed = "100%",
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = -10,
        connections = {
            {type="input", position={1,2,"S"}},
        }
    }
}

prototype "排水口II" {
    model = "glbs/mars-outfall.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/mars-outfall.glb|mesh.prefab config:s,1,3",
    check_coord = "outfall",
    builder = "normal",
    type = {"building", "fluidbox", "chimney", "auto_set_recipe"},
    area = "3x3",
    rotate_on_build = true,
    craft_category = {"流体液体排泄"},
    speed = "500%",
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = -10,
        connections = {
            {type="input", position={1,2,"S"}},
        }
    }
}

prototype "空气过滤器I" {
    model = "glbs/air-filter.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/air-filter.glb|mesh.prefab config:s,1,3,1.2",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "2x2",
    rotate_on_build = true,
    io_shelf = false,
    power = "50kW",
    drain = "1.5kW",
    speed = "100%",
    priority = "secondary",
    recipe = "空气过滤",
    maxslot = 8,
    -- sound = "building/air-filter",
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 200,
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
    model = "glbs/air-filter.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/air-filter.glb|mesh.prefab config:s,1,3,1.2",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "2x2",
    rotate_on_build = true,
    io_shelf = false,
    power = "150kW",
    speed = "300%",
    priority = "secondary",
    recipe = "空气过滤",
    maxslot = 8,
    -- sound = "building/air-filter",
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 200,
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
    model = "glbs/air-filter.glb|mesh.prefab",
    work_status = {work = true},
    icon = "mem:/pkg/vaststars.resources/glbs/air-filter.glb|mesh.prefab config:s,1,3,1.2",
    check_coord = "exclusive",
    builder = "normal",
    type = {"building", "consumer", "assembling", "fluidboxes"},
    area = "2x2",
    rotate_on_build = true,
    io_shelf = false,
    power = "500kW",
    speed = "800%",
    priority = "secondary",
    recipe = "空气过滤",
    maxslot = 8,
    -- sound = "building/air-filter",
    fluidboxes = {
        input = {},
        output = {
            {
                capacity = 200,
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
    building_category = 1,
    display_name = "管道I",
    item = "管道1-X型",
    model = "glbs/pipe/I.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/I.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "pipe",
    building_direction = {"N", "E"},
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
}

prototype "管道1-L型" {
    building_category = 1,
    display_name = "管道I",
    item = "管道1-X型",
    model = "glbs/pipe/L.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/L.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "pipe",
    building_direction = {"N", "E", "S", "W"},
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
}

prototype "管道1-T型" {
    building_category = 1,
    display_name = "管道I",
    item = "管道1-X型",
    model = "glbs/pipe/T.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/T.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "pipe",
    building_direction = {"N", "E", "S", "W"},
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
}

prototype "管道1-X型" {
    building_category = 1,
    display_name = "管道I",
    item = "管道1-X型",
    model = "glbs/pipe/X.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/X.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "pipe",
    building_direction = {"N"},
    type = {"building","fluidbox","pipe"},
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
        },
    },
}

prototype "管道1-O型" {
    building_category = 1,
    display_name = "管道I",
    item = "管道1-X型",
    model = "glbs/pipe/O.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/O.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "pipe",
    building_direction = {"N"},
    type = {"building","fluidbox","pipe"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
        },
    },
}

prototype "管道1-U型" {
    building_category = 1,
    display_name = "管道I",
    item = "管道1-X型",
    model = "glbs/pipe/U.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/U.glb|mesh.prefab config:s,1,3",
    check_coord = "exclusive",
    builder = "pipe",
    building_direction = {"N", "E", "S", "W"},
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
}

prototype "地下管1-JU型" {
    building_category = 2,
    display_name = "地下管I",
    item = "地下管1-JI型",
    model = "glbs/pipe/JU.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/JU.glb|mesh.prefab config:s,1,3",
    check_coord = "pipe_to_ground",
    builder = "pipe_to_ground",
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
}

prototype "地下管1-JI型" {
    building_category = 2,
    display_name = "地下管I",
    item = "地下管1-JI型",
    model = "glbs/pipe/JI.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/JI.glb|mesh.prefab config:s,1,3",
    check_coord = "pipe_to_ground",
    builder = "pipe_to_ground",
    building_direction = {"N", "E", "S", "W"},
    type = {"building","fluidbox","pipe_to_ground"},
    area = "1x1",
    fluidbox = {
        capacity = 100,
        height = 100,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"S"}},
            {type="input-output", position={0,0,"N"}, ground = 10},
        },
    },
}

prototype "地下管2-JU型" {
    building_category = 3,
    display_name = "地下管II",
    item = "地下管2-JI型",
    model = "glbs/pipe/JU.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/JU.glb|mesh.prefab config:s,1,3",
    check_coord = "pipe_to_ground",
    builder = "pipe_to_ground",
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
}

prototype "地下管2-JI型" {
    building_category = 3,
    display_name = "地下管II",
    item = "地下管2-JI型",
    model = "glbs/pipe/JI.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/pipe/JI.glb|mesh.prefab config:s,1,3",
    check_coord = "pipe_to_ground",
    builder = "pipe_to_ground",
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
}