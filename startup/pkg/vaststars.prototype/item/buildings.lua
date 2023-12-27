--物品在仓库显示大小为:4X4、4X2、4X1、2X1四种

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "指挥中心" {
    type = {"item"},
    item_category = "物流",
    station_limit = 1,
    chest_limit = 15,
    backpack_limit = 1,
    item_order = 50,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/headquater.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "存储材料和装配运输汽车的核心建筑",
}

prototype "物流中心" {
    type = {"item"},
    item_category = "物流",
    station_limit = 1,
    chest_limit = 15,
    backpack_limit = 1,
    item_order = 50,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/headquater.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "运输车辆出发和停靠的建筑",
}


prototype "组装机I" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 52,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/assembler.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "自动打印并组装零部件的设备",
}

prototype "组装机II" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 54,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/assembler.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "自动打印并组装零部件的设备",
}

prototype "组装机III" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 56,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/assembler.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "自动打印并组装零部件的设备",
}

prototype "熔炼炉I" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 58,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/furnace.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "高温熔炼矿石和精炼金属的设备",
}

prototype "熔炼炉II" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 60,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/furnace.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "高温熔炼矿石和精炼金属的设备",
}

prototype "熔炼炉III" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 62,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/furnace.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "高温熔炼矿石和精炼金属的设备",
}

prototype "小铁制箱子I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8, 
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 64,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/furnace.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "贮藏物品的容器",
}

prototype "小铁制箱子II" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 66,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/furnace.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "贮藏物品的容器",
}

prototype "大铁制箱子I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 68,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/furnace.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "贮藏物品的容器",
}

prototype "仓库I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 70,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/depot.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "贮藏物品的容器",
}

prototype "无人机平台I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 40,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/drone-depot.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "使用无人机运输并储存货物的仓库",
}

prototype "无人机平台II" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 42,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/drone-depot.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "使用无人机运输并储存货物的平台",
}

prototype "无人机平台III" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 44,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/drone-depot.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "使用无人机运输并储存货物的平台",
}

prototype "采矿机I" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 30,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/miner.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "挖掘或钻探地下矿物资源的设备",
}

prototype "采矿机II" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 32,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/miner.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "挖掘或钻探地下矿物资源的设备",
}

prototype "采矿机III" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 34,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/miner.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "挖掘或钻探地下矿物资源的设备",
}

prototype "轻型采矿机" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 35,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/miner.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "挖掘或钻探地下矿物资源的设备",
}

prototype "蒸汽发电机I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 60,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/turbine.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "将蒸汽的热能转化成机械能用于发电的设备",
}

prototype "蒸汽发电机II" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 62,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/turbine.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "将蒸汽的热能转化成机械能用于发电的设备",
}

prototype "蒸汽发电机III" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 64,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/turbine.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "将蒸汽的热能转化成机械能用于发电的设备",
}

prototype "化工厂I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 66,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chemistry.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过化学反应以生产化学产品的设施",
}

prototype "化工厂II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 68,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chemistry.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过化学反应以生产化学产品的设施",
}

prototype "化工厂III" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 70,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chemistry.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过化学反应以生产化学产品的设施",
}

prototype "铸造厂I" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 72,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chemistry.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "铸造金属的设施",
}

prototype "蒸馏厂I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 74,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/distillery.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "使用蒸馏方式对液态原料进行分离的设施",
}

prototype "蒸馏厂II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 76,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/distillery.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "使用蒸馏方式对液态原料进行分离的设施",
}

prototype "蒸馏厂III" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 78,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/distillery.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "使用蒸馏方式对液态原料进行分离的设施",
}

prototype "粉碎机I" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 80,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/assembler.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "施加机械力到物料上将其破碎成较小碎片的设备",
}

prototype "粉碎机II" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 82,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/assembler.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "施加机械力到物料上将其破碎成较小碎片的设备",
}

prototype "粉碎机III" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 84,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/assembler.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "施加机械力到物料上将其破碎成较小碎片的设备",
}

prototype "浮选器I" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 86,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/flotation-cell-frame.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过浮沉矿石进行分离的机器",
}

prototype "浮选器II" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 88,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/flotation-cell-frame.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过浮沉矿石进行分离的机器",
}

prototype "浮选器III" {
    type = {"item"},
    item_category = "加工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 90,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/flotation-cell-frame.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过浮沉矿石进行分离的机器",
}


prototype "风力发电机I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 2,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/wind-turbine.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "利用风能转换电能的装置",
}

prototype "轻型风力发电机" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 2,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/wind-turbine.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "利用风能转换电能的装置",
}

prototype "铁制电线杆" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 50,
    item_order = 4,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/electric-pole.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "在一定距离内传输电力的铁制电线杆",
}

prototype "远程电线杆" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 6,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/electric-pole.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "远程距离传输电力的电线杆",
}

prototype "广域电线杆" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 8,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/electric-pole.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "在大面积区域内传输电力的电线杆",
}

prototype "科研中心I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 10,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/lab.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "应用于科学研究和开发活动的设施",
}

