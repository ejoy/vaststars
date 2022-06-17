local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


-- allow_manual：允许手工打造，默认为true。如果一个物品被禁止手工打造那么它也不会成为中间产物
-- allow_as_intermediate：允许在手工打造过程中作为中间产物，默认为true
-- results里面的第一个物品为主产物，只有主产物才可以被手工打造

prototype "铁锭" {
    type = { "recipe" },
    category = "金属冶炼",
    --group = "金属",
    order = 10,
    allow_manual = false,
    icon = "textures/construct/plate-Fe.texture",
    ingredients = {
        {"铁矿石", 3},
    },
    results = {
        {"铁锭", 1},
        {"碎石", 1}
    },
    time = "4s",
    description = "铁矿石通过金属冶炼获得铁锭",
}

prototype "铁板1" {
    type = { "recipe" },
    category = "金属冶炼",
    group = "金属",
    order = 11,
    allow_manual = false,
    icon = "textures/construct/plate-Fe.texture",
    ingredients = {
        {"铁矿石", 5},
    },
    results = {
        {"铁板", 2},
        -- {"碎石", 2},
    },
    time = "3s",
    description = "铁矿石通过金属冶炼获得铁板",
}

prototype "铁板2" {
    type = { "recipe" },
    category = "金属冶炼",
    --group = "金属",
    order = 12,
    allow_manual = false,
    icon = "textures/construct/plate-Fe.texture",
    ingredients = {
        {"碾碎铁矿石", 8},
        {"石墨", 1}
    },
    results = {
        {"铁板", 6},
        {"碎石", 2},
    },
    time = "15s",
    description = "使用碾碎铁矿石和石墨锻造铁板",
}

prototype "碾碎铁矿石" {
    type = { "recipe" },
    category = "矿石粉碎",
    --group = "金属",
    order = 14,
    allow_manual = false,
    icon = "textures/construct/crush-ore-Fe.texture",
    ingredients = {
        {"铁矿石", 8},
    },
    results = {
        {"碾碎铁矿石", 7},
        {"碎石", 1},
    },
    time = "6s",
    description = "使用氧化铝和石墨烧制铝板",
}

prototype "碾碎铝矿石" {
    type = { "recipe" },
    category = "矿石粉碎",
    --group = "金属",
    order = 14,
    allow_manual = false,
    icon = "textures/construct/crush-ore-Al.texture",
    ingredients = {
        {"铝矿石", 7},
    },
    results = {
        {"碾碎铝矿石", 5},
        {"沙子", 1},
        {"碾碎铁矿石", 1},
    },
    time = "5s",
    description = "使用氧化铝和石墨烧制铝板",
}

prototype "铝矿石浮选" {
    type = { "recipe" },
    category = "矿石浮选",
    --group = "金属",
    order = 14,
    icon = "textures/construct/iron-ingot.texture",
    ingredients = {
        {"碾碎铝矿石", 4},
        {"碱性溶液", 30}
    },
    results = {
        {"氢氧化铝", 3},
        {"废水", 12},
    },
    time = "5s",
    description = "使用氧化铝和石墨烧制铝板",
}

prototype "氧化铝" {
    type = { "recipe" },
    category = "金属冶炼",
    --group = "金属",
    order = 16,
    allow_manual = false,
    icon = "textures/construct/iron-ingot.texture",
    ingredients = {
        {"氢氧化铝", 4},
    },
    results = {
        {"氧化铝", 3},
    },
    time = "2s",
    description = "使用氧化铝和石墨烧制铝板",
}

prototype "铝板1" {
    type = { "recipe" },
    category = "金属冶炼",
    --group = "金属",
    order = 18,
    allow_manual = false,
    icon = "textures/construct/plate-Ai.texture",
    ingredients = {
        {"氧化铝", 9},
        {"石墨", 5}
    },
    results = {
        {"铝板", 3},
        {"碳化铝", 4},
    },
    time = "10s",
    description = "使用氧化铝和石墨烧制铝板",
}

prototype "铝棒1" {
    type = { "recipe" },
    category = "金属锻造",
    --group = "金属",
    order = 20,
    icon = "textures/construct/iron_stick.texture",
    ingredients = {
        {"铝板", 4},
    },
    results = {
        {"铝棒", 5}
    },
    time = "4s",
    description = "使用铝板锻造铝棒",
}

prototype "铝丝1" {
    type = { "recipe" },
    category = "金属锻造",
    --group = "金属",
    order = 22,
    icon = "textures/construct/iron-wire.texture",
    ingredients = {
        {"铝棒", 5},
    },
    results = {
        {"铝丝", 7}
    },
    time = "5s",
    description = "使用铝棒锻造铝丝",
}

prototype "铁棒1" {
    type = { "recipe" },
    category = "金属锻造",
    --group = "金属",
    order = 13,
    icon = "textures/construct/iron_stick.texture",
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
    --group = "金属",
    order = 14,
    icon = "textures/construct/iron-wire.texture",
    ingredients = {
        {"铁棒", 3},
    },
    results = {
        {"铁丝", 4}
    },
    time = "4s",
    description = "使用铁棒锻造铁丝",
}

prototype "沙子1" {
    type = { "recipe" },
    category = "矿石粉碎",
    --group = "金属",
    order = 40,
    allow_manual = false,
    icon = "textures/construct/sand.texture",
    ingredients = {
        {"碎石", 5},
    },
    results = {
        {"沙子", 3},
    },
    time = "4s",
    description = "粉碎沙石矿获得更微小的原材料",
}

