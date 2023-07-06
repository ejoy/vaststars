--物品在仓库显示大小为:4X4、4X2、4X1、2X1四种

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    type = {"item"},
    item_category = "物流",
    stack = 1,
    pile = "4x1x4",
    backpack_stack = 1,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "存储材料和装配运输汽车的核心建筑",
}
prototype "组装机I" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "自动打印并组装零部件的设备",
}

prototype "组装机II" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "自动打印并组装零部件的设备",
}

prototype "组装机III" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "自动打印并组装零部件的设备",
}

prototype "熔炼炉I" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "高温熔炼矿石和精炼金属的设备",
}

prototype "熔炼炉II" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "高温熔炼矿石和精炼金属的设备",
}

prototype "熔炼炉III" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "高温熔炼矿石和精炼金属的设备",
}

prototype "小铁制箱子I" {
    type = {"item"},
    item_category = "物流",
    stack = 5, 
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/gravel.prefab",
    item_description = "贮藏物品的容器",
}

prototype "小铁制箱子II" {
    type = {"item"},
    item_category = "物流",
    stack = 5,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/gravel.prefab",
    item_description = "贮藏物品的容器",
}

prototype "大铁制箱子I" {
    type = {"item"},
    item_category = "物流",
    stack = 5,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/gravel.prefab",
    item_description = "贮藏物品的容器",
}

prototype "仓库" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/gravel.prefab",
    item_description = "贮藏物品的容器",
}

prototype "无人机仓库I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "使用无人机运输并储存货物的仓库",
}

prototype "无人机仓库II" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "使用无人机运输并储存货物的仓库",
}

prototype "无人机仓库III" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "使用无人机运输并储存货物的仓库",
}

prototype "采矿机I" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "挖掘、钻探地下矿物资源的设备",
}

prototype "采矿机II" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "挖掘、钻探地下矿物资源的设备",
}

prototype "采矿机III" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "挖掘、钻探地下矿物资源的设备",
}

prototype "蒸汽发电机I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "将蒸汽的热能转化成机械能用于发电的设备",
}

prototype "蒸汽发电机II" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "将蒸汽的热能转化成机械能用于发电的设备",
}

prototype "蒸汽发电机III" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "将蒸汽的热能转化成机械能用于发电的设备",
}

prototype "化工厂I" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "进行化学过程以生产化学产品的设施",
}

prototype "化工厂II" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "进行化学过程以生产化学产品的设施",
}

prototype "化工厂III" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "进行化学过程以生产化学产品的设施",
}

prototype "铸造厂I" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "铸造金属的设施",
}

prototype "蒸馏厂I" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "使用蒸馏方式对液态原料进行分离的设施",
}

prototype "蒸馏厂II" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "使用蒸馏方式对液态原料进行分离的设施",
}

prototype "蒸馏厂III" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "使用蒸馏方式对液态原料进行分离的设施",
}

prototype "粉碎机I" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "施加机械力到物料上将其破碎成较小碎片的设备",
}

prototype "粉碎机II" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "施加机械力到物料上将其破碎成较小碎片的设备",
}

prototype "粉碎机III" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "施加机械力到物料上将其破碎成较小碎片的设备",
}

prototype "浮选器I" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "通过浮沉矿石进行分离的机器",
}

prototype "浮选器II" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "通过浮沉矿石进行分离的机器",
}

prototype "浮选器III" {
    type = {"item"},
    item_category = "加工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "通过浮沉矿石进行分离的机器",
}


prototype "风力发电机I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "利用风能转换电能的装置",
}

prototype "铁制电线杆" {
    type = {"item"},
    item_category = "物流",
    stack = 25,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "在一定距离内传输电力的铁制电线杆",
}

prototype "远程电线杆" {
    type = {"item"},
    item_category = "物流",
    stack = 25,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "远程距离传输电力的电线杆",
}

prototype "广域电线杆" {
    type = {"item"},
    item_category = "物流",
    stack = 25,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "在大面积区域内传输电力的电线杆",
}

prototype "科研中心I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "致力于科学研究和开发活动的设施",
}

prototype "科研中心II" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "致力于科学研究和开发活动的设施",
}

prototype "科研中心III" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "致力于科学研究和开发活动的设施",
}

prototype "出货车站" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "给运输车提供货物的车站",
}

prototype "收货车站" {
    type = {"item"},
    item_category = "物流",
    stack = 8,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "从运输车收取货物的车站",
}

prototype "电解厂I" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "用电化学反应处理原料的设施",
}

prototype "电解厂II" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "用电化学反应处理原料的设施",
}

prototype "电解厂III" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "用电化学反应处理原料的设施",
}

prototype "太阳能板I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "利用太阳能产生光电效应发电的装置",
}

prototype "太阳能板II" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "利用太阳能产生光电效应发电的装置",
}

prototype "太阳能板III" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "利用太阳能产生光电效应发电的装置",
}

prototype "蓄电池I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "化学能与电能互相转化并储存的装置",
}

prototype "蓄电池II" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "化学能与电能互相转化并储存的装置",
}

prototype "蓄电池III" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "化学能与电能互相转化并储存的装置",
}

prototype "水电站I" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "大规模处理气液的设施",
}

prototype "水电站II" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "大规模处理气液的设施",
}

prototype "水电站III" {
    type = {"item"},
    item_category = "化工",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "大规模处理气液的设施",
}

prototype "砖石公路-X型" {
    type = {"item"},
    item_category = "物流",
    stack = 100,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "供车辆行驶的砖石公路",
}

prototype "运输车辆I" {
    type = {"item"},
    item_category = "物流",
    stack = 50,
    item_description = "在道路上行驶并运输货物的交通工具",
    capacitance = "10MJ",
    speed = 63,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/truck.texture",
    model = "prefabs/lorry-1.prefab",
}

prototype "换热器I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "将水变成蒸汽的机器",
}

prototype "地热井I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "通过地下钻探获取地热资源的装置",
}

prototype "地热井II" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "通过地下钻探获取地热资源的装置",
}

prototype "地热井III" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "通过地下钻探获取地热资源的装置",
}

prototype "锅炉I" {
    type = {"item"},
    item_category = "物流",
    stack = 10,
    pile = "4x1x4",
    backpack_stack = 20,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "通过加热将水变成蒸汽的装置",
}

prototype "热管1-X型" {
    type = {"item"},
    item_category = "物流",
    stack = 50,
    pile = "4x4x4",
    backpack_stack = 100,
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    item_description = "传导热量的特殊管道",
}