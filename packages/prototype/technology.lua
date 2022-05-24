local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "地质研究" {
    type = { "tech" },
    icon = "textures/science/tech-equipment.texture",
    effects = {
      unlock_recipe = {"地质科技包1"},
    },
    ingredients = {
    },
    count = 5,
    time = "1s",
    desc = "科技的描述",
    sign_desc = {
      { desc = "科技的描述", icon = "textures/science/important.texture"},
    },
    sign_icon = "textures/science/tech-important.texture",
}

---新增水冰配方的对应科技---
prototype "水冰提取铁矿" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"水冰分离铁"},
  },
  prerequisites = {"地质研究"},
  ingredients = {
      {"地质科技包", 3},
  },
  count = 4,
  time = "1s"
}

-- prototype "铁矿收集" {
--   type = { "tech" },
--   icon = "textures/science/tech-metal.texture",
--   effects = {
--   },
--   prerequisites = {"地质研究"},
--   ingredients = {
--       {"铁矿石", 10},
--   },
-- }

---新增水冰配方的对应科技---
prototype "水冰提取石矿" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"水冰分离石头"},
  },
  prerequisites = {"铁矿收集"},
  ingredients = {
      {"地质科技包", 3},
  },
  count = 4,
  time = "1s"
}

prototype "铁矿熔炼" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"铁锭"},
  },
  prerequisites = {"铁矿提取"},
  ingredients = {
      {"地质科技包", 3},
  },
  count = 4,
  time = "1s"
}

prototype "铁加工1" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"铁板1","铁棒1"},
  },
  prerequisites = {"铁矿熔炼"},
  ingredients = {
      {"地质科技包", 5},
  },
  count = 3,
  time = "1s"
}


prototype "气候研究" {
  type = { "tech" },
  icon = "textures/science/tech-equipment.texture",
  effects = {
    unlock_recipe = {"气候科技包1"},
  },
  prerequisites = {"铁加工1"},
  ingredients = {
      {"地质科技包", 3},
  },
  count = 4,
  time = "1s"
}

prototype "水过滤系统" {
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"破损水电站"},
  },
  prerequisites = {"气候研究"},
  ingredients = {
      {"地质科技包", 2},
      {"气候科技包", 2},
  },
  count = 3,
  time = "1s"
}

prototype "管道系统1" {
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"管道1","液罐1"},
  },
  prerequisites = {"气候研究"},
  ingredients = {
      {"地质科技包", 3},
  },
  count = 3,
  time = "1s"
}

prototype "电解" {
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"水冰电解","破损电解厂"},
  },
  prerequisites = {"水过滤系统"},
  ingredients = {
      {"气候科技包", 4},
  },
  count = 4,
  time = "1s"
}

prototype "空气分离" {
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"空气分离1","破损空气过滤器"},
  },
  prerequisites = {"水过滤系统","管道系统1"},
  ingredients = {
      {"气候科技包", 3},
  },
  count = 3,
  time = "1s"
}

prototype "铁加工2" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"铁丝1","铁齿轮","破损组装机"},
  },
  prerequisites = {"铁加工1"},
  ingredients = {
      {"地质科技包", 5},
  },
  count = 4,
  time = "1s"
}

prototype "石头提取" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"水冰分离石头"},
  },
  prerequisites = {"铁加工2"},
  ingredients = {
      {"地质科技包", 8},
  },
  count = 2,
  time = "1s"
}


prototype "石头处理1" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"破损太阳能板","沙石粉碎","破损物流中心"},
  },
  prerequisites = {"石头提取"},
  ingredients = {
      {"地质科技包", 8},
  },
  count = 2,
  time = "1s"
}

prototype "基地生产1" {
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    modifier = {["headquarter-mining-speed"] = 0.5},
    unlock_recipe = {"破损运输汽车"},
  },
  prerequisites = {"铁加工2"},
  ingredients = {
      {"地质科技包", 8},
  },
  count = 2,
  time = "1s"
}