prototype "石砖" {
    type = { "recipe" },
    category = "物流中型制造",
    group = "物流",
    order = 100,
    icon = "textures/construct/stone-brick.texture",
    ingredients = {
        {"碎石", 3},
    },
    results = {
        {"石砖", 1},
    },
    time = "3s",
    description = "使用碎石炼制石砖",
}

prototype "硅1" {
    type = { "recipe" },
    category = "矿石浮选",
    --group = "金属",
    order = 68,
    allow_manual = false,
    icon = "textures/construct/ore-Si.texture",
    ingredients = {
        {"沙子", 8},
    },
    results = {
        {"硅", 4},
    },
    time = "4s",
    description = "使用硅炼制玻璃",
}

prototype "玻璃" {
    type = { "recipe" },
    category = "器件中型制造",
    --group = "器件",
    order = 70,
    icon = "textures/construct/glass.texture",
    ingredients = {
        {"硅", 3},
    },
    results = {
        {"玻璃", 1},
    },
    time = "16s",
    description = "使用硅炼制玻璃",
}

prototype "坩埚" {
    type = { "recipe" },
    category = "金属冶炼",
    --group = "器件",
    order = 72,
    icon = "textures/construct/crucible.texture",
    ingredients = {
        {"硅", 15},
    },
    results = {
        {"坩埚", 1},
    },
    time = "30s",
    description = "使用硅烧制坩埚",
}

prototype "硅板1" {
    type = { "recipe" },
    category = "金属冶炼",
    --group = "金属",
    order = 68,
    allow_manual = false,
    icon = "textures/construct/plate-Si.texture",
    ingredients = {
        {"硅", 5},
        {"石墨", 2},
    },
    results = {
        {"硅板", 3},
    },
    time = "10s",
    description = "使用硅炼制硅板",
}

prototype "橡胶" {
    type = { "recipe" },
    category = "矿石浮选",
    --group = "器件",
    order = 76,
    icon = "textures/construct/rubber.texture",
    ingredients = {
        {"丁二烯", 15},
    },
    results = {
        {"橡胶", 1},
    },
    time = "3s",
    description = "使用丁二烯合成橡胶",
}

prototype "电动机1" {
    type = { "recipe" },
    category = "器件中型制造",
    group = "器件",
    order = 52,
    icon = "textures/construct/electric-motor.texture",
    ingredients = {
        -- {"铁棒", 1},
        -- {"铁丝", 2},
        {"铁板", 6},
        {"塑料", 1},
    },
    results = {
        {"电动机I", 1},
    },
    time = "8s",
    description = "铁制品和塑料打造初级电动机",
}

prototype "铁齿轮" {
    type = { "recipe" },
    category = "金属小型制造",
    group = "金属",
    order = 15,
    icon = "textures/construct/iron-gear.texture",
    ingredients = {
        {"铁板", 4},
    },
    results = {
        {"铁齿轮", 2},
    },
    time = "4s",
    description = "使用铁制品加工铁齿轮",
}

prototype "机器爪1" {
    type = { "recipe" },
    category = "物流小型制造",
    --group = "物流",
    order = 40,
    icon = "textures/construct/insert1.texture",
    ingredients = {
        -- {"铁棒", 3},
        {"铁板", 3},
        {"铁齿轮", 2},
        {"电动机I", 1},
    },
    results = {
        {"机器爪I", 3},
    },
    time = "5s",
    description = "铁制品和电动机制造机器爪",
}

prototype "砖石公路" {
    type = { "recipe" },
    category = "物流中型制造",
    --group = "物流",
    order = 104,
    icon = "textures/construct/road1.texture",
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
    category = "物流中型制造",
    --group = "物流",
    order = 51,
    icon = "textures/construct/manufacture.texture",
    ingredients = {
        {"机器爪I", 1},
        {"小铁制箱子I", 1},
    },
    results = {
        {"车站I", 1},
    },
    time = "4s",
    description = "使用机器爪和箱子制造车站",
}

prototype "物流中心1" {
    type = { "recipe" },
    category = "物流大型制造",
    --group = "物流",
    order = 52,
    icon = "textures/construct/logisitic1.texture",
    ingredients = {
        {"蒸汽发电机I", 1},
        {"车站I", 2},
        {"砖石公路-O型", 10},
    },
    results = {
        {"物流中心I", 1},
    },
    time = "10s",
    description = "发电设施和车载设备制造物流中心",
}

prototype "运输车辆1" {
    type = { "recipe" },
    category = "物流中型制造",
    --group = "物流",
    order = 53,
    icon = "textures/construct/truck.texture",
    ingredients = {
        {"电动机I", 1},
        {"塑料", 4},
        {"铁板", 8},
        {"玻璃", 4},
    },
    results = {
        {"运输车辆I", 1},
    },
    time = "5s",
    description = "电动机和铁制品制造汽车",
}

prototype "小铁制箱子1" {
    type = { "recipe" },
    category = "物流中型制造",
    group = "物流",
    order = 10,
    icon = "textures/construct/chest.texture",
    ingredients = {
        -- {"铁棒", 1},
        {"铁板", 10},
    },
    results = {
        {"小铁制箱子I", 1},
    },
    time = "2s",
    description = "使用铁制品制造箱子",
}

