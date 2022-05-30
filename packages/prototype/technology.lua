local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

  --task = {"stat_production", 0, "铁矿石"},
  --task = {"stat_consumption", 0, "铁矿石"},
  --task = {"select_entity", 0, "组装机"},
  --task = {"select_chest", 0, "指挥中心", "铁丝"},
  --task = {"power_generator", 0},
  --time是指1个count所需的时间

prototype "地质研究" {
    desc = "对火星地质结构进行标本采集和研究",
    type = { "tech" },
    icon = "textures/science/tech-equipment.texture",
    effects = {
      unlock_recipe = {"地质科技包1"},
    },
    ingredients = {
    },
    count = 5,
    time = "3s",
    sign_desc = {
      { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
    },
    sign_icon = "textures/science/tech-important.texture",
}

prototype "收集铁矿石" {
  desc = "收集足够的铁矿石可以开始进行锻造",
  icon = "textures/construct/industry.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "铁矿石"},
  -- task = {"select_chest", 0, "指挥中心", "铁矿石"},
  prerequisites = {"地质研究"},
  count = 10,
  sign_desc = {
    { desc = "收集10个铁矿石", icon = "textures/construct/industry.texture"},
  },
}

prototype "铁矿熔炼" {
  desc = "掌握熔炼铁矿石冶炼成铁板的工艺",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"铁板1"},
  },
  prerequisites = {"收集铁矿石"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 4,
  time = "3s"
}

prototype "生产铁板" {
  desc = "铁板可以打造坚固的房屋和器材，对于基地建设多多益善",
  icon = "textures/science/tech-equipment.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "铁板"},
  prerequisites = {"铁矿熔炼"},
  count = 6,
  sign_desc = {
    { desc = "生产6个铁板", icon = "textures/science/tech-metal.texture"},
  },
}

prototype "石头处理1" {
  desc = "获得火星岩石加工成石砖的工艺",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"石砖"},
  },
  prerequisites = {"生产铁板"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 5,
  time = "2s"
}

prototype "气候研究" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  icon = "textures/science/tech-equipment.texture",
  effects = {
    unlock_recipe = {"生产铁板"},
  },
  prerequisites = {"石头处理1"},
  ingredients = {
      {"地质科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
  },
  sign_icon = "textures/science/tech-important.texture",
  count = 4,
  time = "1s"
}

prototype "挖掘井" {
  desc = "对火星地层下的水源进行开采",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"破损水电站"},
  },
  prerequisites = {"气候研究"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 4,
  time = "1s"
}

-- ---新增地下卤水配方的对应科技---
-- prototype "地下卤水提取铁矿" {
--   type = { "tech" },
--   icon = "textures/science/tech-metal.texture",
--   effects = {
--     unlock_recipe = {"地下卤水分离铁"},
--   },
--   prerequisites = {"地质研究"},
--   ingredients = {
--       {"地质科技包", 3},
--   },
--   count = 4,
--   time = "1s"
-- }

-- ---新增地下卤水配方的对应科技---
-- prototype "地下卤水提取石矿" {
--   type = { "tech" },
--   icon = "textures/science/tech-metal.texture",
--   effects = {
--     unlock_recipe = {"地下卤水分离石头"},
--   },
--   prerequisites = {"铁矿收集"},
--   ingredients = {
--       {"地质科技包", 3},
--   },
--   count = 4,
--   time = "1s"
-- }


prototype "管道系统1" {
  desc = "研究装载和运输液体或气体的管道",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"管道1","液罐1"},
  },
  prerequisites = {"气候研究"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 4,
  time = "1s"
}

prototype "生产管道" {
  desc = "管道可以承载液体和气体，将需要相同气液的机器彼此联通起来",
  icon = "textures/science/tech-equipment.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "管道1-I型"},
  prerequisites = {"挖掘井","管道系统1"},
  count = 10,
  sign_desc = {
    { desc = "生产10个管道", icon = "textures/construct/assembler.texture"},
  },
}


prototype "电解" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"地下卤水电解","破损电解厂"},
  },
  prerequisites = {"生产管道"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 5,
  time = "2s"
}

prototype "空气分离" {
  desc = "获得火星大气分离出纯净气体的工艺",
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"空气分离1","破损空气过滤器"},
  },
  prerequisites = {"生产管道"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 4,
  time = "1.5s"
}

prototype "铁加工1" {
  desc = "获得铁板加工铁齿轮的工艺",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"铁齿轮","破损组装机"},
  },
  prerequisites = {"生产管道"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 5,
  time = "1s"
}

prototype "使用破损组装机" {
  desc = "将破损的机器修复会大大节省建设时间和资源",
  icon = "textures/science/tech-equipment.texture",
  type = { "tech", "task" },
  task = {"stat_consumption", 0, "破损组装机"},
  prerequisites = {"铁加工1"},
  count = 3,
  sign_desc = {
    { desc = "使用3个破损组装机", icon = "textures/construct/assembler.texture"},
  },
}

prototype "石头处理2" {
  desc = "对火星岩石成分的研究",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"破损太阳能板"},
  },
  prerequisites = {"使用破损组装机"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 8,
  time = "1s"
}