prototype "储存1" {
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    unlock_recipe = {"小型铁制箱子","破损车站"},
  },
  prerequisites = {"铁加工2"},
  ingredients = {
      {"地质科技包", 6},
      {"气候科技包", 6},
  },
  count = 3,
  time = "1s"
}

prototype "碳处理1" {
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"破损蓄电池","二氧化碳转甲烷"},
  },
  prerequisites = {"电解","空气分离"},
  ingredients = {
      {"气候科技包", 4},
  },
  count = 4,
  time = "1s"
}

prototype "碳处理2" {
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"二氧化碳转一氧化碳","一氧化碳转石墨"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
      {"气候科技包", 8},
  },
  count = 4,
  time = "1s"
}

prototype "管道系统2" {
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"破损化工厂","地下管1"},
  },
  prerequisites = {"管道系统1","石头处理1"},
  ingredients = {
      {"地质科技包", 4},
      {"气候科技包", 4},
  },
  count = 5,
  time = "1s"
}

prototype "石头处理2" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"石砖"},
  },
  prerequisites = {"石头处理1"},
  ingredients = {
      {"地质科技包", 4},
      {"气候科技包", 4},
  },
  count = 3,
  time = "1s"
}

prototype "基地生产2" {
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    modifier = {["headquarter-craft-speed"] = 0.25},
  },
  prerequisites = {"基地生产1"},
  ingredients = {
      {"地质科技包", 5},
  },
  count = 4,
  time = "1s"
}

prototype "有机化学" {
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"甲烷转乙烯","塑料1"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
    {"地质科技包", 4},
    {"气候科技包", 4},
  },
  count = 5,
  time = "1s"
}

prototype "排放" {
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"烟囱1","排水口1"},
  },
  prerequisites = {"管道系统2"},
  ingredients = {
    {"气候科技包", 8},
  },
  count = 2,
  time = "1s"
}

prototype "冶金学" {
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"熔炼炉1"},
  },
  prerequisites = {"石头处理2"},
  ingredients = {
    {"地质科技包", 5},
  },
  count = 3,
  time = "1s"
}

prototype "电磁学1" {
  type = { "tech" },
  icon = "textures/science/tech-equipment.texture",
  effects = {
    unlock_recipe = {"电动机1"},
  },
  prerequisites = {"有机化学","排放","基地生产2"},
  ingredients = {
    {"地质科技包", 5},
    {"气候科技包", 5},
  },
  count = 3,
  time = "1s"
}

prototype "机械研究" {
  type = { "tech" },
  icon = "textures/science/tech-equipment.texture",
  effects = {
    unlock_recipe = {"机械科技包1"},
  },
  prerequisites = {"电磁学1"},
  ingredients = {
    {"地质科技包", 5},
    {"气候科技包", 5},
  },
  count = 6,
  time = "1s"
}

prototype "蒸馏厂1" {
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"蒸馏厂1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 4},
    {"气候科技包", 4},
  },
  count = 7,
  time = "1s"
}

prototype "挖掘1" {
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"采矿机1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 4},
    {"气候科技包", 4},
  },
  count = 7,
  time = "1s"
}

prototype "驱动1" {
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"机器爪1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 3},
  },
  count = 8,
  time = "1s"
}

prototype "电力传输1" {
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"铁制电线杆"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 2},
    {"气候科技包", 2},
    {"机械科技包", 2},
  },
  count = 12,
  time = "1s"
}

prototype "物流1" {
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    unlock_recipe ={"车站1","物流中心1","运输车辆1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 3},
  },
  count = 8,
  time = "1s"
}

prototype "泵系统1" {
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"压力泵1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"气候科技包", 4},
    {"机械科技包", 4},
  },
  count = 6,
  time = "1s"
}

prototype "金属加工1" {
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"铸造厂1"},
  },
  prerequisites = {"挖掘1","驱动1"},
  ingredients = {
    {"地质科技包", 4},
    {"机械科技包", 4},
  },
  count = 8,
  time = "1s"
}

prototype "自动化1" {
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"组装机1"},
  },
  prerequisites = {"驱动1","电力传输1","物流1"},
  ingredients = {
    {"机械科技包", 3},
  },
  count = 12,
  time = "1s"
}