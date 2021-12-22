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

prototype "铁棍1" {
    type = { "recipe" },
    category = "金属锻造",
    ingredients = {
        {"铁锭", 4},
    },
    results = {
        {"铁棍", 5}
    },
    time = "4s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "铁丝1" {
    type = { "recipe" },
    category = "金属锻造",
    ingredients = {
        {"铁棍", 3},
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
    category = "中型组装",
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
    category = "中型组装",
    ingredients = {
        {"铁棍", 1},
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
        {"铁棍", 1},
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
        {"铁棍", 3},
        {"齿轮", 2},
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
    category = "中型组装",
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
    category = "中型组装",
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
    category = "中型组装",
    ingredients = {
        {"铁棍", 1},
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
        {"齿轮", 3},
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
        {"铁棍", 1},
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
        {"铁棍", 1},
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

prototype "烟囱1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"铁棍", 2},
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

prototype "车辆厂1" {
    type = { "recipe" },
    category = "大型制造",
    ingredients = {
        {"蒸汽发电机1", 1},
        {"车站1", 2},
        {"砖石公路", 10},
    },
    results = {
        {"车辆厂1", 1},
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
        {"水罐1", 4},
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
        {"碳", 1},
        {"破损蓄电池", 1},
    },
    results = {
        {"蓄电池1", 1},
    },
    time = "6s",
    description = "使用铁锭和碎石锻造铁板",
}

prototype "地质科技包" {
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

prototype "机械科技包" {
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

prototype "机械科技包" {
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