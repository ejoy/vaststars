--物品在仓库显示大小为:4X4、4X2、4X1、2X1四种

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    type = {"item"},
    group = {"物流"},
    stack = 1,
    item_description = "基地建造的核心建筑",
}
prototype "组装机I" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用来组装或制造工业产品的工厂",
}

prototype "组装机II" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用来组装或制造工业产品的工厂",
}

prototype "熔炼炉I" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用来熔炼矿石的炉子",
}

prototype "熔炼炉II" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用来熔炼矿石的炉子",
}

prototype "小铁制箱子I" {
    type = {"item"},
    group = {"物流"},
    stack = 5,
    item_description = "贮藏物品的容器",
}

prototype "小铁制箱子II" {
    type = {"item"},
    group = {"物流"},
    stack = 5,
    item_description = "贮藏物品的容器",
}

prototype "大铁制箱子I" {
    type = {"item"},
    group = {"物流"},
    stack = 5,
    item_description = "贮藏物品的容器",
}

prototype "仓库" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "贮藏物品的容器",
}

prototype "物流需求站" {
    type = {"item"},
    group = {"物流"},
    stack = 1,
    item_description = "将货物从运输车卸载到货站",
}

prototype "无人机仓库I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "储存货物的放置点",
}

prototype "建造中心" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "用来建造建筑的场所",
}

prototype "修路站" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "用来建造道路的场所",
}

prototype "修管站" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "用来建造管道的场所",
}

prototype "采矿机I" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用来挖掘矿物资源的机器",
}

prototype "采矿机II" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用来挖掘矿物资源的机器",
}

prototype "蒸汽发电机I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "将热能转换成电能的机器",
}

prototype "化工厂I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    item_description = "加工化工原料的工厂",
}

prototype "铸造厂I" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "铸造金属的工厂",
}

prototype "蒸馏厂I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    item_description = "用来蒸馏液体的工厂",
}

prototype "粉碎机I" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用于粉碎物体的装置",
}

prototype "浮选器I" {
    type = {"item"},
    group = {"加工"},
    stack = 10,
    item_description = "用于浮沉矿石的机器",
}

prototype "物流中心I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "派遣和停靠运输车辆的物流车站",
}

prototype "风力发电机I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "利用风能转换电能的机器",
}

prototype "铁制电线杆" {
    type = {"item"},
    group = {"物流"},
    stack = 25,
    item_description = "用于传输电力的铁制电杆",
}

prototype "科研中心I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "研究科技技术的中心",
}

prototype "出货车站" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "负责送货的车站",
}

prototype "收货车站" {
    type = {"item"},
    group = {"物流"},
    stack = 8,
    item_description = "负责收货的车站",
}

prototype "电解厂I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    item_description = "使用电能电离液体的工厂",
}

prototype "太阳能板I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "用来收集太阳能发电的装置",
}

prototype "蓄电池I" {
    type = {"item"},
    group = {"物流"},
    stack = 25,
    item_description = "可充电和放电的蓄能装置",
}

prototype "水电站I" {
    type = {"item"},
    group = {"化工"},
    stack = 10,
    item_description = "处理水的工厂",
}

prototype "砖石公路-X型" {
    type = {"item"},
    group = {"物流"},
    stack = 100,
    item_description = "供车辆行驶的砖石公路",
}

prototype "运输车辆I" {
    type = {"item"},
    group = {"物流"},
    stack = 50,
    item_description = "运输货物的交通工具",
    capacitance = "10MJ",
    speed = 63,
    icon = "textures/construct/truck.texture",
    model = "prefabs/lorry-1.prefab",
}

prototype "换热器I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "将水变成蒸汽的机器",
}

prototype "地热井I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "地下获取蒸汽的机器",
}

prototype "锅炉I" {
    type = {"item"},
    group = {"物流"},
    stack = 10,
    item_description = "将水变成蒸汽的机器",
}

prototype "热管1-X型" {
    type = {"item"},
    group = {"物流"},
    stack = 100,
    item_description = "传导热量的特殊管道",
}