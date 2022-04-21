local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁锭" {
    type = { "recipe" },
    category = "金属冶炼",
    group = "金属",
    order = 10,
    icon = "construct/steel-beam.png",
    ingredients = {
        {"铁矿石", 5},
    },
    results = {
        {"铁锭", 2},
        {"碎石", 1}
    },
    time = "8s",
    description = "铁矿石通过金属冶炼获得铁锭",
}

prototype "铁板1" {
    type = { "recipe" },
    category = "金属锻造",
    group = "金属",
    order = 11,
    icon = "construct/steel-beam.png",
    ingredients = {
        {"铁锭", 4},
    },
    results = {
        {"铁板", 3}
    },
    time = "3s",
    description = "使用铁锭锻造铁板",

}

prototype "铁板2" {
    type = { "recipe" },
    category = "金属锻造",
    group = "金属",
    order = 12,
    icon = "construct/steel-beam.png",
    ingredients = {
        {"铁锭", 4},
        {"碎石", 2}
    },
    results = {
        {"铁板", 5}
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",

}

prototype "铁棒1" {
    type = { "recipe" },
    category = "金属锻造",
    group = "金属",
    order = 13,
    icon = "construct/steel-beam.png",
    ingredients = {
        {"铁锭", 4},
    },
    results = {
        {"铁棒", 5}
    },
    time = "4s",
    description = "使用铁锭锻造铁棒",
}

prototype "铁丝1" {
    type = { "recipe" },
    category = "金属锻造",
    group = "金属",
    order = 14,
    icon = "construct/steel-beam.png",
    ingredients = {
        {"铁棒", 3},
    },
    results = {
        {"铁丝", 4}
    },
    time = "4s",
    description = "使用铁棒锻造铁丝",
}

prototype "沙石粉碎" {
    type = { "recipe" },
    category = "矿石粉碎",
    group = "金属",
    order = 40,
    icon = "construct/gravel.png",
    ingredients = {
        {"沙石矿", 5},
    },
    results = {
        {"沙子", 3},
        {"碎石", 2},
    },
    time = "4s",
    description = "粉碎沙石矿获得更微小的原材料",
}

prototype "石砖" {
    type = { "recipe" },
    category = "中型制造",
    group = "物流",
    order = 100,
    icon = "construct/gravel.png",
    ingredients = {
        {"碎石", 4},
    },
    results = {
        {"石砖", 2},
    },
    time = "3s",
    description = "使用碎石炼制石砖",
}

prototype "玻璃" {
    type = { "recipe" },
    category = "金属锻造",
    group = "金属",
    order = 70,
    icon = "construct/iron.png",
    ingredients = {
        {"硅", 3},
    },
    results = {
        {"玻璃", 1},
    },
    time = "16s",
    description = "使用硅炼制玻璃",
}

prototype "电动机1" {
    type = { "recipe" },
    category = "中型制造",
    group = "器件",
    order = 52,
    icon = "construct/turbine1.png",
    ingredients = {
        {"铁棒", 1},
        {"铁丝", 2},
        {"铁板", 2},
        {"塑料", 1},
    },
    results = {
        {"电动机1", 1},
    },
    time = "8s",
    description = "铁制品和塑料打造初级电动机",
}

prototype "铁齿轮" {
    type = { "recipe" },
    category = "小型制造",
    group = "金属",
    order = 15,
    icon = "construct/steel-beam.png",
    ingredients = {
        {"铁棒", 1},
        {"铁板", 2},
    },
    results = {
        {"铁齿轮", 2},
    },
    time = "4s",
    description = "使用铁制品加工铁齿轮",
}

prototype "机器爪1" {
    type = { "recipe" },
    category = "小型制造",
    group = "物流",
    order = 40,
    icon = "construct/insert1.png",
    ingredients = {
        {"铁棒", 3},
        {"铁齿轮", 2},
        {"电动机1", 1},
    },
    results = {
        {"机器爪1", 3},
    },
    time = "5s",
    description = "铁制品和电动机制造机器爪",
}

prototype "砖石公路-O型" {
    type = { "recipe" },
    category = "中型制造",
    group = "物流",
    order = 50,
    icon = "construct/processor.png",
    ingredients = {
        {"石砖", 8},
    },
    results = {
        {"砖石公路-O型", 4},
    },
    time = "6s",
    description = "使用石砖制造公路",
}

prototype "车站1" {
    type = { "recipe" },
    category = "中型制造",
    group = "物流",
    order = 51,
    icon = "construct/manufacture.png",
    ingredients = {
        {"机器爪1", 1},
        {"小型铁制箱子", 1},
    },
    results = {
        {"车站1", 1},
    },
    time = "4s",
    description = "使用机器爪和箱子制造车站",
}

prototype "物流中心1" {
    type = { "recipe" },
    category = "大型制造",
    group = "物流",
    order = 52,
    icon = "construct/logisitic1.png",
    ingredients = {
        {"蒸汽发电机1", 1},
        {"车站1", 2},
        {"砖石公路-O型", 10},
    },
    results = {
        {"物流中心1", 1},
    },
    time = "10s",
    description = "发电设施和车载设备制造物流中心",
}

prototype "运输车辆1" {
    type = { "recipe" },
    category = "中型制造",
    group = "物流",
    order = 53,
    icon = "construct/truck.png",
    ingredients = {
        {"电动机1", 1},
        {"塑料", 4},
        {"铁板", 8},
        {"玻璃", 4},
    },
    results = {
        {"运输车辆1", 1},
    },
    time = "5s",
    description = "电动机和铁制品制造汽车",
}

prototype "小型铁制箱子" {
    type = { "recipe" },
    category = "中型制造",
    group = "物流",
    order = 10,
    icon = "construct/chest.png",
    ingredients = {
        {"铁棒", 1},
        {"铁板", 8},
    },
    results = {
        {"小型铁制箱子", 1},
    },
    time = "3s",
    description = "使用铁制品制造箱子",
}

prototype "铁制电线杆" {
    type = { "recipe" },
    category = "中型制造",
    group = "物流",
    order = 30,
    icon = "construct/electric-pole1.png",
    ingredients = {
        {"塑料", 1},
        {"铁棒", 1},
        {"铁丝", 2},
    },
    results = {
        {"铁制电线杆", 1},
    },
    time = "2s",
    description = "导电材料制造电线杆",
}

prototype "采矿机1" {
    type = { "recipe" },
    category = "中型制造",
    group = "生产",
    order = 40,
    icon = "construct/miner.png",
    ingredients = {
        {"铁板", 4},
        {"铁齿轮", 3},
        {"电动机1", 2},
    },
    results = {
        {"采矿机1", 2},
    },
    time = "6s",
    description = "使用铁制品和电动机制造采矿机",
}

prototype "熔炼炉1" {
    type = { "recipe" },
    category = "中型制造",
    group = "生产",
    order = 50,
    icon = "construct/furnace2.png",
    ingredients = {
        {"铁板", 1},
        {"铁丝", 2},
        {"石砖", 4},
    },
    results = {
        {"熔炼炉1", 1},
    },
    time = "8s",
    description = "使用铁制品和石砖制造熔炼炉",
}

prototype "组装机1" {
    type = { "recipe" },
    category = "中型制造",
    group = "生产",
    order = 70,
    icon = "construct/assembler.png",
    ingredients = {
        {"小型铁制箱子", 1},
        {"机器爪1", 1},
        {"铁齿轮", 4},
    },
    results = {
        {"熔炼炉1", 1},
    },
    time = "6s",
    description = "机械原料制造组装机",
}

prototype "蒸汽发电机1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 120,
    icon = "construct/turbine1.png",
    ingredients = {
        {"管道1", 2},
        {"铁齿轮", 1},
        {"铁板", 8},
        {"电动机1", 1},
    },
    results = {
        {"蒸汽发电机1", 1},
    },
    time = "8s",
    description = "管道和机械原料制造蒸汽发电机",
}