prototype "科研中心II" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 12,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/lab.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "应用于科学研究和开发活动的设施",
}

prototype "科研中心III" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 14,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/lab.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "应用于科学研究和开发活动的设施",
}

prototype "地质科研中心" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 10,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/lab.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "应用于科学研究和开发活动的设施",
}

prototype "物流站" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 15,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/goodstation-input.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "给运输车辆提供货物的车站",
}

prototype "电解厂I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 50,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/electrolysis.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "用电化学反应处理原料的设施",
}

prototype "电解厂II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 52,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/electrolysis.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "用电化学反应处理原料的设施",
}

prototype "电解厂III" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 54,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/electrolysis.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "用电化学反应处理原料的设施",
}

prototype "太阳能板I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 20,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/solar-panel.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "利用太阳能产生光电效应发电的装置",
}

prototype "太阳能板II" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 22,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/solar-panel.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "利用太阳能产生光电效应发电的装置",
}

prototype "太阳能板III" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 24,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/solar-panel.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "利用太阳能产生光电效应发电的装置",
}

prototype "轻型太阳能板" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 24,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/solar-panel.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "利用太阳能产生光电效应发电的装置",
}

prototype "蓄电池I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 26,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/grid-battery.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "化学能与电能互相转化并储存的装置",
}

prototype "蓄电池II" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 28,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/grid-battery.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "化学能与电能互相转化并储存的装置",
}

prototype "蓄电池III" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 30,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/grid-battery.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "化学能与电能互相转化并储存的装置",
}

prototype "水电站I" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 56,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/hydroplant.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "大规模处理气液的设施",
}

prototype "水电站II" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 58,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/hydroplant.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "大规模处理气液的设施",
}

prototype "水电站III" {
    type = {"item"},
    item_category = "化工",
    station_limit = 8,
    chest_limit = 15,
    item_order = 60,
    backpack_limit = 20,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/hydroplant.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "大规模处理气液的设施",
}

prototype "砖石公路-X型" {
    type = {"item"},
    item_category = "物流",
    station_limit = 16,
    chest_limit = 60,
    backpack_limit = 100,
    item_order = 2,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/road.texture",
    item_model = "glbs/stackeditems/stone-brick.glb|mesh.prefab",
    item_description = "供车辆行驶的砖石公路",
}

prototype "运输车辆I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    item_description = "行驶在公路上可运输货物的交通工具",
    capacitance = "10MJ",
    speed = 63,
    chest_limit = 15,
    backpack_limit = 50,
    item_order = 4,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/truck.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    icon = "mem:/pkg/vaststars.resources/glbs/stackeditems/building.glb|mesh.prefab config:s,1,3",
    model = "glbs/lorry-1.glb|mesh.prefab",
}

prototype "换热器I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 70,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/truck.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "将水变成蒸汽的机器",
}

prototype "地热井I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 72,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/geothermal-plant.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过地下钻探获取地热资源的装置",
}

prototype "地热井II" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 74,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/geothermal-plant.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过地下钻探获取地热资源的装置",
}

prototype "地热井III" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 76,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/geothermal-plant.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过地下钻探获取地热资源的装置",
}

prototype "锅炉I" {
    type = {"item"},
    item_category = "物流",
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 20,
    item_order = 78,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/boiler-frame.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "通过加热将水变成蒸汽的装置",
}

prototype "广播塔I" {
    type = {"item"},
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 25,
    item_order = 80,
    item_model = "glbs/stackeditems/iron-plate.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chemistry.texture",
    item_description = "将插件功效传导到周边其他机器的设施",
    item_category = "物流",
}

prototype "广播塔II" {
    type = {"item"},
    station_limit = 8,
    chest_limit = 15,
    backpack_limit = 25,
    item_order = 82,
    item_model = "glbs/stackeditems/iron-plate.glb|mesh.prefab",
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chemistry.texture",
    item_description = "将插件功效传导到周边其他机器的设施",
    item_category = "物流",
}

prototype "热管1-X型" {
    type = {"item"},
    item_category = "物流",
    station_limit = 16,
    chest_limit = 64,
    backpack_limit = 100,
    item_order = 84,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/chemistry.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "传导热量的特殊管道",
}

----------------------------------------
prototype "机身残骸" {
    type = {"item"},
    item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 100,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机身组件",
}

prototype "机翼残骸" {
    type = {"item"},
    item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 102,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机翼组件",
}

prototype "机头残骸" {
    type = {"item"},
    item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 104,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机头组件",
}

prototype "机尾残骸" {
    type = {"item"},
    item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊组装机" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊科研中心" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊浮选器" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊电解厂" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊熔炼炉" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊化工厂" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊水电站" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊采矿机" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}

prototype "特殊蒸馏厂" {
    type = {"item"},
    --item_category = "物流",
    station_limit = 50,
    chest_limit = 15,
    backpack_limit = 100,
    item_order = 106,
    item_icon = "/pkg/vaststars.resources/textures/icons/item/ruin.texture",
    item_model = "glbs/stackeditems/building.glb|mesh.prefab",
    item_description = "损坏飞行器残留的机尾组件",
}