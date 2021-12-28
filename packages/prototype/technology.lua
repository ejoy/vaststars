local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype


prototype "地质研究" {
    effects = {
      {"unlock-recipe","地质科技包1"},
    },
    prerequisites = {},
    ingredients = {
        {"", 5},
    },
    time = 3
}

prototype "铁矿熔炼" {
  effects = {
    {"unlock-recipe","铁锭"},
  },
  prerequisites = {"地质研究"},
  ingredients = {
      {"地质科技包", 3},
  },
  time = 4
}

prototype "铁加工1" {
  effects = {
    {"unlock-recipe","铁板1"},
    {"unlock-recipe","铁棒1"},
  },
  prerequisites = {"铁矿熔炼"},
  ingredients = {
      {"地质科技包", 5},
  },
  time = 3
}


prototype "气候研究" {
  effects = {
    {"unlock-recipe","气候科技包1"},
  },
  prerequisites = {"铁加工1"},
  ingredients = {
      {"地质科技包", 3},
  },
  time = 4
}

prototype "水过滤系统" {
  effects = {
    {"unlock-recipe","破损水电站"},
  },
  prerequisites = {"气候研究"},
  ingredients = {
      {"地质科技包", 2},
      {"气候科技包", 2},
  },
  time = 3
}

prototype "管道系统1" {
  effects = {
    {"unlock-recipe","管道1"},
    {"unlock-recipe","液罐1"},
  },
  prerequisites = {"气候研究"},
  ingredients = {
      {"地质科技包", 3},
  },
  time = 3
}

prototype "电解" {
  effects = {
    {"unlock-recipe","海水电解"},
    {"unlock-recipe","破损电解厂"},
  },
  prerequisites = {"水过滤系统"},
  ingredients = {
      {"气候科技包", 4},
  },
  time = 4
}

prototype "空气分离" {
  effects = {
    {"unlock-recipe","空气分离1"},
    {"unlock-recipe","破损空气过滤器"},
  },
  prerequisites = {"水过滤系统","管道系统1"},
  ingredients = {
      {"气候科技包", 3},
  },
  time = 3
}

prototype "铁加工2" {
  effects = {
    {"unlock-recipe","铁丝1"},
    {"unlock-recipe","铁齿轮"},
    {"unlock-recipe","破损组装机"},
  },
  prerequisites = {"铁加工1"},
  ingredients = {
      {"地质科技包", 5},
  },
  time = 4
}

prototype "石头处理1" {
  effects = {
    {"unlock-recipe","破损太阳能板"},
    {"unlock-recipe","沙石粉碎"},
    {"unlock-recipe","破损物流中心"},
  },
  prerequisites = {"铁加工2"},
  ingredients = {
      {"地质科技包", 8},
  },
  time = 2
}

prototype "基地生产1" {
  effects = {
    type = "headquarter-mining-speed",
    modifier = 0.5,
    {"unlock-recipe","破损运输汽车"},
  },
  prerequisites = {"铁加工2"},
  ingredients = {
      {"地质科技包", 8},
  },
  time = 2
}

prototype "储存1" {
  effects = {
    {"unlock-recipe","小型铁制箱子"},
    {"unlock-recipe","破损车站"},
  },
  prerequisites = {"铁加工2"},
  ingredients = {
      {"地质科技包", 6},
      {"气候科技包", 6},
  },
  time = 3
}

prototype "碳处理1" {
  effects = {
    {"unlock-recipe","破损蓄电池"},
    {"unlock-recipe","二氧化碳转甲烷"},
  },
  prerequisites = {"电解","空气分离"},
  ingredients = {
      {"气候科技包", 4},
  },
  time = 4
}

prototype "碳处理2" {
  effects = {
    {"unlock-recipe","二氧化碳转一氧化碳"},
    {"unlock-recipe","一氧化碳转石墨"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
      {"气候科技包", 8},
  },
  time = 4
}

prototype "管道系统2" {
  effects = {
    {"unlock-recipe","破损化工厂"},
    {"unlock-recipe","地下管1"},
  },
  prerequisites = {"管道系统1","石头处理1"},
  ingredients = {
      {"地质科技包", 4},
      {"气候科技包", 4},
  },
  time = 5
}

prototype "石头处理2" {
  effects = {
    {"unlock-recipe","石砖"},
  },
  prerequisites = {"石头处理1"},
  ingredients = {
      {"地质科技包", 4},
      {"气候科技包", 4},
  },
  time = 3
}

prototype "基地生产2" {
  effects = {
    type = "headquarter-craft-speed",
    modifier = 0.25,
  },
  prerequisites = {"基地生产1"},
  ingredients = {
      {"地质科技包", 5},
  },
  time = 4
}

prototype "有机化学" {
  effects = {
    {"unlock-recipe","甲烷转乙烯"},
    {"unlock-recipe","塑料1"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
    {"地质科技包", 4},
    {"气候科技包", 4},
  },
  time = 5
}

prototype "排放" {
  effects = {
    {"unlock-recipe","烟囱1"},
    {"unlock-recipe","排水口1"},
  },
  prerequisites = {"管道系统2"},
  ingredients = {
    {"气候科技包", 8},
  },
  time = 2
}

prototype "金属冶炼" {
  effects = {
    {"unlock-recipe","熔炼炉1"},
  },
  prerequisites = {"石头处理2"},
  ingredients = {
    {"地质科技包", 5},
  },
  time = 3
}

prototype "电磁学1" {
  effects = {
    {"unlock-recipe","电动机1"},
  },
  prerequisites = {"有机化学","排放","基地生产2"},
  ingredients = {
    {"地质科技包", 5},
    {"气候科技包", 5},
  },
  time = 3
}

prototype "机械研究" {
  effects = {
    {"unlock-recipe","机械科技包1"},
  },
  prerequisites = {"电磁学1"},
  ingredients = {
    {"地质科技包", 5},
    {"气候科技包", 5},
  },
  time = 6
}

prototype "蒸馏厂1" {
  effects = {
    {"unlock-recipe","蒸馏厂1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 4},
    {"气候科技包", 4},
  },
  time = 7
}

prototype "挖掘1" {
  effects = {
    {"unlock-recipe","采矿机1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 4},
    {"气候科技包", 4},
  },
  time = 7
}

prototype "驱动1" {
  effects = {
    {"unlock-recipe","机器爪1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 3},
  },
  time = 8
}

prototype "电力传输1" {
  effects = {
    {"unlock-recipe","铁制电线杆"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 2},
    {"气候科技包", 2},
    {"机械科技包", 2},
  },
  time = 12
}

prototype "物流1" {
  effects = {
    {"unlock-recipe","车站1"},
    {"unlock-recipe","物流中心1"},
    {"unlock-recipe","运输车辆1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 3},
  },
  time = 8
}

prototype "泵系统1" {
  effects = {
    {"unlock-recipe","压力泵1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"气候科技包", 4},
    {"机械科技包", 4},
  },
  time = 6
}

prototype "金属加工1" {
  effects = {
    {"unlock-recipe","铸造厂1"},
  },
  prerequisites = {"挖掘1","驱动1"},
  ingredients = {
    {"地质科技包", 4},
    {"机械科技包", 4},
  },
  time = 8
}



prototype "自动化1" {
  effects = {
    {"unlock-recipe","组装机1"},
  },
  prerequisites = {"驱动1","电力传输1","物流1"},
  ingredients = {
    {"机械科技包", 3},
  },
  time = 12
}