prototype "风力发电机1" {
    type = { "recipe" },
    category = "大型制造",
    group = "生产",
    order = 10,
    icon = "construct/wind-turbine.png",
    ingredients = {
        {"铁制电线杆", 3},
        {"蒸汽发电机1", 2},
    },
    results = {
        {"风力发电机1", 1},
    },
    time = "5s",
    description = "电传输材料和发电设施制造风力发电机",
}

prototype "液罐1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 22,
    icon = "construct/tank1.png",
    ingredients = {
        {"管道1", 4},
        {"铁棒", 1},
        {"铁板", 6},
    },
    results = {
        {"液罐1", 1},
    },
    time = "6s",
    description = "管道和铁制品制造液罐",
}

prototype "化工厂1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 80,
    icon = "construct/chemistry2.png",
    ingredients = {
        {"玻璃", 4},
        {"压力泵1", 1},
        {"液罐1", 2},
        {"组装机1", 1},
    },
    results = {
        {"化工厂1", 1},
    },
    time = "15s",
    description = "液体容器和加工设备制造化工厂",
}

prototype "铸造厂1" {
    type = { "recipe" },
    category = "大型制造",
    group = "生产",
    order = 63,
    icon = "construct/assembler.png",
    ingredients = {
        {"铁板", 3},
        {"机器爪1", 2},
        {"熔炼炉1", 1},
    },
    results = {
        {"铸造厂1", 1},
    },
    time = "15s",
    description = "熔炼设备和机器爪制造铸造厂",
}

