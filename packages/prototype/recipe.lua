local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁锭" {
    type = { "recipe" },
    category = "金属冶炼",
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
    ingredients = {
        {"铁锭", 4},
    },
    results = {
        {"铁棒", 5}
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "铁丝1" {
    type = { "recipe" },
    category = "金属锻造",
    ingredients = {
        {"铁棒", 3},
    },
    results = {
        {"铁丝", 4}
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "沙石粉碎" {
    type = { "recipe" },
    category = "矿石粉碎",
    ingredients = {
        {"沙石矿", 5},
    },
    results = {
        {"沙子", 3},
        {"碎石", 2},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "石砖" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"碎石", 4},
    },
    results = {
        {"石砖", 2},
    },
    time = "3s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "玻璃" {
    type = { "recipe" },
    category = "金属锻造",
    ingredients = {
        {"硅", 3},
    },
    results = {
        {"玻璃", 1},
    },
    time = "16s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "电动机1" {
    type = { "recipe" },
    category = "中型制造",
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
    description = "使用铁锭和碎石锻造铁板",
}

prototype "铁齿轮" {
    type = { "recipe" },
    category = "小型制造",
    ingredients = {
        {"铁棒", 1},
        {"铁板", 2},
    },
    results = {
        {"铁齿轮", 2},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "机器爪1" {
    type = { "recipe" },
    category = "小型制造",
    ingredients = {
        {"铁棒", 3},
        {"铁齿轮", 2},
        {"电动机1", 1},
    },
    results = {
        {"机器爪1", 3},
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "砖石公路" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"石砖", 8},
    },
    results = {
        {"砖石公路", 4},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "车站1" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"机器爪1", 1},
        {"小型铁制箱子", 1},
    },
    results = {
        {"车站1", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "小型铁制箱子" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"铁棒", 1},
        {"铁板", 8},
    },
    results = {
        {"小型铁制箱子", 1},
    },
    time = "3s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "采矿机1" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"铁板", 4},
        {"铁齿轮", 3},
        {"电动机1", 2},
    },
    results = {
        {"采矿机1", 2},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "熔炼炉1" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"铁板", 1},
        {"铁丝", 2},
        {"石砖", 4},
    },
    results = {
        {"熔炼炉1", 1},
    },
    time = "8s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "组装机1" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"小型铁制箱子", 1},
        {"机器爪1", 1},
        {"铁齿轮", 4},
    },
    results = {
        {"熔炼炉1", 1},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "蒸汽发电机1" {
    type = { "recipe" },
    category = "大型制造",
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
    description = "使用铁锭和碎石锻造铁板",
}

prototype "风力发电机1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"铁制电线杆", 3},
        {"蒸汽发电机1", 2},
    },
    results = {
        {"风力发电机1", 1},
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "铁制电线杆" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"塑料", 1},
        {"铁棒", 1},
        {"铁丝", 2},
    },
    results = {
        {"铁制电线杆", 1},
    },
    time = "2s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "液罐1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"管道1", 4},
        {"铁棒", 1},
        {"铁板", 6},
    },
    results = {
        {"液罐1", 1},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "化工厂1" {
    type = { "recipe" },
    category = "大型制造",
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
    description = "使用铁锭和碎石锻造铁板",
}

prototype "铸造厂1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"铁板", 3},
        {"机器爪1", 2},
        {"熔炼炉1", 1},
    },
    results = {
        {"铸造厂1", 1},
    },
    time = "15s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "水电站1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"蒸馏厂1", 1},
        {"抽水泵", 1},
    },
    results = {
        {"水电站1", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "蒸馏厂1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"烟囱1", 1},
        {"液罐1", 2},
        {"熔炼炉1", 1}, 
    },
    results = {
        {"蒸馏厂1", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}


prototype "烟囱1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"铁棒", 2},
        {"管道1", 3},
        {"石砖", 3},
    },
    results = {
        {"烟囱1", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "压力泵1" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"电动机1", 1},
        {"管道1", 4},
    },
    results = {
        {"压力泵1", 1},
    },
    time = "2s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "抽水泵" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"排水口1", 1},
        {"压力泵1", 1},
    },
    results = {
        {"抽水泵", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "空气过滤器1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"压力泵1", 1},
        {"塑料", 4},
        {"蒸汽发电机1", 4},
    },
    results = {
        {"空气过滤器1", 1},
    },
    time = "8s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "排水口1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"管道1", 5},
        {"地下管1", 1},
    },
    results = {
        {"排水口1", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "管道1" {
    type = { "recipe" },
    category = "小型制造",
    ingredients = {
        {"石砖", 8},
    },
    results = {
        {"管道1", 5},
        {"碎石", 1},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "地下管1" {
    type = { "recipe" },
    category = "小型制造",
    ingredients = {
        {"管道1", 5},
        {"沙子", 2},
    },
    results = {
        {"地下管1", 2},
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "粉碎机1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"铁丝", 4},
        {"石砖", 8},
        {"采矿机1", 1},
    },
    results = {
        {"粉碎机1", 1},
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "物流中心1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"蒸汽发电机1", 1},
        {"车站1", 2},
        {"砖石公路", 10},
    },
    results = {
        {"物流中心1", 1},
    },
    time = "10s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "运输车辆1" {
    type = { "recipe" },
    category = "中型制造",
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
    description = "使用铁锭和碎石锻造铁板",
}

prototype "电解厂1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"液罐1", 4},
        {"铁制电线杆", 8},
    },
    results = {
        {"电解厂1", 1},
    },
    time = "10s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "科研中心1" {
    type = { "recipe" },
    category = "大型制造",
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
    description = "使用铁锭和碎石锻造铁板",
}


prototype "破损水电站" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"管道1", 4},
        {"破损水电站", 1},
    },
    results = {
        {"水电站1", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损空气过滤器" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"铁板", 4},
        {"破损空气过滤器", 1},
    },
    results = {
        {"空气过滤器1", 1},
    },
    time = "3s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损电解厂" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"铁丝", 5},
        {"破损电解厂", 1},
    },
    results = {
        {"电解厂1", 1},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损化工厂" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"压力泵1", 1},
        {"破损化工厂", 1},
    },
    results = {
        {"化工厂1", 1},
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损组装机" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"铁齿轮", 2},
        {"破损组装机", 1},
    },
    results = {
        {"组装机1", 1},
    },
    time = "3s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损铁制电线杆" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"铁棒", 2},
        {"破损铁制电线杆", 1},
    },
    results = {
        {"铁制电线杆", 1},
    },
    time = "2s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损太阳能板" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"沙子", 1},
        {"破损太阳能板", 1},
    },
    results = {
        {"太阳能板1", 1},
    },
    time = "8s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损蓄电池" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"石墨", 1},
        {"破损蓄电池", 1},
    },
    results = {
        {"蓄电池1", 1},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损物流中心" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"铁板", 5},
        {"破损物流中心", 1},
    },
    results = {
        {"物流中心1", 1},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损运输汽车" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"铁丝", 10},
        {"破损运输车辆", 1},
    },
    results = {
        {"运输车辆1", 1},
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "破损车站" {
    type = { "recipe" },
    category = "手工制造",
    ingredients = {
        {"铁棒", 6},
        {"破损车站", 1},
    },
    results = {
        {"车站1", 1},
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "地质科技包1" {
    type = { "recipe" },
    category = "小型制造",
    ingredients = {
        {"铁矿石", 2},
        {"沙石矿", 2},
    },
    results = {
        {"地质科技包", 1},
    },
    time = "15s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "气候科技包1" {
    type = { "recipe" },
    category = "液体处理",
    ingredients = {
        {"海水", 2000},
        {"空气", 3000},
    },
    results = {
        {"气候科技包", 1},
    },
    time = "25s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "机械科技包1" {
    type = { "recipe" },
    category = "中型制造",
    ingredients = {
        {"电动机1", 1},
        {"铁齿轮", 3},
    },
    results = {
        {"机械科技包", 1},
    },
    time = "15s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "空气过滤" {
    type = { "recipe" },
    ingredients = {
    },
    results = {
        {"空气", 50},
    },
    time = "1s",
}

prototype "离岸抽水" {
    type = { "recipe" },
    ingredients = {
    },
    results = {
        {"海水", 1200},
    },
    time = "1s",
}


prototype "空气分离1" {
    type = { "recipe" },
    category = "过滤",
    ingredients = {
        {"空气", 150},
    },
    results = {
        {"氮气", 90},
        {"二氧化碳", 40},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "海水电解" {
    type = { "recipe" },
    category = "电解",
    ingredients = {
        {"海水", 40},
    },
    results = {
        {"氢气", 110},
        {"氯气", 15},
        {"氢氧化钠", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "二氧化碳转一氧化碳" {
    type = { "recipe" },
    category = "基础化工",
    ingredients = {
        {"二氧化碳", 40},
        {"氢气", 40},
    },
    results = {
        {"纯水", 8},
        {"一氧化碳", 25},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "二氧化碳转甲烷" {
    type = { "recipe" },
    category = "基础化工",
    ingredients = {
        {"二氧化碳", 32},
        {"氢气", 110},
    },
    results = {
        {"纯水", 10},
        {"甲烷", 24},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "一氧化碳转石墨" {
    type = { "recipe" },
    category = "基础化工",
    ingredients = {
        {"一氧化碳", 28},
        {"氢气", 36},
    },
    results = {
        {"纯水", 5},
        {"石墨", 1},
    },
    time = "2s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "氯化氢" {
    type = { "recipe" },
    category = "基础化工",
    ingredients = {
        {"氯气", 30},
        {"氢气", 30},
    },
    results = {
        {"盐酸", 60},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "纯水电解" {
    type = { "recipe" },
    category = "电解",
    ingredients = {
        {"纯水", 45},
    },
    results = {
        {"氧气", 70},
        {"氢气", 140},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "甲烷转乙烯" {
    type = { "recipe" },
    category = "基础化工",
    ingredients = {
        {"甲烷", 40},
        {"氧气", 40},
    },
    results = {
        {"乙烯", 16},
        {"纯水", 8},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "塑料1" {
    type = { "recipe" },
    category = "基础化工",
    ingredients = {
        {"乙烯", 30},
        {"氯气", 30},
    },
    results = {
        {"盐酸", 20},
        {"塑料", 1},
    },
    time = "3s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "塑料2" {
    type = { "recipe" },
    category = "基础化工",
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
    description = "使用铁锭和碎石锻造铁板",
}

prototype "酸碱中和" {
    type = { "recipe" },
    category = "液体处理",
    ingredients = {
        {"碱性溶液", 80},
        {"盐酸", 80},
    },
    results = {
        {"废水", 100},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "碱性溶液" {
    type = { "recipe" },
    category = "液体处理",
    ingredients = {
        {"纯水", 80},
        {"氢氧化钠", 3},
    },
    results = {
        {"碱性溶液", 100},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "废水排泄" {
    type = { "recipe" },
    category = "液体排泄",
    ingredients = {
        {"废水", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "海水排泄" {
    type = { "recipe" },
    category = "液体排泄",
    ingredients = {
        {"海水", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "纯水排泄" {
    type = { "recipe" },
    category = "液体排泄",
    ingredients = {
        {"纯水", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "碱性溶液排泄" {
    type = { "recipe" },
    category = "液体排泄",
    ingredients = {
        {"碱性溶液", 100},
    },
    results = {
        {"液体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "氮气排泄" {
    type = { "recipe" },
    category = "气体排泄",
    ingredients = {
        {"氮气", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "氧气排泄" {
    type = { "recipe" },
    category = "气体排泄",
    ingredients = {
        {"氧气", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "二氧化碳排泄" {
    type = { "recipe" },
    category = "气体排泄",
    ingredients = {
        {"二氧化碳", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "氢气排泄" {
    type = { "recipe" },
    category = "气体排泄",
    ingredients = {
        {"氢气", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "蒸汽排泄" {
    type = { "recipe" },
    category = "气体排泄",
    ingredients = {
        {"蒸汽", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "甲烷排泄" {
    type = { "recipe" },
    category = "气体排泄",
    ingredients = {
        {"甲烷", 100},
    },
    results = {
        {"气体排泄物", 1},
    },
    time = "1s",
    description = "使用铁锭和碎石锻造铁板",
}