prototype "小铁制箱子2" {
    type = { "recipe" },
    category = "物流中型制造",
    group = "物流",
    order = 10,
    icon = "textures/construct/chest.texture",
    ingredients = {
        {"橡胶", 1},
        {"钢板", 6},
        {"小铁制箱子I", 1},
    },
    results = {
        {"小铁制箱子II", 1},
    },
    time = "3s",
    description = "使用铁制品制造箱子",
}

prototype "大铁制箱子1" {
    type = { "recipe" },
    category = "物流中型制造",
    group = "物流",
    order = 10,
    icon = "textures/construct/large-chest.texture",
    ingredients = {
        {"铝板", 4},
        {"小铁制箱子II", 5},
    },
    results = {
        {"大铁制箱子I", 1},
    },
    time = "5s",
    description = "使用铁制品制造箱子",
}

prototype "铁制电线杆" {
    type = { "recipe" },
    category = "物流中型制造",
    --group = "物流",
    order = 30,
    icon = "textures/construct/electric-pole1.texture",
    ingredients = {
        {"塑料", 1},
        {"铁板", 2},
        -- {"铁棒", 1},
        -- {"铁丝", 2},
    },
    results = {
        {"铁制电线杆", 1},
    },
    time = "2s",
    description = "导电材料制造电线杆",
}

prototype "采矿机1" {
    type = { "recipe" },
    category = "生产中型制造",
    --group = "生产",
    order = 40,
    icon = "textures/construct/miner.texture",
    ingredients = {
        {"铁板", 4},
        {"铁齿轮", 3},
        {"电动机I", 2},
    },
    results = {
        {"采矿机I", 2},
    },
    time = "6s",
    description = "使用铁制品和电动机制造采矿机",
}

prototype "采矿机2" {
    type = { "recipe" },
    category = "生产中型制造",
    --group = "生产",
    order = 40,
    icon = "textures/construct/miner.texture",
    ingredients = {
        {"钢板", 3},
        {"采矿机I", 2},
    },
    results = {
        {"采矿机II", 1},
    },
    time = "10s",
    description = "使用铁制品和电动机制造采矿机",
}

prototype "熔炼炉1" {
    type = { "recipe" },
    category = "生产中型制造",
    group = "生产",
    order = 50,
    icon = "textures/construct/furnace2.texture",
    ingredients = {
        {"铁板", 3},
        -- {"铁丝", 2},
        {"石砖", 4},
    },
    results = {
        {"熔炼炉I", 1},
    },
    time = "8s",
    description = "使用铁制品和石砖制造熔炼炉",
}

prototype "熔炼炉2" {
    type = { "recipe" },
    category = "生产中型制造",
    group = "生产",
    order = 51,
    icon = "textures/construct/furnace2.texture",
    ingredients = {
        {"钢板", 4},
        {"坩埚", 2},
        {"熔炼炉I", 1},
    },
    results = {
        {"熔炼炉II", 1},
    },
    time = "15s",
    description = "使用铁制品和石砖制造熔炼炉",
}

prototype "组装机1" {
    type = { "recipe" },
    category = "生产中型制造",
    --group = "生产",
    order = 70,
    icon = "textures/construct/assembler.texture",
    ingredients = {
        {"小铁制箱子I", 1},
        {"机器爪I", 1},
        {"铁齿轮", 4},
    },
    results = {
        {"组装机I", 1},
    },
    time = "6s",
    description = "机械原料制造组装机",
}

prototype "组装机2" {
    type = { "recipe" },
    category = "生产中型制造",
    --group = "生产",
    order = 70,
    icon = "textures/construct/assembler.texture",
    ingredients = {
        {"钢板", 2},
        {"组装机I", 2},
    },
    results = {
        {"组装机II", 1},
    },
    time = "10s",
    description = "机械原料制造组装机",
}

prototype "蒸汽发电机1" {
    type = { "recipe" },
    category = "化工大型制造",
    --group = "化工",
    order = 120,
    icon = "textures/construct/turbine1.texture",
    ingredients = {
        {"管道1-I型", 2},
        {"铁齿轮", 1},
        {"铁板", 8},
        {"电动机I", 1},
    },
    results = {
        {"蒸汽发电机I", 1},
    },
    time = "8s",
    description = "管道和机械原料制造蒸汽发电机",
}

prototype "风力发电机1" {
    type = { "recipe" },
    category = "生产大型制造",
    --group = "生产",
    order = 10,
    icon = "textures/construct/wind-turbine.texture",
    ingredients = {
        {"铁制电线杆", 3},
        {"蒸汽发电机I", 2},
    },
    results = {
        {"风力发电机I", 1},
    },
    time = "5s",
    description = "电传输材料和发电设施制造风力发电机",
}

prototype "液罐1" {
    type = { "recipe" },
    category = "化工大型制造",
    group = "化工",
    order = 22,
    icon = "textures/construct/tank1.texture",
    ingredients = {
        {"管道1-I型", 4},
        -- {"铁棒", 1},
        {"铁板", 6},
    },
    results = {
        {"液罐I", 1},
    },
    time = "6s",
    description = "管道和铁制品制造液罐",
}