prototype "水电站1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 70,
    icon = "construct/hydroplant.png",
    ingredients = {
        {"蒸馏厂1", 1},
        {"抽水泵", 1},
    },
    results = {
        {"水电站1", 1},
    },
    time = "4s",
    description = "蒸馏设施和抽水泵制造水电站",
}

prototype "蒸馏厂1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 62,
    icon = "construct/distillery.png",
    ingredients = {
        {"烟囱1", 1},
        {"液罐1", 2},
        {"熔炼炉1", 1}, 
    },
    results = {
        {"蒸馏厂1", 1},
    },
    time = "4s",
    description = "液体容器和熔炼设备制造蒸馏厂",
}


prototype "烟囱1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 65,
    icon = "construct/chimney2.png",
    ingredients = {
        {"铁棒", 2},
        {"管道1", 3},
        {"石砖", 3},
    },
    results = {
        {"烟囱1", 1},
    },
    time = "4s",
    description = "铁制品和管道制造烟囱",
}

prototype "压力泵1" {
    type = { "recipe" },
    category = "中型制造",
    group = "化工",
    order = 40,
    icon = "construct/pump1.png",
    ingredients = {
        {"电动机1", 1},
        {"管道1", 4},
    },
    results = {
        {"压力泵1", 1},
    },
    time = "2s",
    description = "管道和电机制造压力泵",
}

prototype "抽水泵" {
    type = { "recipe" },
    category = "中型制造",
    group = "化工",
    order = 50,
    icon = "construct/offshore-pump.png",
    ingredients = {
        {"排水口1", 1},
        {"压力泵1", 1},
    },
    results = {
        {"抽水泵", 1},
    },
    time = "4s",
    description = "排水设施和压力泵制造抽水泵",
}

prototype "空气过滤器1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 60,
    icon = "construct/air-filter1.png",
    ingredients = {
        {"压力泵1", 1},
        {"塑料", 4},
        {"蒸汽发电机1", 4},
    },
    results = {
        {"空气过滤器1", 1},
    },
    time = "8s",
    description = "压力泵和发电设施制造空气过滤器",
}

prototype "排水口1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 56,
    icon = "construct/outfall.png",
    ingredients = {
        {"管道1", 5},
        {"地下管1", 1},
    },
    results = {
        {"排水口1", 1},
    },
    time = "4s",
    description = "管道制造排水口",
}

