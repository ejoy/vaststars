local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "指挥中心" {
    type ={"entity", "generator"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
}
prototype "组装机1" {
    type = {"entity", "assembling", "consumer", "fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
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

prototype "熔炼炉1" {
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "50%",
    power = "75kW",
    priority = "secondary",
}

prototype "小型铁制箱子" {
    type = {"entity", "chest"},
    area = "1x1",
    slots = 10,
}

prototype "采矿机1" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}

prototype "车站1" {
    type = {"entity", "chest"},
    area = "1x1",
    slots = 30,
}

prototype "机器爪1" {
    type = {"entity", "inserter", "consumer"},
    area = "1x1",
    speed = "1s",
    power = "12kW",
    priority = "secondary",
}

prototype "蒸汽发电机1" {
    type ={"entity", "generator", "fluidbox"},
    area = "2x3",
    power = "1MW",
    priority = "secondary",
    fluidbox = {
        capacity = 100,
        height = 200,
        base_level = -100,
        connections = {
            {type="input-output", position={0,1,"W"}},
            {type="input-output", position={2,1,"E"}},
        }
    }
}

prototype "化工厂1" {
    type ={"entity", "assembling", "consumer","fluidboxes"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    priority = "secondary",
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

prototype "蒸馏厂1" {
    type ={"entity", "assembling", "consumer", "fluidboxes"},
    area = "5x5",
    power = "240kW",
    priority = "secondary",
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

prototype "粉碎机1" {
    type ={"entity", "assembling", "consumer"},
    area = "3x3",
    power = "100kW",
    drain = "3kW",
    priority = "secondary",
}

prototype "物流中心" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "600kW",
    priority = "secondary",
}

prototype "液罐1" {
    type ={"entity", "fluidbox"},
    area = "3x3",
    fluidbox = {
        capacity = 20000,
        height = 200,
        base_level = 0,
        connections = {
            {type="input-output", position={0,0,"N"}},
            {type="input-output", position={2,2,"E"}},
            {type="input-output", position={2,2,"S"}},
            {type="input-output", position={0,0,"W"}},
        }
    }
}

prototype "抽水泵" {
    type ={"entity", "consumer", "fluidbox"},
    area = "1x2",
    power = "6kW",
    priority = "secondary",
    fluidbox = {
        capacity = 300,
        height = 100,
        base_level = 150,
        connections = {
            {type="output", position={0,0,"N"}},
        }
    }
}

prototype "压力泵1" {
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
    type ={"entity", "fluidbox"},
    area = "2x2",
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
    type ={"entity", "fluidbox"},
    area = "3x3",
    fluidbox = {
        capacity = 1000,
        height = 100,
        base_level = 10,
        connections = {
            {type="input", position={1,0,"N"}},
        }
    }
}

prototype "风力发电机1" {
    type ={"entity", "generator"},
    area = "3x3",
    power = "1.2MW",
    priority = "primary",
}

prototype "铁制电线杆" {
    type ={"entity"},
    area = "1x1",
}

prototype "科技中心1" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}

prototype "电解厂1" {
    type ={"entity", "assembling", "consumer", "fluidboxes"},
    area = "5x5",
    power = "1MW",
    drain = "30kW",
    priority = "secondary",
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

prototype "空气过滤器1" {
    type ={"entity", "consumer","fluidbox"},
    area = "3x3",
    power = "50kW",
    drain = "1.5kW",
    priority = "secondary",
    fluidbox = {
        capacity = 1000,
        height = 200,
        base_level = 150,
        connections = {
            {type="output", position={1,2,"S"}},
        }
    }
}

prototype "管道1-I型" {
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

prototype "管道1-L型" {
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

prototype "地下管1" {
    type ={"entity","pipe-to-ground","fluidbox"},
    area = "1x1",
    max_distance = 10,
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

prototype "太阳能板1" {
    type ={"entity","generator"},
    area = "3x3",
    power = "100kW",
    priority = "primary",
}

prototype "蓄电池1" {
    type ={"entity"},
    area = "2x2",
    priority = "secondary",
}

prototype "水电站1" {
    type ={"entity", "assembling", "consumer", "fluidboxes"},
    area = "5x5",
    power = "150kW",
    priority = "secondary",
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
    }


}

prototype "核反应堆" {
    type = {"entity", "generator", "burner"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
}