prototype "放置太阳能板" {
  desc = "放置太阳能板将光热转换成电能",
  icon = "textures/science/tech-equipment.texture",
  type = { "tech", "task" },
  task = {"select_entity", 0, "太阳能板I"},
  prerequisites = {"石头处理2"},
  count = 3,
  sign_desc = {
    { desc = "放置3个太阳能板", icon = "textures/construct/assembler.texture"},
  },
}

prototype "基地生产1" {
  desc = "提高指挥中心的生产效率",
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    modifier = {["headquarter-mining-speed"] = 0.1},
  },
  prerequisites = {"使用破损组装机"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 8,
  time = "1s",
  sign_desc = {
    { desc = "该科技可以持续地提高某项能力", icon = "textures/science/recycle.texture"},
  },
  sign_icon = "textures/science/tech-cycle.texture",
}

prototype "储存1" {
  desc = "研究更便捷的存储方式",
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    unlock_recipe = {"小型铁制箱子"},
  },
  prerequisites = {"使用破损组装机"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 6,
  time = "1s"
}

prototype "生产储藏箱" {
  desc = "生产小型铁制箱子用于存储基地的资源",
  icon = "textures/science/tech-equipment.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "小型铁制箱子"},
  prerequisites = {"储存1","基地生产1"},
  count = 10,
  sign_desc = {
    { desc = "生产3个小型铁制箱子", icon = "textures/construct/assembler.texture"},
  },
}

prototype "基地生产2" {
  desc = "提高指挥中心的生产效率",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    modifier = {["headquarter-craft-speed"] = 0.2},
  },
  prerequisites = {"生产储藏箱"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 10,
  time = "2s",
  sign_desc = {
    { desc = "该科技可以持续地提高某项能力", icon = "textures/science/recycle.texture"},
  },
  sign_icon = "textures/science/tech-cycle.texture",
}

prototype "碳处理1" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"二氧化碳转甲烷"},
  },
  prerequisites = {"电解","空气分离"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 4,
  time = "2s"
}

prototype "碳处理2" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"二氧化碳转一氧化碳","一氧化碳转石墨"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "管道系统2" {
  desc = "研究装载和运输液体或气体的管道",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"破损化工厂","地下管1"},
  },
  prerequisites = {"空气分离"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 4,
  time = "3s"
}

prototype "有机化学" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"甲烷转乙烯","塑料1"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 5,
  time = "10s"
}

prototype "排放" {
  desc = "研究气体和液体的排放工艺",
  type = { "tech" },
  icon = "textures/science/tech-liquid.texture",
  effects = {
    unlock_recipe = {"烟囱1","排水口1"},
  },
  prerequisites = {"管道系统2"},
  ingredients = {
    {"气候科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "冶金学" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  icon = "textures/science/tech-metal.texture",
  effects = {
    unlock_recipe = {"熔炼炉1"},
  },
  prerequisites = {"放置太阳能板"},
  ingredients = {
    {"地质科技包", 1},
  },
  count = 5,
  time = "4s"
}

prototype "生产一氧化碳" {
  desc = "尝试生产初级化工气体一氧化碳",
  icon = "textures/science/tech-equipment.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "一氧化碳"},
  prerequisites = {"碳处理2"},
  count = 1000,
  sign_desc = {
    { desc = "生产1000个单位一氧化碳", icon = "textures/fluid/gas.texture"},
  },
}

prototype "生产塑料" {
  desc = "使用有机化学的科学成果生产质量轻、耐腐蚀的工业材料塑料",
  icon = "textures/science/tech-equipment.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "塑料"},
  prerequisites = {"有机化学"},
  count = 50,
  sign_desc = {
    { desc = "生产50个塑料", icon = "textures/construct/assembler.texture"},
  },
}

prototype "电磁学1" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  icon = "textures/science/tech-equipment.texture",
  effects = {
    unlock_recipe = {"电动机1"},
  },
  prerequisites = {"生产一氧化碳","生产塑料","基地生产2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 10,
  time = "6s"
}

prototype "机械研究" {
  desc = "对适合在火星表面作业的机械装置进行改进和开发",
  type = { "tech" },
  icon = "textures/science/tech-equipment.texture",
  effects = {
    unlock_recipe = {"机械科技包1"},
  },
  prerequisites = {"电磁学1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 6,
  time = "1s",
  sign_desc = {
    { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
  },
  sign_icon = "textures/science/tech-important.texture",
}

prototype "蒸馏厂1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-chemical.texture",
  effects = {
    unlock_recipe = {"蒸馏厂1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 1},
    {"气候科技包", 1},
  },
  count = 8,
  time = "1s"
}

prototype "挖掘1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"采矿机1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "驱动1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"机器爪1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "电力传输1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"铁制电线杆"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 12,
  time = "2s"
}

prototype "物流1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-logistics.texture",
  effects = {
    unlock_recipe ={"车站1","物流中心1","运输车辆1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "泵系统1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"压力泵1"},
  },
  prerequisites = {"机械研究"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 6,
  time = "2s"
}

prototype "金属加工1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"铸造厂1"},
  },
  prerequisites = {"挖掘1","驱动1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "自动化1" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-manufacture.texture",
  effects = {
    unlock_recipe = {"组装机1"},
  },
  prerequisites = {"驱动1","电力传输1","物流1"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 12,
  time = "3s"
}