prototype "化工厂1" {
    type = { "recipe" },
    category = "化工大型制造",
    --group = "化工",
    order = 80,
    icon = "textures/construct/chemistry2.texture",
    ingredients = {
        {"玻璃", 4},
        {"压力泵I", 1},
        {"液罐I", 2},
        {"组装机I", 1},
    },
    results = {
        {"化工厂I", 1},
    },
    time = "15s",
    description = "液体容器和加工设备制造化工厂",
}

prototype "铸造厂1" {
    type = { "recipe" },
    category = "生产大型制造",
    --group = "生产",
    order = 63,
    icon = "textures/construct/assembler.texture",
    ingredients = {
        {"铁板", 3},
        {"机器爪I", 2},
        {"熔炼炉I", 1},
    },
    results = {
        {"铸造厂I", 1},
    },
    time = "15s",
    description = "熔炼设备和机器爪制造铸造厂",
}

prototype "水电站1" {
    type = { "recipe" },
    category = "化工大型制造",
    --group = "化工",
    order = 70,
    icon = "textures/construct/hydroplant.texture",
    ingredients = {
        {"蒸馏厂I", 1},
        {"地下水挖掘机", 1},
    },
    results = {
        {"水电站I", 1},
    },
    time = "4s",
    description = "蒸馏设施和地下水挖掘机制造水电站",
}

prototype "蒸馏厂1" {
    type = { "recipe" },
    category = "化工大型制造",
    --group = "化工",
    order = 62,
    icon = "textures/construct/distillery.texture",
    ingredients = {
        {"烟囱I", 1},
        {"液罐I", 2},
        {"熔炼炉I", 1}, 
    },
    results = {
        {"蒸馏厂I", 1},
    },
    time = "4s",
    description = "液体容器和熔炼设备制造蒸馏厂",
}


prototype "烟囱1" {
    type = { "recipe" },
    category = "化工大型制造",
    group = "化工",
    order = 65,
    icon = "textures/construct/chimney2.texture",
    ingredients = {
        -- {"铁棒", 2},
        {"铁板", 2},
        {"管道1-I型", 3},
        {"石砖", 3},
    },
    results = {
        {"烟囱I", 1},
    },
    time = "4s",
    description = "铁制品和管道制造烟囱",
}

prototype "压力泵1" {
    type = { "recipe" },
    category = "化工中型制造",
    --group = "化工",
    order = 40,
    icon = "textures/construct/pump1.texture",
    ingredients = {
        {"电动机I", 1},
        {"管道1-I型", 4},
    },
    results = {
        {"压力泵I", 1},
    },
    time = "2s",
    description = "管道和电机制造压力泵",
}

prototype "地下水挖掘机" {
    type = { "recipe" },
    category = "化工中型制造",
    --group = "化工",
    order = 50,
    icon = "textures/construct/pumpjack1.texture",
    ingredients = {
        {"排水口I", 1},
        {"压力泵I", 1},
    },
    results = {
        {"地下水挖掘机", 1},
    },
    time = "4s",
    description = "排水设施和压力泵制造抽水泵",
}

prototype "空气过滤器1" {
    type = { "recipe" },
    category = "化工大型制造",
    --group = "化工",
    order = 60,
    icon = "textures/construct/air-filter1.texture",
    ingredients = {
        {"压力泵I", 1},
        {"塑料", 4},
        {"蒸汽发电机I", 1},
    },
    results = {
        {"空气过滤器I", 1},
    },
    time = "8s",
    description = "压力泵和发电设施制造空气过滤器",
}

prototype "排水口1" {
    type = { "recipe" },
    category = "化工大型制造",
    --group = "化工",
    order = 56,
    icon = "textures/construct/outfall.texture",
    ingredients = {
        {"管道1-I型", 5},
        {"地下管I", 1},
    },
    results = {
        {"排水口I", 1},
    },
    time = "4s",
    description = "管道制造排水口",
}

prototype "管道1" {
    type = { "recipe" },
    category = "化工小型制造",
    group = "化工",
    order = 10,
    icon = "textures/construct/pipe.texture",
    ingredients = {
        {"铁板", 2},
    },
    results = {
        {"管道1-I型", 2},
    },
    time = "6s",
    description = "石砖制造管道",
}

prototype "管道2" {
    type = { "recipe" },
    category = "化工小型制造",
    group = "化工",
    order = 10,
    allow_as_intermediate = false,
    icon = "textures/construct/pipe.texture",
    ingredients = {
        {"石砖", 8},
    },
    results = {
        {"管道1-I型", 5},
        {"碎石", 1},
    },
    time = "6s",
    description = "石砖制造管道",
}

prototype "地下管1" {
    type = { "recipe" },
    category = "化工小型制造",
    --group = "化工",
    order = 12,
    icon = "textures/construct/pipe.texture",
    ingredients = {
        {"管道1-I型", 5},
        {"沙子", 2},
    },
    results = {
        {"地下管I", 2},
    },
    time = "5s",
    description = "管道和沙子制造地下管道",
}

prototype "地下管2" {
    type = { "recipe" },
    category = "化工小型制造",
    --group = "化工",
    order = 14,
    icon = "textures/construct/pipe.texture",
    ingredients = {
        {"地下管I", 1},
        {"钢板", 3},
        {"碎石", 2},
    },
    results = {
        {"地下管II", 2},
    },
    time = "5s",
    description = "管道和钢板制造地下管道",
}