prototype "管道1" {
    type = { "recipe" },
    category = "小型制造",
    group = "化工",
    order = 10,
    icon = "construct/pipe.png",
    ingredients = {
        {"石砖", 8},
    },
    results = {
        {"管道1", 5},
        {"碎石", 1},
    },
    time = "6s",
    description = "石砖制造管道",
}

prototype "地下管1" {
    type = { "recipe" },
    category = "小型制造",
    group = "化工",
    order = 12,
    icon = "construct/pipe.png",
    ingredients = {
        {"管道1", 5},
        {"沙子", 2},
    },
    results = {
        {"地下管1", 2},
    },
    time = "5s",
    description = "管道和沙子制造地下管道",
}

prototype "粉碎机1" {
    type = { "recipe" },
    category = "大型制造",
    group = "生产",
    order = 60,
    icon = "construct/crusher1.png",
    ingredients = {
        {"铁丝", 4},
        {"石砖", 8},
        {"采矿机1", 1},
    },
    results = {
        {"粉碎机1", 1},
    },
    time = "5s",
    description = "石砖和采矿机制造粉碎机",
}

prototype "电解厂1" {
    type = { "recipe" },
    category = "大型制造",
    group = "化工",
    order = 90,
    icon = "construct/electrolysis1.png",
    ingredients = {
        {"液罐1", 4},
        {"铁制电线杆", 8},
    },
    results = {
        {"电解厂1", 1},
    },
    time = "10s",
    description = "液体容器和电传输设备制造电解厂",
}

prototype "科研中心1" {
    type = { "recipe" },
    category = "大型制造",
    group = "生产",
    order = 80,
    icon = "construct/manufacture.png",
    ingredients = {
        {"机器爪1", 4},
        {"铁板", 20},
        {"电动机1", 1},
        {"玻璃", 4}, 
    },
    results = {
        {"科研中心1", 1},
    },
    time = "10s",
    description = "机械装置和电动机制造科研中心",
}


prototype "破损水电站" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 110,
    icon = "construct/hydroplant.png",
    ingredients = {
        {"管道1", 4},
        {"破损水电站", 1},
    },
    results = {
        {"水电站1", 1},
    },
    time = "4s",
    description = "修复损坏的水电站",
}

prototype "破损空气过滤器" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 111,
    icon = "construct/air-filter1.png",
    ingredients = {
        {"铁板", 4},
        {"破损空气过滤器", 1},
    },
    results = {
        {"空气过滤器1", 1},
    },
    time = "3s",
    description = "修复损坏的空气过滤器",
}

prototype "破损电解厂" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 112,
    icon = "construct/electrolysis1.png",
    ingredients = {
        {"铁丝", 5},
        {"破损电解厂", 1},
    },
    results = {
        {"电解厂1", 1},
    },
    time = "6s",
    description = "修复损坏的电解厂",
}

prototype "破损化工厂" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 113,
    icon = "construct/chemistry2.png",
    ingredients = {
        {"压力泵1", 1},
        {"破损化工厂", 1},
    },
    results = {
        {"化工厂1", 1},
    },
    time = "5s",
    description = "修复损坏的化工厂",
}

prototype "破损组装机" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 114,
    icon = "construct/assembler.png",
    ingredients = {
        {"铁齿轮", 2},
        {"破损组装机", 1},
    },
    results = {
        {"组装机1", 1},
    },
    time = "3s",
    description = "修复损坏的组装机",
}

prototype "破损铁制电线杆" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 115,
    icon = "construct/electric-pole1.png",
    ingredients = {
        {"铁棒", 2},
        {"破损铁制电线杆", 1},
    },
    results = {
        {"铁制电线杆", 1},
    },
    time = "2s",
    description = "修复损坏的铁制电线杆",
}

