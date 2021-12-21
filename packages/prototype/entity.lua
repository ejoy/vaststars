local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "指挥中心" {
    type ={"entity", "generator"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
}
prototype "组装机1" {
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
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
    type ={"entity", "generator"},
    area = "2x3",
    power = "1MW",
    priority = "secondary",
}

prototype "化工厂1" {
    type ={"entity", "assembling", "consumer"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    priority = "secondary",
}

prototype "蒸馏厂1" {
    type ={"entity", "assembling", "consumer"},
    area = "5x5",
    power = "240kW",
    priority = "secondary",
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
    type ={"entity"},
    area = "3x3",
}

prototype "抽水泵" {
    type ={"entity", "consumer"},
    area = "1x2",
    power = "6kW",
    priority = "secondary",
}

prototype "压力泵1" {
    type ={"entity", "consumer"},
    area = "1x2",
    power = "10kW",
    drain = "300W",
    priority = "secondary",
}

prototype "烟囱1" {
    type ={"entity"},
    area = "2x2",
}

prototype "排水口1" {
    type ={"entity"},
    area = "2x2",
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
    type ={"entity", "assembling", "consumer"},
    area = "5x5",
    power = "1MW",
    drain = "30kW",
    priority = "secondary",
}

prototype "空气过滤器1" {
    type ={"entity", "consumer"},
    area = "2x2",
    power = "50kW",
    drain = "1.5kW",
    priority = "secondary",
}

prototype "管道1" {
    type ={"entity"},
    area = "1x1",
}

prototype "地下管1" {
    type ={"entity"},
    area = "1x1",
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
    type ={"entity", "assembling", "consumer"},
    area = "5x5",
    power = "150kW",
    priority = "secondary",
}

prototype "核反应堆" {
    type = {"entity", "generator", "burner"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
}