prototype "粉碎机1" {
    type = { "recipe" },
    category = "生产大型制造",
    --group = "生产",
    order = 60,
    icon = "textures/construct/crusher1.texture",
    ingredients = {
        -- {"铁丝", 4},
        {"铁板", 4},
        {"石砖", 8},
        {"采矿机I", 1},
    },
    results = {
        {"粉碎机I", 1},
    },
    time = "5s",
    description = "石砖和采矿机制造粉碎机",
}

prototype "电解厂1" {
    type = { "recipe" },
    category = "化工大型制造",
    --group = "化工",
    order = 90,
    icon = "textures/construct/electrolysis1.texture",
    ingredients = {
        {"液罐I", 4},
        {"铁制电线杆", 8},
    },
    results = {
        {"电解厂I", 1},
    },
    time = "10s",
    description = "液体容器和电传输设备制造电解厂",
}

prototype "浮选器1" {
    type = { "recipe" },
    category = "生产大型制造",
    --group = "生产",
    order = 64,
    icon = "textures/construct/flotation-cell.texture",
    ingredients = {
        {"粉碎机I", 1},
        {"水电站I", 1},
    },
    results = {
        {"浮选器I", 1},
    },
    time = "5s",
    description = "将矿石浮沉进行筛选",
}


prototype "科研中心1" {
    type = { "recipe" },
    category = "生产大型制造",
    --group = "生产",
    order = 80,
    icon = "textures/property/research-packs.texture",
    ingredients = {
        {"机器爪I", 4},
        {"铁板", 20},
        {"电动机I", 1},
        {"玻璃", 4}, 
    },
    results = {
        {"科研中心I", 1},
    },
    time = "10s",
    description = "机械装置和电动机制造科研中心",
}


prototype "破损水电站" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 110,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-hydroplant.texture",
    ingredients = {
        {"管道1-I型", 6},
        {"破损水电站", 1},
    },
    results = {
        {"水电站I", 1},
    },
    time = "4s",
    description = "修复损坏的水电站",
}

prototype "破损空气过滤器" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 111,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-air-filter1.texture",
    ingredients = {
        {"石砖", 4},
        {"铁板", 8},
        {"破损空气过滤器", 1},
    },
    results = {
        {"空气过滤器I", 1},
    },
    time = "3s",
    description = "修复损坏的空气过滤器",
}

prototype "破损地下水挖掘机" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 112,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-pump.texture",
    ingredients = {
        {"铁板", 8},
        {"破损地下水挖掘机", 1},
    },
    results = {
        {"地下水挖掘机", 1},
    },
    time = "3s",
    description = "修复损坏的空气过滤器",
}

prototype "破损电解厂" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 114,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-electrolysis1.texture",
    ingredients = {
        {"石砖", 10},
        {"铁板", 10},
        {"破损电解厂", 1},
    },
    results = {
        {"电解厂I", 1},
    },
    time = "6s",
    description = "修复损坏的电解厂",
}

prototype "破损化工厂" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 116,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-chemistry2.texture",
    ingredients = {
        {"小铁制箱子I", 2},
        {"石砖", 10},
        {"破损化工厂", 1},
    },
    results = {
        {"化工厂I", 1},
    },
    time = "5s",
    description = "修复损坏的化工厂",
}

prototype "破损组装机" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 118,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-assembler.texture",
    ingredients = {
        -- {"铁丝", 6},
        {"石砖", 8},
        {"铁板", 12},
        {"破损组装机", 1},
    },
    results = {
        {"组装机I", 1},
    },
    time = "3s",
    description = "修复损坏的组装机",
}

prototype "破损铁制电线杆" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 120,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-electric-pole1.texture",
    ingredients = {
        -- {"铁棒", 2},
        {"铁板", 2},
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
    category = "生产手工制造",
    group = "生产",
    order = 122,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-solar-panel.texture",
    ingredients = {
        {"铁板", 10},
        {"石砖", 10},
        {"破损太阳能板", 1},
    },
    results = {
        {"太阳能板I", 1},
    },
    time = "8s",
    description = "修复损坏的太阳能板",
}

prototype "破损蓄电池" {
    type = { "recipe" },
    category = "生产手工制造",
    group = "生产",
    order = 124,
    allow_as_intermediate = false,
    icon = "textures/construct/broken-grid-battery.texture",
    ingredients = {
        {"铁板", 8},
        {"破损蓄电池", 1},
    },
    results = {
        {"蓄电池I", 1},
    },
    time = "6s",
    description = "修复损坏的蓄电池",
}

prototype "破损物流中心" {
    type = { "recipe" },
    category = "生产手工制造",
    --group = "生产",
    order = 126,
    allow_as_intermediate = false,
    icon = "textures/construct/logisitic1.texture",
    ingredients = {
        {"铁板", 5},
        {"破损物流中心", 1},
    },
    results = {
        {"物流中心I", 1},
    },
    time = "6s",
    description = "修复损坏的物流中心",
}

prototype "破损运输汽车" {
    type = { "recipe" },
    category = "生产手工制造",
    --group = "生产",
    order = 128,
    allow_as_intermediate = false,
    icon = "textures/construct/truck.texture",
    ingredients = {
        -- {"铁丝", 10},
        {"铁板", 10},
        {"破损运输车辆", 1},
    },
    results = {
        {"运输车辆I", 1},
    },
    time = "4s",
    description = "修复损坏的运输汽车",
}