prototype "破损太阳能板" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 116,
    icon = "construct/solar-panel.png",
    ingredients = {
        {"沙子", 1},
        {"破损太阳能板", 1},
    },
    results = {
        {"太阳能板1", 1},
    },
    time = "8s",
    description = "修复损坏的太阳能板",
}

prototype "破损蓄电池" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 117,
    icon = "construct/grid-battery.png",
    ingredients = {
        {"石墨", 1},
        {"破损蓄电池", 1},
    },
    results = {
        {"蓄电池1", 1},
    },
    time = "6s",
    description = "修复损坏的蓄电池",
}

prototype "破损物流中心" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 118,
    icon = "construct/logisitic1.png",
    ingredients = {
        {"铁板", 5},
        {"破损物流中心", 1},
    },
    results = {
        {"物流中心1", 1},
    },
    time = "6s",
    description = "修复损坏的物流中心",
}

prototype "破损运输汽车" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 119,
    icon = "construct/truck.png",
    ingredients = {
        {"铁丝", 10},
        {"破损运输车辆", 1},
    },
    results = {
        {"运输车辆1", 1},
    },
    time = "4s",
    description = "修复损坏的运输汽车",
}

prototype "破损车站" {
    type = { "recipe" },
    category = "手工制造",
    group = "生产",
    order = 120,
    icon = "construct/manufacture.png",
    ingredients = {
        {"铁棒", 6},
        {"破损车站", 1},
    },
    results = {
        {"车站1", 1},
    },
    time = "5s",
    description = "修复损坏的车站",
}

prototype "地质科技包1" {
    type = { "recipe" },
    category = "小型制造",
    group = "器件",
    order = 80,
    icon = "construct/processor.png",
    ingredients = {
        {"铁矿石", 2},
        {"沙石矿", 2},
    },
    results = {
        {"地质科技包", 1},
    },
    time = "15s",
    description = "地质材料制造地质科技包",
}

prototype "气候科技包1" {
    type = { "recipe" },
    category = "液体处理",
    group = "器件",
    order = 82,
    icon = "construct/processor.png",
    ingredients = {
        {"海水", 2000},
        {"空气", 3000},
    },
    results = {
        {"气候科技包", 1},
    },
    time = "25s",
    description = "气候材料制造气候科技包",
}

prototype "机械科技包1" {
    type = { "recipe" },
    category = "中型制造",
    group = "器件",
    order = 84,
    icon = "construct/processor.png",
    ingredients = {
        {"电动机1", 1},
        {"铁齿轮", 3},
    },
    results = {
        {"机械科技包", 1},
    },
    time = "15s",
    description = "机械原料制造机械科技包",
}

prototype "空气过滤" {
    type = { "recipe" },
    category = "过滤",
    group = "流体",
    order = 20,
    icon = "construct/air-filter1.png",
    ingredients = {
    },
    results = {
        {"空气", 50},
    },
    time = "1s",
    description = "采集大气并过滤",
}

prototype "离岸抽水" {
    type = { "recipe" },
    category = "水泵",
    group = "流体",
    order = 10,
    icon = "construct/hydroplant.png",
    ingredients = {
    },
    results = {
        {"海水", 1200},
    },
    time = "1s",
    description = "抽取海洋里海水",
}


prototype "空气分离1" {
    type = { "recipe" },
    category = "过滤",
    group = "流体",
    order = 11,
    icon = "construct/air-filter1.png",
    ingredients = {
        {"空气", 150},
    },
    results = {
        {"氮气", 90},
        {"二氧化碳", 40},
    },
    time = "1s",
    description = "空气分离出纯净气体",
}

prototype "海水电解" {
    type = { "recipe" },
    category = "电解",
    group = "流体",
    order = 16,
    icon = "construct/electrolysis1.png",
    ingredients = {
        {"海水", 40},
    },
    results = {
        {"氢气", 110},
        {"氯气", 15},
        {"氢氧化钠", 1},
    },
    time = "1s",
    description = "海水电解出纯净气体和化合物",
}

