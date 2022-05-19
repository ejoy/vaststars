local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "指挥中心" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/headquater.texture",
    model = "prefabs/rock.prefab",
    description = "基地建造的核心建筑",
    group = "物流",
    order = 100,
}
prototype "组装机I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/assembler.texture",
    model = "prefabs/rock.prefab",
    description = "用来组装或制造工业产品的工厂",
    group = "加工",
    order = 70,
}

prototype "熔炼炉I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/furnace2.texture",
    model = "prefabs/rock.prefab",
    description = "用来熔炼矿石的炉子",
    group = "加工",
    order = 50,
}

prototype "小型铁制箱子" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/chest.texture",
    model = "prefabs/rock.prefab",
    description = "贮藏物品的容器",
    group = "物流",
    order = 10,
}

prototype "采矿机I" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/miner.texture",
    model = "prefabs/rock.prefab",
    description = "用来挖掘矿物资源的机器",
    group = "加工",
    order = 40,
}

prototype "车站I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/manufacture.texture",
    model = "prefabs/rock.prefab",
    description = "专为运输车辆装载货物的装置",
    group = "物流",
    order = 51,
}

prototype "机器爪I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/insert1.texture",
    model = "prefabs/rock.prefab",
    description = "用来抓取货物的机械装置",
    group = "物流",
    order = 40,
}

prototype "蒸汽发电机I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/turbine1.texture",
    model = "prefabs/rock.prefab",
    description = "将热能转换成电能的机器",
    group = "物流",
    order = 120,
}

prototype "化工厂I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/chemistry2.texture",
    model = "prefabs/rock.prefab",
    description = "加工化工原料的工厂",
    group = "化工",
    order = 80,
}

prototype "铸造厂I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/assembler.texture",
    model = "prefabs/rock.prefab",
    description = "铸造金属的工厂",
    group = "加工",
    order = 63,
}

prototype "蒸馏厂I" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/distillery.texture",
    model = "prefabs/rock.prefab",
    description = "用来蒸馏液体的工厂",
    group = "化工",
    order = 62,
}

prototype "粉碎机I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/crusher1.texture",
    model = "prefabs/rock.prefab",
    description = "用于粉碎物体的装置",
    group = "加工",
    order = 60,
}

prototype "物流中心I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/logisitic1.texture",
    model = "prefabs/rock.prefab",
    description = "派遣和停靠运输车辆的物流车站",
    group = "物流",
    order = 52,
}

prototype "风力发电机I" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/wind-turbine.texture",
    model = "prefabs/rock.prefab",
    description = "利用风能转换电能的机器",
    group = "物流",
    order = 10,
}

prototype "铁制电线杆" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/electric-pole1.texture",
    model = "prefabs/rock.prefab",
    description = "用于传输电力的铁制电杆",
    group = "物流",
    order = 30,
}

prototype "科研中心I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/manufacture.texture",
    model = "prefabs/rock.prefab",
    description = "研究科技技术的中心",
    group = "加工",
    order = 80,
}

prototype "电解厂I" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/electrolysis1.texture",
    model = "prefabs/rock.prefab",
    description = "使用电能电离液体的工厂",
    group = "化工",
    order = 90,
}

prototype "太阳能板I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/solar-panel.texture",
    model = "prefabs/rock.prefab",
    description = "用来收集太阳能发电的装置",
    group = "物流",
    order = 15,
    
}

prototype "蓄电池I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/grid-battery.texture",
    model = "prefabs/rock.prefab",
    description = "可充电和放电的蓄能装置",
    group = "物流",
    order = 19,
}

prototype "水电站I" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/hydroplant.texture",
    model = "prefabs/rock.prefab",
    description = "处理海水的工厂",
    group = "化工",
    order = 70,
}

prototype "砖石公路-O型" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/road1.texture",
    model = "prefabs/rock.prefab",
    description = "处理海水的工厂",
    group = "物流",
    order = 50,
}

prototype "运输车辆I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/truck.texture",
    model = "prefabs/rock.prefab",
    description = "运输货物的交通工具",
    group = "物流",
    order = 53,
}