prototype "破损车站" {
    type = { "recipe" },
    category = "生产手工制造",
    --group = "生产",
    order = 130,
    allow_as_intermediate = false,
    icon = "textures/construct/manufacture.texture",
    ingredients = {
        -- {"铁棒", 6},
        {"铁板", 6},
        {"破损车站", 1},
    },
    results = {
        {"车站I", 1},
    },
    time = "5s",
    description = "修复损坏的车站",
}

prototype "地质科技包1" {
    type = { "recipe" },
    category = "器件小型制造",
    group = "器件",
    order = 80,
    icon = "textures/recipe/geology-pack.texture",
    ingredients = {
        {"铁矿石", 2},
        {"碎石", 2},
    },
    results = {
        {"地质科技包", 1},
    },
    time = "15s",
    description = "地质材料制造地质科技包",
}

prototype "气候科技包1" {
    type = { "recipe" },
    category = "器件液体处理",
    group = "器件",
    order = 82,
    icon = "textures/recipe/climatology-pack.texture",
    ingredients = {
        {"地下卤水", 2000},
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
    category = "器件中型制造",
    group = "器件",
    order = 84,
    icon = "textures/recipe/mechanical-pack.texture",
    ingredients = {
        {"电动机I", 1},
        {"铁齿轮", 3},
    },
    results = {
        {"机械科技包", 1},
    },
    time = "15s",
    description = "机械原料制造机械科技包",
}

prototype "电子科技包1" {
    type = { "recipe" },
    category = "器件中型制造",
    group = "器件",
    order = 84,
    icon = "textures/recipe/electrical-pack.texture",
    ingredients = {
        {"电容", 1},
        {"绝缘线", 2},
        {"逻辑电路", 1},
    },
    results = {
        {"电子科技包", 1},
    },
    time = "12s",
    description = "电子元件制造电子科技包",
}

prototype "铁矿石挖掘" {
    type = { "recipe" },
    category = "金属冶炼",
    --group = "金属",
    allow_manual = false,
    order = 20,
    icon = "textures/construct/air-filter1.texture",
    ingredients = {
    },
    results = {
        {"铁矿石", 1},
        {"碎石", 1},
    },
    time = "3s",
    description = "采集铁矿石",
}

prototype "绝缘线1" {
    type = { "recipe" },
    category = "器件小型制造",
    group = "器件",
    order = 82,
    icon = "textures/construct/insulated-wire.texture",
    ingredients = {
        {"橡胶", 2},
        {"铝丝", 3},
    },
    results = {
        {"绝缘线", 4},
    },
    time = "4s",
    description = "生产外部绝缘的导线",
}

prototype "电容1" {
    type = { "recipe" },
    category = "金属锻造",
    --group = "金属",
    order = 84,
    icon = "textures/construct/capacitor.texture",
    ingredients = {
        {"石墨", 1},
        {"氧化铝", 1},
        {"塑料", 3},
        {"铝板", 2},
    },
    results = {
        {"电容", 2}
    },
    time = "5s",
    description = "生产电子元器件电容",
}

prototype "逻辑电路1" {
    type = { "recipe" },
    category = "器件小型制造",
    group = "器件",
    order = 86,
    icon = "textures/construct/logic-circuit.texture",
    ingredients = {
        {"石墨", 1},
        {"铝丝", 4},
        {"塑料", 3},
        {"硅板", 3},
    },
    results = {
        {"逻辑电路", 3},
    },
    time = "5s",
    description = "生产电子元器件逻辑电路",
}

prototype "空气过滤" {
    type = { "recipe" },
    category = "过滤",
    --group = "流体",
    order = 20,
    icon = "textures/construct/air-filter1.texture",
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
    --group = "流体",
    order = 10,
    icon = "textures/construct/hydroplant.texture",
    ingredients = {
    },
    results = {
        {"地下卤水", 120},
    },
    time = "0.1s",
    description = "抽取地表下的地下卤水",
}


prototype "空气分离1" {
    type = { "recipe" },
    category = "过滤",
    group = "流体",
    order = 11,
    icon = "textures/fluid/gas-seperate.texture",
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

prototype "二氧化碳转一氧化碳" {
    type = { "recipe" },
    category = "流体基础化工",
    group = "流体",
    order = 31,
    icon = "textures/fluid/gas-co.texture",
    ingredients = {
        {"二氧化碳", 40},
        {"氢气", 40},
    },
    results = {
        {"一氧化碳", 25},
        {"纯水", 8},
    },
    time = "1s",
    description = "二氧化碳转一氧化碳",
}

prototype "二氧化碳转甲烷" {
    type = { "recipe" },
    category = "流体基础化工",
    group = "流体",
    order = 34,
    icon = "textures/fluid/gas-ch4.texture",
    ingredients = {
        {"二氧化碳", 32},
        {"氢气", 110},
    },
    results = {
        {"甲烷", 24},
        {"纯水", 10},
    },
    time = "1s",
    description = "二氧化碳转甲烷",
}

prototype "一氧化碳转石墨" {
    type = { "recipe" },
    category = "器件基础化工",
    --group = "器件",
    order = 10,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"一氧化碳", 28},
        {"氢气", 36},
    },
    results = {
        {"石墨", 1},
        {"纯水", 5},
    },
    time = "2s",
    description = "一氧化碳转石墨",
}