prototype "二氧化碳转一氧化碳" {
    type = { "recipe" },
    category = "基础化工",
    group = "流体",
    order = 31,
    icon = "fluid/gas.png",
    ingredients = {
        {"二氧化碳", 40},
        {"氢气", 40},
    },
    results = {
        {"纯水", 8},
        {"一氧化碳", 25},
    },
    time = "1s",
    description = "二氧化碳转一氧化碳",
}

prototype "二氧化碳转甲烷" {
    type = { "recipe" },
    category = "基础化工",
    group = "流体",
    order = 34,
    icon = "fluid/gas.png",
    ingredients = {
        {"二氧化碳", 32},
        {"氢气", 110},
    },
    results = {
        {"纯水", 10},
        {"甲烷", 24},
    },
    time = "1s",
    description = "二氧化碳转甲烷",
}

prototype "一氧化碳转石墨" {
    type = { "recipe" },
    category = "基础化工",
    group = "器件",
    order = 10,
    icon = "fluid/gas.png",
    ingredients = {
        {"一氧化碳", 28},
        {"氢气", 36},
    },
    results = {
        {"纯水", 5},
        {"石墨", 1},
    },
    time = "2s",
    description = "一氧化碳转石墨",
}

prototype "氯化氢" {
    type = { "recipe" },
    category = "基础化工",
    group = "流体",
    order = 60,
    icon = "fluid/gas.png",
    ingredients = {
        {"氯气", 30},
        {"氢气", 30},
    },
    results = {
        {"盐酸", 60},
    },
    time = "1s",
    description = "氢气和氯气化合成氯化氢",
}

prototype "纯水电解" {
    type = { "recipe" },
    category = "电解",
    group = "流体",
    order = 15,
    icon = "fluid/gas.png",
    ingredients = {
        {"纯水", 45},
    },
    results = {
        {"氧气", 70},
        {"氢气", 140},
    },
    time = "1s",
    description = "纯水电解成氧气和氢气",
}

prototype "甲烷转乙烯" {
    type = { "recipe" },
    category = "基础化工",
    group = "流体",
    order = 36,
    icon = "fluid/gas.png",
    ingredients = {
        {"甲烷", 40},
        {"氧气", 40},
    },
    results = {
        {"乙烯", 16},
        {"纯水", 8},
    },
    time = "1s",
    description = "甲烷转乙烯",
}

prototype "塑料1" {
    type = { "recipe" },
    category = "基础化工",
    group = "器件",
    order = 20,
    icon = "construct/processor.png",
    ingredients = {
        {"乙烯", 30},
        {"氯气", 30},
    },
    results = {
        {"盐酸", 20},
        {"塑料", 1},
    },
    time = "3s",
    description = "化工原料合成塑料",
}

prototype "塑料2" {
    type = { "recipe" },
    category = "基础化工",
    group = "器件",
    order = 21,
    icon = "construct/processor.png",
    ingredients = {
        {"甲烷", 20},
        {"氧气", 20},
        {"氯气", 20},
    },
    results = {
        {"盐酸", 25},
        {"塑料", 1},
    },
    time = "4s",
    description = "化工原料合成塑料",
}

prototype "酸碱中和" {
    type = { "recipe" },
    category = "液体处理",
    group = "流体",
    order = 65,
    icon = "fluid/liquid.png",
    ingredients = {
        {"碱性溶液", 80},
        {"盐酸", 80},
    },
    results = {
        {"废水", 100},
    },
    time = "1s",
    description = "酸碱溶液中和成废水",
}

prototype "碱性溶液" {
    type = { "recipe" },
    category = "液体处理",
    group = "流体",
    order = 64,
    icon = "fluid/liquid.png",
    ingredients = {
        {"纯水", 80},
        {"氢氧化钠", 3},
    },
    results = {
        {"碱性溶液", 100},
    },
    time = "1s",
    description = "碱性原料融水制造碱性溶液",
}

