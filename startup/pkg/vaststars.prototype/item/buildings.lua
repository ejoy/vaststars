local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

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
    icon = "textures/construct/assembler1.texture",
    model = "prefabs/rock.prefab",
    description = "用来组装或制造工业产品的工厂",
    group = "加工",
    order = 70,
}

prototype "组装机II" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/assembler2.texture",
    model = "prefabs/rock.prefab",
    description = "用来组装或制造工业产品的工厂",
    group = "加工",
    order = 72,
}
prototype "车辆厂I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/assembler1.texture",
    model = "prefabs/rock.prefab",
    description = "用来组装运输车的工厂",
    group = "加工",
    order = 74,
}

prototype "熔炼炉I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/furnace1.texture",
    model = "prefabs/rock.prefab",
    description = "用来熔炼矿石的炉子",
    group = "加工",
    order = 50,
}

prototype "熔炼炉II" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/furnace2.texture",
    model = "prefabs/rock.prefab",
    description = "用来熔炼矿石的炉子",
    group = "加工",
    order = 51,
}

prototype "小铁制箱子I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/chest1.texture",
    model = "prefabs/rock.prefab",
    description = "贮藏物品的容器",
    group = "物流",
    order = 10,
}

prototype "小铁制箱子II" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/chest2.texture",
    model = "prefabs/rock.prefab",
    description = "贮藏物品的容器",
    group = "物流",
    order = 12,
}

prototype "大铁制箱子I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/chest.texture",
    model = "prefabs/rock.prefab",
    description = "贮藏物品的容器",
    group = "物流",
    order = 14,
}

prototype "仓库" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/chest.texture",
    model = "prefabs/rock.prefab",
    description = "贮藏物品的容器",
    group = "物流",
    order = 15,
}

prototype "基建站" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/road_box.texture",
    model = "prefabs/rock.prefab",
    description = "修建道路的专用设备",
    group = "物流",
    order = 16,
}

prototype "物流派送站" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/goodsstation-output.texture",
    model = "prefabs/rock.prefab",
    description = "将货物从货站装运到运输车",
    group = "物流",
    order = 17,
}

prototype "物流需求站" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/goodsstation-input.texture",
    model = "prefabs/rock.prefab",
    description = "将货物从运输车卸载到货站",
    group = "物流",
    order = 18,
}

prototype "无人机仓库" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/drone-depot.texture",
    model = "prefabs/rock.prefab",
    description = "储存货物的放置点",
    group = "物流",
    order = 19,
}

prototype "建造中心" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/construction-center.texture",
    model = "prefabs/rock.prefab",
    description = "用来建造建筑的场所",
    group = "物流",
    order = 20,
}

prototype "道路建造站" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/road-builder.texture",
    model = "prefabs/rock.prefab",
    description = "用来建造道路的场所",
    group = "物流",
    order = 21,
}

prototype "管道建造站" {
    type = {"item"},
    stack = 26,
    icon = "textures/construct/pipe-builder.texture",
    model = "prefabs/rock.prefab",
    description = "用来建造管道的场所",
    group = "物流",
    order = 22,
}

prototype "装卸站" {
    type = {"item"},
    stack = 28,
    icon = "textures/construct/logisitic1.texture",
    model = "prefabs/rock.prefab",
    description = "运输汽车装卸货物的停靠站点",
    group = "物流",
    order = 22,
}

prototype "采矿机I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/miner.texture",
    model = "prefabs/rock.prefab",
    description = "用来挖掘矿物资源的机器",
    group = "加工",
    order = 40,
}

prototype "采矿机II" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/miner.texture",
    model = "prefabs/rock.prefab",
    description = "用来挖掘矿物资源的机器",
    group = "加工",
    order = 42,
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

prototype "浮选器I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/flotation-cell.texture",
    model = "prefabs/rock.prefab",
    description = "用于浮沉矿石的机器",
    group = "加工",
    order = 65,
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
    icon = "textures/construct/lab.texture",
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
    description = "处理水的工厂",
    group = "化工",
    order = 70,
}

prototype "砖石公路-X型-01" {
    show_prototype_name = "砖石公路",
    type = {"item"},
    stack = 100,
    icon = "textures/construct/road1.texture",
    model = "prefabs/rock.prefab",
    description = "供车辆行驶的砖石公路",
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

prototype "换热器I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/turbine1.texture",
    model = "prefabs/rock.prefab",
    description = "将水变成蒸汽的机器",
    group = "加工",
    order = 130,
}

prototype "锅炉I" {
    type = {"item"},
    stack = 25,
    icon = "textures/construct/turbine1.texture",
    model = "prefabs/rock.prefab",
    description = "将水变成蒸汽的机器",
    group = "加工",
    order = 120,
}

prototype "热管1-X型" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/turbine1.texture",
    model = "prefabs/rock.prefab",
    description = "传导热量的特殊管道",
    group = "加工",
    order = 140,
}