prototype "盐酸" {
    type = { "recipe" },
    category = "流体基础化工",
    --group = "流体",
    order = 60,
    icon = "textures/fluid/liquid-hydrochloric.texture",
    ingredients = {
        {"氯气", 30},
        {"氢气", 30},
    },
    results = {
        {"盐酸", 60},
    },
    time = "1s",
    description = "氢气和氯气化合成盐酸",
}

prototype "润滑油" {
    type = { "recipe" },
    category = "流体基础化工",
    --group = "流体",
    order = 60,
    icon = "textures/fluid/lubricant.texture",
    ingredients = {
        {"硅板", 1},
        {"盐酸", 50},
    },
    results = {
        {"润滑油", 10},
    },
    time = "4s",
    description = "盐酸和硅板合成润滑油",
}

prototype "地下卤水电解" {
    type = { "recipe" },
    category = "电解",
    group = "流体",
    order = 15,
    icon = "textures/fluid/brine-electrolysis.texture",
    ingredients = {
        {"地下卤水", 45},
    },
    results = {
        {"氧气", 45},
        {"氢气", 110},
        {"氯气", 14},
        {"氢氧化钠", 1},
    },
    time = "1s",
    description = "卤水电解成氧气、氢气和氯气",
}

prototype "地下卤水净化" {
    type = { "recipe" },
    category = "流体基础化工",
    group = "流体",
    order = 15,
    icon = "textures/fluid/liquid-purify.texture",
    ingredients = {
        {"地下卤水", 100},
    },
    results = {
        {"纯水", 70},
        {"废水", 30},
    },
    time = "1s",
    description = "卤水净化成纯水",
}

prototype "地下卤水电解-backup" {
    type = { "recipe" },
    category = "电解",
    --group = "流体",
    order = 15,
    icon = "textures/fluid/liquid-electrolysis.texture",
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

prototype "纯水电解" {
    type = { "recipe" },
    category = "电解",
    group = "流体",
    order = 15,
    icon = "textures/fluid/water-electrolysis.texture",
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
    category = "流体基础化工",
    group = "流体",
    order = 36,
    icon = "textures/fluid/gas-ethene.texture",
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

prototype "乙烯转丁二烯" {
    type = { "recipe" },
    category = "流体基础化工",
    group = "流体",
    order = 38,
    icon = "textures/fluid/gas-butadiene.texture",
    ingredients = {
        {"乙烯", 50},
        {"蒸汽", 150},
    },
    results = {
        {"丁二烯", 20},
        {"氢气", 30},
    },
    time = "1s",
    description = "甲烷转乙烯",
}

prototype "纯水转蒸汽" {
    type = { "recipe" },
    category = "流体基础化工",
    --group = "流体",
    order = 112,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"纯水", 70},
    },
    results = {
        {"蒸汽", 270},
    },
    time = "1s",
    description = "蒸汽排泄",
}

prototype "塑料1" {
    type = { "recipe" },
    category = "器件基础化工",
    group = "器件",
    order = 20,
    icon = "textures/construct/plastic.texture",
    ingredients = {
        {"氯气", 30},
        {"乙烯", 30},
    },
    results = {
        {"塑料", 1},
        {"盐酸", 20},
    },
    time = "3s",
    description = "化工原料合成塑料",
}

prototype "塑料2" {
    type = { "recipe" },
    category = "器件基础化工",
    --group = "器件",
    order = 21,
    icon = "textures/construct/processor.texture",
    ingredients = {
        {"甲烷", 20},
        {"氧气", 20},
        {"氯气", 20},
    },
    results = {
        {"塑料", 1},
        {"盐酸", 25},
    },
    time = "4s",
    description = "化工原料合成塑料",
}