prototype "废水排泄" {
    type = { "recipe" },
    category = "液体排泄",
    group = "流体",
    order = 100,
    icon = "fluid/liquid.png",
    ingredients = {
        {"废水", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "废水排泄",
}

prototype "海水排泄" {
    type = { "recipe" },
    category = "液体排泄",
    group = "流体",
    order = 101,
    icon = "fluid/liquid.png",
    ingredients = {
        {"海水", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "海水排泄",
}

prototype "纯水排泄" {
    type = { "recipe" },
    category = "液体排泄",
    group = "流体",
    order = 102,
    icon = "fluid/liquid.png",
    ingredients = {
        {"纯水", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "纯水排泄",
}

prototype "碱性溶液排泄" {
    type = { "recipe" },
    category = "液体排泄",
    group = "流体",
    order = 103,
    icon = "fluid/liquid.png",
    ingredients = {
        {"碱性溶液", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "碱性溶液排泄",
}

prototype "氮气排泄" {
    type = { "recipe" },
    category = "气体排泄",
    group = "流体",
    order = 104,
    icon = "fluid/gas.png",
    ingredients = {
        {"氮气", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "氮气排泄",
}

prototype "氧气排泄" {
    type = { "recipe" },
    category = "气体排泄",
    group = "流体",
    order = 105,
    icon = "fluid/gas.png",
    ingredients = {
        {"氧气", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "氧气排泄",
}

prototype "二氧化碳排泄" {
    type = { "recipe" },
    category = "气体排泄",
    group = "流体",
    order = 106,
    icon = "fluid/gas.png",
    ingredients = {
        {"二氧化碳", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "二氧化碳排泄",
}

prototype "氢气排泄" {
    type = { "recipe" },
    category = "气体排泄",
    group = "流体",
    order = 107,
    icon = "fluid/gas.png",
    ingredients = {
        {"氢气", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "氢气排泄",
}

prototype "蒸汽排泄" {
    type = { "recipe" },
    category = "气体排泄",
    group = "流体",
    order = 108,
    icon = "fluid/gas.png",
    ingredients = {
        {"蒸汽", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "蒸汽排泄",
}

prototype "甲烷排泄" {
    type = { "recipe" },
    category = "气体排泄",
    group = "流体",
    order = 109,
    icon = "fluid/gas.png",
    ingredients = {
        {"甲烷", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "甲烷排泄",
}

---------海水生成矿物配方----------
prototype "海水分离铁" {
    type = { "recipe" },
    category = "流体处理",
    group = "金属",
    order = 1,
    icon = "construct/iron.png",
    ingredients = {
        {"海水", 100},
    },
    results = {
        {"铁矿石", 2},
        {"碎石", 2},
        {"纯水", 50},
    },
    time = "3s",
    description = "海水中过滤铁矿石",
}

prototype "海水分离水藻" {
    type = { "recipe" },
    category = "流体处理",
    group = "金属",
    order = 2,
    icon = "construct/outfall.png",
    ingredients = {
        {"海水", 100},
    },
    results = {
        {"海藻", 2},
        {"沙子", 2},
        {"纯水", 50},
    },
    time = "3s",
    description = "海水中过滤水藻",
}

prototype "海水分离石头" {
    type = { "recipe" },
    category = "流体处理",
    group = "金属",
    order = 3,
    icon = "construct/gravel.png",
    ingredients = {
        {"海水", 100},
    },
    results = {
        {"石头", 4},
        {"沙子",1},
        {"碎石",1},
        {"纯水", 25},
    },
    time = "3s",
    description = "海水中过滤石头",
}

prototype "提炼纤维" {
    type = { "recipe" },
    category = "中型制造",
    group = "器件",
    order = 26,
    icon = "construct/industry.png",
    ingredients = {
        {"海藻", 4},
    },
    results = {
        {"纤维燃料", 1},
    },
    time = "2s",
    description = "海藻加工成纤维燃料",
}