prototype "酸碱中和" {
    type = { "recipe" },
    category = "流体液体处理",
    --group = "流体",
    order = 65,
    icon = "textures/fluid/liquid.texture",
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
    category = "流体基础化工",
    --group = "流体",
    order = 64,
    icon = "textures/fluid/liquid.texture",
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

prototype "钢板1" {
    type = { "recipe" },
    category = "金属锻造",
    group = "金属",
    order = 20,
    icon = "textures/construct/steel-beam.texture",
    ingredients = {
        {"铁板", 5},
        {"氧气", 60},
    },
    results = {
        {"钢板", 2},
        {"二氧化碳", 25},
        -- {"碎石", 1},
    },
    time = "12s",
    description = "铁板通过金属冶炼获得钢板",
}

prototype "钢齿轮" {
    type = { "recipe" },
    category = "金属小型制造",
    group = "金属",
    order = 22,
    allow_manual = false,
    icon = "textures/construct/iron-gear.texture",
    ingredients = {
        {"钢板", 3},
    },
    results = {
        {"钢齿轮", 2},
    },
    time = "6s",
    description = "使用钢制品加工钢齿轮",
}

prototype "铁矿石回收" {
    type = { "recipe" },
    category = "矿石粉碎",
    allow_manual = false,
    --group = "金属",
    order = 104,
    icon = "textures/fluid/liquid.texture",
    ingredients = {
        {"碾碎铁矿石", 4},
    },
    results = {
        {"碎石", 3},
    },
    time = "2s",
    description = "铁矿石回收",
}

prototype "碎石回收" {
    type = { "recipe" },
    category = "矿石浮选",
    allow_manual = false,
    --group = "金属",
    order = 106,
    icon = "textures/fluid/liquid.texture",
    ingredients = {
        {"碎石", 4},
    },
    results = {
        {"废料", 3},
    },
    time = "2s",
    description = "碎石回收",
}

prototype "沙子回收" {
    type = { "recipe" },
    category = "流体液体处理",
    --group = "金属",
    order = 102,
    icon = "textures/fluid/liquid.texture",
    ingredients = {
        {"地下卤水", 80},
        {"沙子", 4},
    },
    results = {
        {"废水", 100},
    },
    time = "1s",
    description = "沙子排泄",
}

prototype "废料中和" {
    type = { "recipe" },
    category = "流体液体排泄",
    --group = "金属",
    order = 102,
    icon = "textures/fluid/liquid.texture",
    ingredients = {
        {"盐酸", 10},
        {"废料", 1},
    },
    results = {
        {"废水", 6},
        {"二氧化碳", 5},
    },
    time = "1s",
    description = "废料中和",
}

prototype "地下卤水排泄" {
    type = { "recipe" },
    category = "流体液体排泄",
    --group = "流体",
    order = 101,
    icon = "textures/fluid/liquid.texture",
    ingredients = {
        {"地下卤水", 100},
    },
    results = {
    },
    time = "1s",
    description = "地下卤水排泄",
}

prototype "纯水排泄" {
    type = { "recipe" },
    category = "流体液体排泄",
    --group = "流体",
    order = 102,
    icon = "textures/fluid/liquid.texture",
    ingredients = {
        {"纯水", 100},
    },
    results = {
    },
    time = "1s",
    description = "纯水排泄",
}

prototype "碱性溶液排泄" {
    type = { "recipe" },
    category = "流体液体排泄",
    --group = "流体",
    order = 103,
    icon = "textures/fluid/liquid.texture",
    ingredients = {
        {"碱性溶液", 100},
    },
    results = {
    },
    time = "1s",
    description = "碱性溶液排泄",
}

prototype "氮气排泄" {
    type = { "recipe" },
    category = "流体气体排泄",
    --group = "流体",
    order = 104,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"氮气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氮气排泄",
}

prototype "氧气排泄" {
    type = { "recipe" },
    category = "流体气体排泄",
    --group = "流体",
    order = 105,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"氧气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氧气排泄",
}

prototype "二氧化碳排泄" {
    type = { "recipe" },
    category = "流体气体排泄",
    --group = "流体",
    order = 106,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"二氧化碳", 100},
    },
    results = {
    },
    time = "1s",
    description = "二氧化碳排泄",
}

prototype "氢气排泄" {
    type = { "recipe" },
    category = "流体气体排泄",
    --group = "流体",
    order = 107,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"氢气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氢气排泄",
}


prototype "蒸汽排泄" {
    type = { "recipe" },
    category = "流体气体排泄",
    --group = "流体",
    order = 108,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"蒸汽", 100},
    },
    results = {
    },
    time = "1s",
    description = "蒸汽排泄",
}

prototype "甲烷排泄" {
    type = { "recipe" },
    category = "流体气体排泄",
    --group = "流体",
    order = 109,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"甲烷", 100},
    },
    results = {
    },
    time = "1s",
    description = "甲烷排泄",
}

prototype "废水排泄" {
    type = { "recipe" },
    category = "流体液体排泄",
    --group = "流体",
    order = 109,
    icon = "textures/fluid/liquid-wastewater.texture",
    ingredients = {
        {"废水", 100},
    },
    results = {
    },
    time = "1s",
    description = "废水排泄",
}

prototype "氯气排泄" {
    type = { "recipe" },
    category = "流体气体排泄",
    --group = "流体",
    order = 110,
    icon = "textures/fluid/gas.texture",
    ingredients = {
        {"氯气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氢气排泄",
}
---------地下卤水生成矿物配方----------
prototype "地下卤水分离铁" {
    type = { "recipe" },
    category = "金属流体处理",
    --group = "金属",
    order = 1,
    -- icon = "textures/construct/gravel.texture",
    icon = "textures/recipe/water2iron.texture",
    ingredients = {
        {"地下卤水", 100},
    },
    results = {
        {"铁矿石", 2},
        {"纯水", 50},
    },
    time = "3s",
    description = "地下卤水中分离铁矿石",
}

prototype "地下卤水分离水藻" {
    type = { "recipe" },
    category = "金属流体处理",
    --group = "金属",
    order = 2,
    icon = "textures/construct/gravel.texture",
    ingredients = {
        {"地下卤水", 100},
    },
    results = {
        {"海藻", 2},
        {"沙子", 2},
        {"纯水", 50},
    },
    time = "3s",
    description = "地下卤水中分离水藻",
}

prototype "地下卤水分离石头" {
    type = { "recipe" },
    category = "金属流体处理",
    --group = "金属",
    order = 3,
    -- icon = "textures/construct/gravel.texture",
    icon = "textures/recipe/water2gravel.texture",
    ingredients = {
        {"地下卤水", 100},
    },
    results = {
        {"碎石",2},
    },
    time = "3s",
    description = "地下卤水中分离石头",
}

prototype "提炼纤维" {
    type = { "recipe" },
    category = "器件中型制造",
    --group = "器件",
    order = 26,
    icon = "textures/construct/industry.texture",
    ingredients = {
        {"海藻", 4},
    },
    results = {
        {"纤维燃料", 1},
    },
    time = "2s",
    description = "海藻加工成纤维燃料",
}