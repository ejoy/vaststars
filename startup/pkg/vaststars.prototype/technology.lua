local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

  --task = {"stat_production", 0, "铁矿石"},            生产XX个物品
  --task = {"stat_consumption", 0, "铁矿石"},           消耗XX个物品
  --task = {"select_entity", 0, "组装机"},              拥有XX台机器
  --task = {"select_chest", 0, "指挥中心", "铁丝"},     向指挥中心转移X个物品
  --task = {"power_generator", 0},                      电力发电到达X瓦
  --task = {"unknown", 0},                              自定义任务
  
  --task = {"unknown", 0, 3},                           自定义任务，组装机指定选择配方
  --task_params = {recipe = "地质科技包1"},
  --count = 1,
  --time是指1个count所需的时间

  -- task = {"unknown", 0, 5},                          自定义任务，无人机仓库I指定选择物品
  -- task_params = {item = "采矿机框架"},

  -- task = {"unknown", 0, 6},
  -- task_params = {ui = "item_transfer_subscribe", building = "xxx"},    传送设置

  -- task = {"unknown", 0, 6},
  -- task_params = {ui = "item_transfer_unsubscribe", , building = "xxx"},  传送取消

  -- task = {"unknown", 0, 6},
  -- task_params = {ui = "item_transfer_place", , building = "xxx"},       传送启动
  

  prototype "迫降火星" {
    desc = "迫降火星",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
      -- unlock_recipe = {"采矿机打印"},
      unlock_item = {"碎石"},
    },
    prerequisites = {""},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "初次进入火星", icon = "textures/construct/industry.texture"},
    },
  }

  -- prototype "生产运输车辆1" {
  --   desc = "指挥中心建造4辆运输车辆",
  --   icon = "textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "运输车辆I"},
  --   prerequisites = {"迫降火星"},
  --   count = 4,
  --   tips_pic = {
  --     "textures/task_tips_pic/task_produce_ore3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "指挥中心建造4辆运输车辆", icon = "textures/construct/industry.texture"},
  --   },
  --   -- guide_focus = {
  --   --   {
  --   --     prefab = "prefabs/selected-box-no-animation.prefab",
  --   --     x = 128,
  --   --     y = 122,
  --   --     w = 5.5,
  --   --     h = 5.5,
  --   --     show_arrow = true,
  --   --   },
  --   --   {
  --   --     camera_x = 121,
  --   --     camera_y = 122,
  --   --   },
  --   -- },
  -- }

  prototype "放置采矿机" {
    desc = "放置1台采矿机",
    icon = "textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "采矿机I"},
    prerequisites = {"迫降火星"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 114,
    --     y = 128,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 114,
    --     y = 123.8,
    --     w = 1.8,
    --     h = 1.8,
    --     show_arrow = true,
    --   },
    --   {
    --     camera_x = 115,
    --     camera_y = 125,
    --   },
    -- },
    sign_desc = {
      { desc = "在石矿上放置1个采矿机", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置风力发电机" {
    desc = "放置1台采矿机",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "风力发电机I"},
    prerequisites = {"放置采矿机"},
    effects = {
    },
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 114,
    --     y = 117.8,
    --     w = 1.8,
    --     h = 1.8,
    --     show_arrow = true,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 110,
    --     y = 124,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 118,
    --     y = 124,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 114,
    --     y = 124,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 114,
    --     y = 132,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 110,
    --     y = 132,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 118,
    --     y = 132,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 110,
    --     y = 128,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 118,
    --     y = 128,
    --     w = 3.5,
    --     h = 3.5,
    --   },
    --   {
    --     camera_x = 115,
    --     camera_y = 125,
    --   },
    -- },
    sign_desc = {
      { desc = "在石矿上放置1个采矿机", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置电线杆" {
    desc = "放置2个铁制电线杆",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "铁制电线杆"},
    prerequisites = {"放置风力发电机"},
    count = 2,
    effects = {
      --  unlock_recipe = {"无人机仓库I打印"},
      --  unlock_item = {"无人机仓库I框架"},
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_pole1.texture",
      "textures/task_tips_pic/task_place_pole2.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 127,
    --     y = 115.8,
    --     w = 1.8,
    --     h = 1.8,
    --     show_arrow = true,
    --   },
    --   {
    --     camera_x = 125,
    --     camera_y = 121,
    --   },
    -- },
    sign_desc = {
      { desc = "风力发电机附近放置2个铁制电线杆构成电网", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置无人机仓库" {
    desc = "放置1个无人机仓库",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "无人机仓库I"},
    prerequisites = {"放置电线杆"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_pole1.texture",
      "textures/task_tips_pic/task_place_pole2.texture",
    },
    effects = {
      -- unlock_item = {"碎石"},
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 127,
    --     y = 127.8,
    --     w = 1.8,
    --     h = 1.8,
    --     show_arrow = true,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 117.5,
    --     y = 124.5,
    --     w = 2.5,
    --     h = 2.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 117.5,
    --     y = 132.5,
    --     w = 2.5,
    --     h = 2.5,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 117.5,
    --     y = 128.5,
    --     w = 2.5,
    --     h = 2.5,
    --   },
    --   {
    --     camera_x = 120,
    --     camera_y = 128,
    --   },
    -- },
    sign_desc = {
      { desc = "放置1个无人机仓库I", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "无人机仓库设置" {
    desc = "无人机仓库选择碎石",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 5},                          
    task_params = {item = "碎石"},
    count = 1,
    prerequisites = {"放置无人机仓库"},
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "无人机仓库选择碎石", icon = "textures/construct/industry.texture"},
    },
  }


  prototype "收集碎石" {
    desc = "挖掘足够的碎石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "碎石"},
    prerequisites = {"无人机仓库设置"},
    count = 12,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "在碎石矿上放置挖矿机并挖掘12个碎石矿", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "更多碎石" {
    desc = "挖掘足够的碎石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "碎石"},
    prerequisites = {"收集碎石"},
    count = 24,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "放置2个无人机平台收集达24个碎石矿", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置科研中心" {
    desc = "放置可以研究火星科技的建筑",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "科研中心I"},
    prerequisites = {"更多碎石"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_click_build.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 130,
    --     y = 115.8,
    --     w = 1.8,
    --     h = 1.8,
    --     show_arrow = true,
    --   },
    --   {
    --     camera_x = 128,
    --     camera_y = 121,
    --   },
    -- },
    sign_desc = {
      { desc = "放置1座科研中心", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "地质研究" {
    desc = "对火星地质结构进行标本采集和研究",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"地质科技包1"},
      -- unlock_item = {"组装机框架"},
    },
    ingredients = {
    },
    count = 10,
    time = "2s",
    prerequisites = {"放置科研中心"},
    sign_desc = {
      { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "textures/science/key_sign.texture"},
    },
    sign_icon = "textures/science/tech-key_sign.texture",
}

  prototype "放置组装机" {
    desc = "放置组装机",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "组装机I"},
    effects = {
      unlock_item = {"地质科技包"},
    },
    prerequisites = {"地质研究"},
    count = 2,
    tips_pic = {
      "textures/task_tips_pic/task_click_build.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 130,
    --     y = 127.8,
    --     w = 1.8,
    --     h = 1.8,
    --     show_arrow = true,
    --   },
    --   {
    --     camera_x = 128,
    --     camera_y = 125,
    --   },
    -- },
    sign_desc = {
      { desc = "放置2台组装机", icon = "textures/construct/industry.texture"},
    },
  }
  
  prototype "组装机生产" {
    desc = "自动化生产科技包用于科技研究",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "地质科技包"},
    prerequisites = {"放置组装机"},
    count = 8,
    tips_pic = {
      "textures/task_tips_pic/task_produce_geopack3.texture",
      "textures/task_tips_pic/task_produce_geopack4.texture",
      "textures/task_tips_pic/task_produce_geopack5.texture",
      "textures/task_tips_pic/task_produce_geopack6.texture",
    },
    sign_desc = {
      { desc = "用无人机仓库I存储从组装机中生产的8个地质科技包", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "石头处理1" {
    desc = "获得火星岩石加工成石砖的工艺",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"石砖"},
      unlock_item = {"石砖"},
    },
    prerequisites = {"组装机生产"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 8,
    time = "1s"
  }

  prototype "生产石砖" {
    desc = "挖掘足够的碎石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "石砖"},
    prerequisites = {"石头处理1"},
    count = 8,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产8个石砖", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "铁矿石开采" {
    desc = "获得火星铁矿开采的能力",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_item = {"铁矿石"},
    },
    prerequisites = {"生产石砖"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 8,
    time = "1s"
  }

  prototype "公路研究" {
    desc = "掌握使用石砖制造公路的技术",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    prerequisites = {"铁矿石开采"},
    effects = {
      unlock_recipe = {"砖石公路打印"},
    },
    ingredients = {
        {"地质科技包", 1},
    },
    count = 12,
    time = "1.5s"
  }

  prototype "建造公路" {
    desc = "建造60段公路",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "砖石公路-X型"},
    prerequisites = {"公路研究"},
    count = 60,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "往建造中心运送石砖生产60段公路", icon = "textures/construct/industry.texture"},
    },
  }

  
  prototype "通向铁矿" {
    desc = "修建35节公路",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 1},
    task_params = {},
    prerequisites = {"建造公路"},
    count = 35,
    tips_pic = {
      "textures/task_tips_pic/task_place_road1.texture",
      "textures/task_tips_pic/task_place_road2.texture",
      "textures/task_tips_pic/task_place_road3.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 126,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 127,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 128,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 129,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 130,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 131,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 132,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 133,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 134,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 135,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 136,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 137,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 138,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 139,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 140,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 141,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 142,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 143,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 144,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 145,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 146,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 147,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 148,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 149,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 150,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 151,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 152,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 153,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 154,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 155,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 156,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 157,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 158,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 159,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 160,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 161,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 162,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 163,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 164,
    --     y = 125,
    --     w = 0.25,
    --     h = 0.25,
    --   },
    --   {
    --     camera_x = 125,
    --     camera_y = 122,
    --   },
    -- },
    sign_desc = {
      { desc = "修建道路从指挥中心到东边的铁矿", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "物流学1" {
    desc = "研究出货车站和收货车站建造工艺",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"出货车站维修","收货车站维修"},
    },
    prerequisites = {"通向铁矿"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 30,
    time = "1s"
  }

  prototype "铁矿放置采矿机" {
    desc = "放置1台采矿机",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "采矿机I"},
    prerequisites = {"物流学1"},
    count = 2,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "在铁矿上放置1台采矿机", icon = "textures/construct/industry.texture"},
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 163,
    --     y = 128,
    --     w = 3.5,
    --     h = 3.5,
    --     show_arrow = true,
    --   },
    --   {
    --     camera_x = 121,
    --     camera_y = 122,
    --   },
    -- },
  }

  prototype "放置出货车站" {
    desc = "放置1座出货车站",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "出货车站"},
    prerequisites = {"铁矿放置采矿机"},
    count = 1,
    effects = {
      unlock_recipe = {"车辆装配"},
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 109,
    --     y = 136,
    --     w = 5,
    --     h = 5,
    --     show_arrow = true,
    --   },
    --   {
    --     camera_x = 108,
    --     camera_y = 130,
    --   },
    -- },
    sign_desc = {
      { desc = "搜索废墟传送至建造中心生产并放置1个出货车站", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置收货车站" {
    desc = "放置1座收货车站",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "收货车站"},
    prerequisites = {"铁矿放置采矿机"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    -- guide_focus = {
    --   {
    --     prefab = "prefabs/selected-box-no-animation.prefab",
    --     x = 109,
    --     y = 136,
    --     w = 5,
    --     h = 5,
    --     show_arrow = true,
    --   },
    --   {
    --     camera_x = 108,
    --     camera_y = 130,
    --   },
    -- },
    sign_desc = {
      { desc = "搜索废墟传送至建造中心生产并放置1个收货车站", icon = "textures/construct/industry.texture"},
    },
  }

  -- prototype "生产运输车辆" {
  --   desc = "指挥中心建造4辆运输车辆",
  --   icon = "textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "运输车辆I"},
  --   prerequisites = {"放置出货车站","放置收货车站"},
  --   count = 4,
  --   tips_pic = {
  --     "textures/task_tips_pic/task_produce_ore3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "指挥中心建造4辆运输车辆", icon = "textures/construct/industry.texture"},
  --   },
  --   -- guide_focus = {
  --   --   {
  --   --     prefab = "prefabs/selected-box-no-animation.prefab",
  --   --     x = 128,
  --   --     y = 122,
  --   --     w = 5.5,
  --   --     h = 5.5,
  --   --     show_arrow = true,
  --   --   },
  --   --   {
  --   --     camera_x = 121,
  --   --     camera_y = 122,
  --   --   },
  --   -- },
  -- }

  prototype "生产铁矿石" {
    desc = "挖掘足够的铁矿石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "铁矿石"},
    prerequisites = {"放置出货车站","放置收货车站"},
    count = 10,
    effects = {
      unlock_recipe = {"熔炼炉打印"},
      unlock_item = {"熔炼炉I"},
    },
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "在铁矿上放置挖矿机并挖掘10个铁矿石", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "铁矿熔炼" {
    desc = "掌握熔炼铁矿石冶炼成铁板的工艺",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"铁板1"},
      unlock_item = {"铁板"},
    },
    prerequisites = {"生产铁矿石"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 10,
    time = "5s"
  }
  
  prototype "放置熔炼炉" {
    desc = "放置熔炼炉",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "熔炼炉I"},
    prerequisites = {"生产铁矿石"},
    count = 2,
    tips_pic = {
      "textures/task_tips_pic/task_click_build.texture",
      "textures/task_tips_pic/task_produce_geopack1.texture",
      "textures/task_tips_pic/task_produce_geopack2.texture",
      "textures/task_tips_pic/start_construct.texture",
    },
    sign_desc = {
      { desc = "使用“建造”放置2台熔炼炉", icon = "textures/construct/industry.texture"},
    },
  }
  
  prototype "生产铁板" {
    desc = "铁板可以打造坚固器材，对于基地建设多多益善",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "铁板"},
    prerequisites = {"放置熔炼炉","铁矿熔炼"},
    count = 4,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ironplate1.texture",
      "textures/task_tips_pic/task_produce_ironplate2.texture",
      "textures/task_tips_pic/task_produce_ironplate3.texture",
      "textures/task_tips_pic/task_produce_ironplate4.texture",
      "textures/task_tips_pic/task_produce_ironplate5.texture",
    },
    sign_desc = {
      { desc = "使用熔炼炉生产4个铁板", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "铁加工1" {
    desc = "获得铁板加工铁齿轮的工艺",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"铁齿轮"},
      unlock_item = {"铁齿轮"},
    },
    prerequisites = {"生产铁板"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 16,
    time = "5s"
  }

  prototype "生产铁齿轮" {
    desc = "铁板可以打造坚固器材，对于基地建设多多益善",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "铁齿轮"},
    prerequisites = {"铁加工1"},
    count = 10,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ironplate1.texture",
      "textures/task_tips_pic/task_produce_ironplate2.texture",
      "textures/task_tips_pic/task_produce_ironplate3.texture",
      "textures/task_tips_pic/task_produce_ironplate4.texture",
      "textures/task_tips_pic/task_produce_ironplate5.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产10个铁齿轮", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "车辆维修" {
    desc = "研究生产运输车辆工艺",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"维修运输汽车"},
    },
    prerequisites = {"生产铁齿轮"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 16,
    time = "5s"
  }

  prototype "量产运输车辆" {
    desc = "生产8辆运输车",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "运输车辆I"},
    prerequisites = {"车辆维修"},
    count = 8,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ironplate1.texture",
      "textures/task_tips_pic/task_produce_ironplate2.texture",
      "textures/task_tips_pic/task_produce_ironplate3.texture",
      "textures/task_tips_pic/task_produce_ironplate4.texture",
      "textures/task_tips_pic/task_produce_ironplate5.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产8辆运输车", icon = "textures/construct/industry.texture"},
    },
  }

prototype "物流学2" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
  },
  prerequisites = {"量产运输车辆"},
  ingredients = {
    {"地质科技包", 1},
  },
  count = 20,
  time = "6s"
}

prototype "气候研究1" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"气候科技包1","空气过滤器打印","地下水挖掘机打印"},
    unlock_item = {"气候科技包","空气过滤器I","地下水挖掘机I"},
  },
  prerequisites = {"物流学2"},
  ingredients = {
      {"地质科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "textures/science/key_sign.texture"},
  },
  sign_icon = "textures/science/tech-key_sign.texture",
  count = 12,
  time = "1.5s"
}

prototype "管道系统1" {
  desc = "研究装载和运输气液原料的管道",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"管道1","管道2","液罐打印"},
    unlock_item = {"液罐I","管道1-X型"},
  },
  prerequisites = {"气候研究1"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 12,
  time = "1s"
}

prototype "生产管道" {
  desc = "生产可以传输气液原料的管道",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "管道1-X型"},
  prerequisites = {"管道系统1"},
  count = 10,
  tips_pic = {
    "textures/task_tips_pic/task_produce_pipe1.texture",
  },
  sign_desc = {
    { desc = "使用组装机生产10个管道", icon = "textures/construct/industry.texture"},
  },
}

prototype "排放1" {
  desc = "研究气体和液体的排放工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"烟囱打印","排水口打印","地下管1"},
    unlock_item = {"烟囱I","排水口I","地下管1-JI型"},
  },
  prerequisites = {"生产管道"},
  ingredients = {
    {"气候科技包", 1},
  },
  count = 15,
  time = "2s"
}

prototype "采水研究" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"水电站打印"},
    unlock_item = {"水电站I"},
  },
  prerequisites = {"排放1"},
  ingredients = {
      {"地质科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "textures/science/key_sign.texture"},
  },
  sign_icon = "textures/science/tech-key_sign.texture",
  count = 12,
  time = "1.5s"
}

prototype "建造地下水挖掘机" {
  desc = "生产科技包用于科技研究",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "地下水挖掘机I"},
  prerequisites = {"采水研究"},
  count = 1,
  tips_pic = {
    "textures/task_tips_pic/task_produce_climatepack2.texture",
    "textures/task_tips_pic/task_produce_climatepack3.texture",
    "textures/task_tips_pic/task_produce_climatepack4.texture",
    "textures/task_tips_pic/task_produce_climatepack5.texture",
  },
  sign_desc = {
    { desc = "生产1个地下水挖掘机", icon = "textures/construct/industry.texture"},
  },
}

prototype "建造水电站" {
  desc = "建造水电站用于处理液体",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "水电站I"},
  prerequisites = {"采水研究"},
  count = 1,
  tips_pic = {
    "textures/task_tips_pic/task_produce_climatepack2.texture",
    "textures/task_tips_pic/task_produce_climatepack3.texture",
    "textures/task_tips_pic/task_produce_climatepack4.texture",
    "textures/task_tips_pic/task_produce_climatepack5.texture",
  },
  sign_desc = {
    { desc = "建造1个水电站", icon = "textures/construct/industry.texture"},
  },
}

prototype "生产气候科技包" {
  desc = "生产科技包用于科技研究",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "气候科技包"},
  prerequisites = {"建造地下水挖掘机","建造水电站"},
  count = 1,
  tips_pic = {
    "textures/task_tips_pic/task_produce_climatepack2.texture",
    "textures/task_tips_pic/task_produce_climatepack3.texture",
    "textures/task_tips_pic/task_produce_climatepack4.texture",
    "textures/task_tips_pic/task_produce_climatepack5.texture",
  },
  sign_desc = {
    { desc = "使用水电站生产1个气候科技包", icon = "textures/construct/industry.texture"},
  },
}

  prototype "放置太阳能板" {
    desc = "放置4座太阳能板",
    icon = "textures/construct/industry.texture",
    type = { "task" },
    task = {"select_entity", 0, "太阳能板I"},
    prerequisites = {"生产气候科技包"},
    count = 4,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置4个太阳能板", icon = "textures/construct/industry.texture"},
    },
  }

prototype "电解" {
  desc = "科技的描述",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"地下卤水电解1","地下卤水电解2","电解厂打印"},
  },
  prerequisites = {"生产气候科技包"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 10,
  time = "2s"
}

prototype "空气分离工艺1" {
  desc = "获得火星大气分离出纯净气体的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"空气分离1"},
  },
  prerequisites = {"电解"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 8,
  time = "1.5s"
}

prototype "收集空气" {
  desc = "采集火星上的空气",
  type = { "task" },
  icon = "textures/construct/industry.texture",
  task = {"stat_production", 1, "空气"},
  prerequisites = {"空气分离工艺1"},
  count = 4000,
  tips_pic = {
    "textures/task_tips_pic/task_produce_air1.texture",
    "textures/task_tips_pic/task_produce_air2.texture",
  },
  sign_desc = {
    { desc = "用空气过滤器生产40000单位空气", icon = "textures/construct/industry.texture",},
  },
}

prototype "碳处理1" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"二氧化碳转甲烷","化工厂打印"},
  },
  prerequisites = {"电解","空气分离工艺1","放置太阳能板"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 8,
  time = "2s"
}

prototype "生产氢气" {
  desc = "生产工业气体氢气",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "氢气"},
  prerequisites = {"碳处理1"},
  count = 500,
  tips_pic = {
    "textures/task_tips_pic/task_produce_h21.texture",
    "textures/task_tips_pic/task_produce_h22.texture",
  },
  sign_desc = {
    { desc = "电解厂电解卤水生产500个单位氢气", icon = "textures/construct/industry.texture"},
  },
}

prototype "生产二氧化碳" {
  desc = "生产工业气体二氧化碳",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "二氧化碳"},
  prerequisites = {"碳处理1"},
  count = 500,
  tips_pic = {
    "textures/task_tips_pic/task_produce_co21.texture",
    "textures/task_tips_pic/task_produce_co22.texture",
  },
  sign_desc = {
    { desc = "蒸馏厂分离空气生产500个单位二氧化碳", icon = "textures/construct/industry.texture"},
  },
}

prototype "碳处理2" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"甲烷转乙烯","二氧化碳转一氧化碳","一氧化碳转石墨"},
  },
  prerequisites = {"生产氢气","生产二氧化碳"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 16,
  time = "2s"
}

prototype "地质研究2" {
  desc = "对火星地质结构进行标本采集和研究",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"地质科技包2"},
  },
  ingredients = {
      {"地质科技包", 1},
  },
  count = 10,
  time = "1.2s",
  prerequisites = {"碳处理2"},
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "textures/science/key_sign.texture"},
  },
  sign_icon = "textures/science/tech-key_sign.texture",
}

prototype "冶金学1" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"熔炼炉1"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
    {"地质科技包", 1},
  },
  count = 10,
  time = "4s"
}

prototype "维修化工厂" {
  desc = "维修化工厂生成化工原料",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_consumption", 0, "化工厂框架"},
  prerequisites = {"碳处理2"},
  count = 1,
  tips_pic = {
    "textures/task_tips_pic/task_repair_chemicalplant1.texture",
  },
  sign_desc = {
    { desc = "使用组装机维修1个破损化工厂", icon = "textures/construct/industry.texture"},
  },
}

prototype "放置化工厂" {
  desc = "放置化工厂生产化工产品",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"select_entity", 0, "化工厂I"},
  prerequisites = {"维修化工厂"},
  count = 1,
  tips_pic = {
    "textures/task_tips_pic/task_click_build.texture",
    "textures/task_tips_pic/task_place_chemicalplant.texture",
  },
  sign_desc = {
    { desc = "放置1座化工厂", icon = "textures/construct/industry.texture"},
  },
}

prototype "生产甲烷" {
  desc = "生产工业气体甲烷",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "甲烷"},
  prerequisites = {"放置化工厂"},
  count = 1000,
  tips_pic = {
    "textures/task_tips_pic/task_produce_ch4.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产1000个单位甲烷", icon = "textures/construct/industry.texture"},
  },
}

prototype "有机化学1" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"塑料1"},
  },
  prerequisites = {"生产甲烷"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 12,
  time = "10s"
}

prototype "生产乙烯" {
  desc = "生产工业气体乙烯",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "乙烯"},
  prerequisites = {"有机化学1"},
  count = 1000,
  tips_pic = {
    "textures/task_tips_pic/task_produce_ch4.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产1000个单位乙烯", icon = "textures/construct/industry.texture"},
  },
}

prototype "生产塑料" {
  desc = "使用有机化学的科学成果生产质量轻、耐腐蚀的工业材料塑料",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "塑料"},
  prerequisites = {"生产乙烯"},
  count = 30,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产30个塑料", icon = "textures/construct/industry.texture"},
  },
}

prototype "电磁学1" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电动机1"},
    unlock_item = {"电动机I"},
  },
  prerequisites = {"生产塑料","排放1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 20,
  time = "6s"
}

--研究机械科技瓶
prototype "机械研究" {
  desc = "对可在火星表面作业的机械装置进行改进和开发",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"机械科技包1"},
    unlock_item = {"机械科技包"},
  },
  prerequisites = {"电磁学1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 12,
  time = "2s",
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "textures/science/key_sign.texture"},
  },
  sign_icon = "textures/science/tech-key_sign.texture",
}

prototype "生产机械科技包" {
  desc = "生产机械科技包用于科技研究",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "机械科技包"},
  prerequisites = {"机械研究"},
  count = 3,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产3个机械科技包", icon = "textures/construct/industry.texture"},
  },
}


prototype "挖掘1" {
  desc = "研究对火星岩石的开采技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"采矿机1"},
    unlock_item = {"采矿机I"},
  },
  prerequisites = {"生产机械科技包"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 8,
  time = "7s"
}

prototype "无人机运输1" {
  desc = "使用无人机快速运送物品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"无人机仓库1"},
  },
  prerequisites = {"生产机械科技包"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 6,
  time = "8s"
}

prototype "蒸馏1" {
  desc = "将液体混合物汽化并分离的技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蒸馏厂1"},
    unlock_item = {"蒸馏厂I"},
  },
  prerequisites = {"挖掘1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 8,
  time = "7s"
}

prototype "电力传输1" {
  desc = "将电能远距离传输的技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"铁制电线杆"},
    unlock_item = {"铁制电线杆"},
  },
  prerequisites = {"生产机械科技包"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "12s"
}

prototype "泵系统1" {
  desc = "使用机械方式加快液体流动",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"压力泵1"},
    unlock_item = {"压力泵I"},
  },
  prerequisites = {"电力传输1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 8,
  time = "6s"
}

prototype "自动化1" {
  desc = "使用3D打印技术复制物品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"组装机1"},
    unlock_item = {"组装机I"},
  },
  prerequisites = {"挖掘1","电力传输1"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 12,
  time = "8s"
}

prototype "物流车站1" {
  desc = "研究供运输车辆装卸货物的物流点",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"出货车站打印","收货车站打印"},
    unlock_item = {"出货车站","收货车站"},
  },
  prerequisites = {"自动化1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 10,
  time = "10s"
}

prototype "地下水净化1" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"地下卤水净化","地下水挖掘机1","水电站1"},
  },
  prerequisites = {"蒸馏1","泵系统1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 8,
  time = "10s"
}

prototype "过滤1" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"空气过滤器1"},
  },
  prerequisites = {"地下水净化1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 10,
  time = "10s"
}

prototype "炼钢" {
  desc = "将铁冶炼成更坚硬金属的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"钢板1"},
    unlock_item = {"钢板"},
  },
  prerequisites = {"挖掘1","物流车站1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 10,
  time = "10s"
}

prototype "大炼钢铁" {
  desc = "生产更多的钢板",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "钢板"},
  prerequisites = {"炼钢"},
  count = 20,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用熔炼炉生产20个钢板", icon = "textures/construct/industry.texture"},
  },
}

prototype "发电机1" {
  desc = "使用蒸汽作为工质将热能转为机械能的发电装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蒸汽发电机1"},
    unlock_item = {"蒸汽发电机I"},
  },
  prerequisites = {"电力传输1","自动化1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 8,
  time = "15s"
}

prototype "矿物处理1" {
  desc = "将矿物进行碾碎并再加工的机械工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"粉碎机1","沙子1"},
    unlock_item = {"粉碎机I","沙子"},
  },
  prerequisites = {"挖掘1","自动化1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 10,
  time = "10s"
}

prototype "矿石粉碎" {
  desc = "将碎石粉碎获得沙子",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "沙子"},
  prerequisites = {"矿物处理1"},
  count = 20,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用粉碎机生产20个沙子", icon = "textures/construct/industry.texture"},
  },
}

prototype "钢加工" {
  desc = "对钢板进行再加工获得钢齿轮",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"钢齿轮"},
    unlock_item = {"钢齿轮"},
  },
  prerequisites = {"大炼钢铁"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 16,
  time = "8s"
}

prototype "打造钢齿轮" {
  desc = "生产更多的钢齿轮",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "钢齿轮"},
  prerequisites = {"钢加工"},
  count = 20,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产30个钢齿轮", icon = "textures/construct/industry.texture"},
  },
}

prototype "浮选1" {
  desc = "使用浮选设备对矿石实行筛选",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"浮选器1"},
    unlock_item = {"浮选器I"},
  },
  prerequisites = {"矿物处理1","地下水净化1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 16,
  time = "8s"
}

prototype "硅处理" {
  desc = "从沙子中提炼硅的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"硅1","玻璃"},
    unlock_item = {"硅","玻璃"},
  },
  prerequisites = {"浮选1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 16,
  time = "8s"
}

prototype "铁矿熔炼2" {
  desc = "将铁矿石冶炼成铁板的更高效工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"铁板2"},
  },
  prerequisites = {"打造钢齿轮"},
  ingredients = {
      {"地质科技包", 1},
      {"机械科技包", 1},
  },
  count = 12,
  time = "8s"
}

prototype "电解1" {
  desc = "使用电化学手段制取工业气体",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电解厂1"},
    unlock_item = {"电解厂I"},
  },
  prerequisites = {"铁矿熔炼2"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 8,
  time = "12s"
}

prototype "有机化学2" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"乙烯转丁二烯","纯水转蒸汽"},
  },
  prerequisites = {"硅处理","电解1"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 16,
  time = "8s"
}

prototype "管道系统2" {
  desc = "研究可储藏气液原料的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"液罐2"},
    unlock_item = {"液罐II"},

  },
  prerequisites = {"硅处理","有机化学2"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 10,
  time = "6s"
}

prototype "化学工程1" {
  desc = "使用特殊设施生产化工产品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"化工厂1","纯水电解"},
    unlock_item = {"化工厂I"},
  },
  prerequisites = {"有机化学2","管道系统2"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 10,
  time = "10s"
}

prototype "无机化学" {
  desc = "使用无机化合物合成物质的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"酸碱中和","碱性溶液","盐酸"},
    unlock_item = {"碱性溶液","盐酸"},
  },
  prerequisites = {"化学工程1"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 20,
  time = "5s"
}

prototype "废料回收1" {
  desc = "将工业废料、矿石进行回收处理的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"铁矿石回收","碎石回收","沙子回收","废料中和"},
  },
  prerequisites = {"无机化学"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 24,
  time = "6s"
}

prototype "石头处理3" {
  desc = "研究可进行高温加工的特殊器皿",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"坩埚"},
    unlock_item = {"坩埚"},
  },
  prerequisites = {"硅处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 24,
  time = "8s"
}

prototype "坩埚制造" {
  desc = "生产可高温加工的坩埚",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "坩埚"},
  prerequisites = {"石头处理3"},
  count = 20,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产20个坩埚", icon = "textures/construct/industry.texture"},
  },
}

prototype "有机化学3" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"橡胶"},
    unlock_item = {"橡胶"},
  },
  prerequisites = {"化学工程1"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 24,
  time = "8s"
}

prototype "无人机运输2" {
  desc = "使用无人机快速运送物品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"无人机仓库2"},
    unlock_item = {"无人机仓库II"},
  },
  prerequisites = {"有机化学3","炼钢"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 30,
  time = "8s"
}

prototype "冶金学2" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"熔炼炉2"},
    unlock_item = {"熔炼炉II"},
  },
  prerequisites = {"石头处理3","铁矿熔炼2"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 40,
  time = "6s"
}

prototype "铝生产" {
  desc = "加工铝矿的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"碾碎铝矿石","铝矿石浮选","氧化铝","铝板1"},
    unlock_item = {"铝板","碾碎铝矿石","氧化铝"},
  },
  prerequisites = {"无机化学","冶金学2"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 40,
  time = "6s"
}

prototype "硅生产" {
  desc = "将硅加工硅板的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"硅板1"},
    unlock_item = {"硅板"},
  },
  prerequisites = {"无机化学","冶金学2"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 60,
  time = "6s"
}

prototype "硅板制造" {
  desc = "生产大量的硅板",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "硅板"},
  prerequisites = {"硅生产"},
  count = 30,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产30个硅板", icon = "textures/construct/industry.texture"},
  },
}

prototype "润滑" {
  desc = "研究工业润滑油制作工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"润滑油"},
    unlock_item = {"润滑油"},
  },
  prerequisites = {"硅生产"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 60,
  time = "5s"
}

prototype "铝加工" {
  desc = "使用铝加工其他零器件的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"铝丝1","铝棒1"},
    unlock_item = {"铝丝","铝棒"},
  },
  prerequisites = {"铝生产","冶金学2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 50,
  time = "8s"
}

prototype "铝丝制造" {
  desc = "生产铝制的金属丝",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "铝丝"},
  prerequisites = {"铝加工"},
  count = 40,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产40个铝丝", icon = "textures/construct/industry.texture"},
  },
}

prototype "沸腾实验" {
  desc = "通过加热液体获取蒸汽的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"换热器1","热管1","纯水沸腾","卤水沸腾"},
    unlock_item = {"换热器I","热管1-X型"},
  },
  prerequisites = {"铝丝制造"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 30,
  time = "5s"
}

prototype "电子器件1" {
  desc = "生产精密的电子元器件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电容1","绝缘线1","逻辑电路1"},
    unlock_item = {"电容I","绝缘线","逻辑电路"},
  },
  prerequisites = {"铝加工","硅生产"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 80,
  time = "5s"
}

prototype "电力传输2" {
  desc = "将电能远距离传输的技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"远程电线杆"},
    unlock_item = {"远程电线杆"},
  },
  prerequisites = {"电子器件1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 60,
  time = "12s"
}

prototype "太阳能存储1" {
  desc = "研究将太阳能板转化的电能进行储存的电池",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蓄电池1"},
    unlock_item = {"蓄电池I"},
  },
  prerequisites = {"电力传输2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 60,
  time = "15s"
}

prototype "电子研究" {
  desc = "研究由电能作用的材料或设备",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电子科技包1"},
    unlock_item = {"电子科技包"},
  },
  prerequisites = {"电子器件1","电力传输2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "textures/science/key_sign.texture"},
  },
  sign_icon = "textures/science/tech-key_sign.texture",
  count = 100,
  time = "5s"
}

---------------------------化学研究---------------------------
prototype "电磁学2" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电动机2"},
    unlock_item = {"电动机II"},

  },
  prerequisites = {"电子研究"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 30,
  time = "10s"
}

prototype "研究设施1" {
  desc = "研究可以开展大规模研发的设施",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"科研中心1"},
    unlock_item = {"科研中心I"},
  },
  prerequisites = {"电子研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 15,
  time = "10s"
}


prototype "科技大跃进" {
  desc = "生产更多的科研中心I",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "科研中心I"},
  prerequisites = {"研究设施1"},
  count = 3,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产3个科研中心", icon = "textures/construct/industry.texture"},
  },
}


prototype "信号处理" {
  desc = "研究电子信号传输介质",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"数据线1"},
    unlock_item = {"数据线"},
  },
  prerequisites = {"研究设施1"},
  ingredients = {
    {"气候科技包", 1},
    {"电子科技包", 1},
  },
  count = 30,
  time = "10s"
}
  

prototype "计算元件" {
  desc = "研究可进行复杂计算的电路集群",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"运算电路1"},
    unlock_item = {"运算电路"},
  },
  prerequisites = {"信号处理"},
  ingredients = {
    {"气候科技包", 1},
    {"电子科技包", 1},
  },
  count = 70,
  time = "10s"
}

prototype "电解2" {
  desc = "使用电化学手段制取工业气体",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电解厂2"},
    unlock_item = {"电解厂II"},
  },
  prerequisites = {"计算元件"},
  ingredients = {
    {"气候科技包", 1},
    {"电子科技包", 1},
  },
  count = 80,
  time = "15s"
}

prototype "挖掘2" {
  desc = "研究对火星岩石的开采技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"采矿机2"},
    unlock_item = {"采矿机II"},
  },
  prerequisites = {"计算元件"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 50,
  time = "15s"
}

prototype "水能利用" {
  desc = "研究淡水处理的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"淡水沸腾","淡水过滤"},
  },
  prerequisites = {"计算元件"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 40,
  time = "15s"
}

prototype "自动化2" {
  desc = "使用3D打印技术复制物品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"组装机2"},
    unlock_item = {"组装机II"},
  },
  prerequisites = {"水能利用"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 60,
  time = "15s"
}

prototype "发电机2" {
  desc = "使用蒸汽作为工质将热能转为机械能的发电装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蒸汽发电机2"},
    unlock_item = {"蒸汽发电机II"},
  },
  prerequisites = {"自动化2"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 70,
  time = "25s"
}

prototype "优化1" {
  desc = "研究提高生产效率的插件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"效能插件1","速度插件1","产能插件1"},
    unlock_item = {"效能插件I","速度插件I","产能插件I"},
  },
  prerequisites = {"发电机2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 150,
  time = "15s"
}

prototype "广播1" {
  desc = "研究可影响周边生产设施工作效率的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"广播塔1"},
    unlock_item = {"广播塔I"},
  },
  prerequisites = {"发电机2"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 100,
  time = "20s"
}

prototype "效能提升" {
  desc = "生产可以降低机器能耗的插件",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "效能插件I"},
  prerequisites = {"优化1","广播1"},
  count = 5,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个效能插件I", icon = "textures/construct/industry.texture"},
  },
}

prototype "速度提升" {
  desc = "生产可以加速机器生产的插件",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "速度插件I"},
  prerequisites = {"优化1","广播1"},
  count = 5,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个速度插件I", icon = "textures/construct/industry.texture"},
  },
}

prototype "产能提升" {
  desc = "生产可以提高机器产能的插件",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "产能插件I"},
  prerequisites = {"优化1","广播1"},
  count = 5,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个产能插件I", icon = "textures/construct/industry.texture"},
  },
}

prototype "矿物处理2" {
  desc = "将矿物进行碾碎并再加工的机械工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"粉碎机2"},
    unlock_item = {"粉碎机II"},
  },
  prerequisites = {"优化1","广播1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 60,
  time = "25s"
}

prototype "氮化学" {
  desc = "研究含氮的化合物生产",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"氨气"},
    unlock_item = {"氨气"},
  },
  prerequisites = {"矿物处理2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 60,
  time = "15s"
}

prototype "氨制造" {
  desc = "生产工业气体氨气",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "氨气"},
  prerequisites = {"氮化学"},
  count = 500,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个速度插件I", icon = "textures/construct/industry.texture"},
  },
}

prototype "气候研究2" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"气候科技包2"},
  },
  prerequisites = {"氮化学"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 60,
  time = "15s"
}

prototype "玻璃制造" {
  desc = "研究更高效生产玻璃的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"玻璃2"},
  },
  prerequisites = {"气候研究2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 90,
  time = "15s"
}

prototype "建筑材料" {
  desc = "研究可以用于建材的新型材料",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_item = {"混凝土"},
  },
  prerequisites = {"玻璃制造"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 150,
  time = "15s"
}

prototype "电力传输3" {
  desc = "将电能远距离传输的技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"广域电线杆"},
    unlock_item = {"广域电线杆"},
  },
  prerequisites = {"建筑材料"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 150,
  time = "12s"
}

prototype "地下水净化2" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"水电站2","地下水挖掘机2"},
    unlock_item = {"水电站II","地下水挖掘机II"},
  },
  prerequisites = {"电力传输3"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 160,
  time = "30s"
}

prototype "地热1" {
  desc = "研究开发地热资源的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"地热井1"},
    unlock_item = {"地热井I"},
  },
  prerequisites = {"建筑材料"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 120,
  time = "20s"
}

prototype "太阳能1" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"太阳能板1"},
    unlock_item = {"太阳能板I"},
  },
  prerequisites = {"建筑材料"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 150,
  time = "20s"
}

prototype "铺设太阳能板" {
  desc = "铺设更多的太阳能板",
  icon = "textures/construct/industry.texture",
  type = {"task" },
  task = {"select_entity", 0, "太阳能板I"},
  prerequisites = {"太阳能1"},
  count = 20,
  tips_pic = {
    "textures/task_tips_pic/task_place_logistics.texture",
  },
  sign_desc = {
    { desc = "放置20个太阳能板I", icon = "textures/construct/industry.texture"},
  },
}

prototype "蒸馏2" {
  desc = "将液体混合物汽化并分离的技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蒸馏厂2"},
    unlock_item = {"蒸馏厂II"},
  },
  prerequisites = {"太阳能1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 170,
  time = "30s"
}

prototype "硫磺处理" {
  desc = "加工含硫地热气获得其他化工品的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_item = {"硫酸"},
  },
  prerequisites = {"太阳能1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 120,
  time = "20s"
}

prototype "硫酸生产" {
  desc = "生产大量的硫酸",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "硫酸"},
  prerequisites = {"硫磺处理"},
  count = 500,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产500个单位硫酸", icon = "textures/construct/industry.texture"},
  },
}

prototype "过滤2" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"空气过滤器2"},
    unlock_item = {"空气过滤器II"},
  },
  prerequisites = {"硫磺处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 200,
  time = "30s"
}

prototype "浮选2" {
  desc = "使用浮选设备对矿石实行筛选",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"浮选器2"},
    unlock_item = {"浮选器II"},
  },
  prerequisites = {"硫磺处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 200,
  time = "30s"
}

prototype "化学工程2" {
  desc = "使用特殊设施生产化工产品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"化工厂2"},
    unlock_item = {"化工厂II"},
  },
  prerequisites = {"硫磺处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 200,
  time = "30s"
}

prototype "化学研究" {
  desc = "对化学反应进行深度研究",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"化学科技包1"},
    unlock_item = {"化学科技包"},
  },
  prerequisites = {"过滤2","浮选2","化学工程2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "textures/science/key_sign.texture"},
  },
  sign_icon = "textures/science/tech-key_sign.texture",
  count = 250,
  time = "30s"
}


---------------------------------物流研究-------------------------------------

prototype "钠处理" {
  desc = "研究获取钠原料的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"氢氧化钠电解"},
    unlock_item = {"钠"},
  },
  prerequisites = {"化学研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 120,
  time = "20s"
}

prototype "空气分离工艺2" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"空气分离2"},
    unlock_item = {"氦气"},
  },
  prerequisites = {"化学研究"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 160,
  time = "30s"
}

prototype "氦气生产" {
  desc = "生产更多的氦气",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "氦气"},
  prerequisites = {"空气分离工艺2"},
  count = 500,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产500个单位氦气", icon = "textures/construct/industry.texture"},
  },
}

prototype "排放2" {
  desc = "研究气体和液体的排放工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"烟囱2","排水口2"},
    unlock_item = {"烟囱II","排水口II"},
  },
  prerequisites = {"氦气生产"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 250,
  time = "30s"
}

prototype "钛生产1" {
  desc = "研究可以提取钛原料的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"金红石1"},
    unlock_item = {"金红石"},
  },
  prerequisites = {"氦气生产"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 300,
  time = "30s"
}

prototype "高温分解" {
  desc = "研究在高温下化合石墨的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"甲烷转石墨"},
  },
  prerequisites = {"钠处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 200,
  time = "30s"
}

prototype "电池存储1" {
  desc = "研究可以储存和释放电能的元件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电池1"},
    unlock_item = {"电池I"},
  },
  prerequisites = {"高温分解"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 450,
  time = "30s"
}

prototype "电池制造" {
  desc = "生产更多的电池元件",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "电池I"},
  prerequisites = {"电池存储1"},
  count = 20,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产20个电池", icon = "textures/construct/industry.texture"},
  },
}

prototype "复合材料" {
  desc = "多种材料组合成多相材料",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"玻璃纤维1"},
    unlock_item = {"玻璃纤维"},
  },
  prerequisites = {"电池存储1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"化学科技包", 1},
  },
  count = 550,
  time = "30s"
}

prototype "太阳能存储2" {
  desc = "研究将太阳能板转化的电能进行储存的电池",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蓄电池2"},
    unlock_item = {"蓄电池II"},
  },
  prerequisites = {"复合材料"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1}, 
    {"化学科技包", 1},
  },
  count = 320,
  time = "30s"
}

prototype "钛生产2" {
  desc = "研究可以提取钛原料的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"四氯化钛","钛板"},
    unlock_item = {"四氯化钛","钛板"},
  },
  prerequisites = {"太阳能存储2","钛生产1"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "钛板生产" {
  desc = "生产更多的钛板",
  icon = "textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "钛板"},
  prerequisites = {"钛生产2"},
  count = 30,
  tips_pic = {
    "textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用浮选器生产30个钛板", icon = "textures/construct/industry.texture"},
  },
}

prototype "无人机运输3" {
  desc = "使用无人机快速运送物品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"无人机仓库3"},
    unlock_item = {"无人机仓库III"},
  },
  prerequisites = {"钛生产2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "自动化3" {
  desc = "使用3D打印技术复制物品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"组装机3"},
    unlock_item = {"组装机III"},
  },
  prerequisites = {"钛生产2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "挖掘3" {
  desc = "研究对火星岩石的开采技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"采矿机3"},
    unlock_item = {"采矿机III"},
  },
  prerequisites = {"钛生产2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "电子器件2" {
  desc = "生产精密的电子元器件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"处理器1"},
    unlock_item = {"处理器I"},
  },
  prerequisites = {"无人机运输3","自动化3","挖掘3"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 360,
  time = "30s"
}

prototype "广播2" {
  desc = "研究可影响周边生产设施工作效率的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"广播塔2"},
    unlock_item = {"广播塔II"},
  },
  prerequisites = {"电子器件2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 380,
  time = "30s"
}

prototype "优化2" {
  desc = "研究提高生产效率的插件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"效能插件2","速度插件2","产能插件2"},
    unlock_item = {"效能插件II","速度插件II","产能插件II"},
  },
  prerequisites = {"广播2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 400,
  time = "30s"
}

prototype "矿物处理3" {
  desc = "将矿物进行碾碎并再加工的机械工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"粉碎机3"},
    unlock_item = {"粉碎机III"},
  },
  prerequisites = {"优化2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 420,
  time = "30s"
}

prototype "太阳能2" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"太阳能板2"},
    unlock_item = {"太阳能板II"},
  },
  prerequisites = {"优化2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 420,
  time = "30s"
}

prototype "管道系统3" {
  desc = "研究可储藏气液原料的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"液罐3"},
    unlock_item = {"液罐III"},
  },
  prerequisites = {"优化2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"化学科技包", 1},
  },
  count = 420,
  time = "30s"
}

prototype "地热2" {
  desc = "研究开发地热资源的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"地热井2"},
    unlock_item = {"地热井II"},
  },
  prerequisites = {"矿物处理3","太阳能2","管道系统3"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 500,
  time = "30s"
}

prototype "研究设施2" {
  desc = "研究可以开展大规模研发的设施",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"科研中心2"},
    unlock_item = {"科研中心II"},
  },
  prerequisites = {"矿物处理3","太阳能2","管道系统3"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 550,
  time = "30s"
}

prototype "高温防护" {
  desc = "研究能够耐高温的材料",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"隔热板1"},
    unlock_item = {"隔热板"},
  },
  prerequisites = {"研究设施2","地热2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 600,
  time = "35s"
}

prototype "物理研究" {
  desc = "研究物质结构以及基本运动规律",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"物理科技包1"},
    unlock_item = {"物理科技包"},
  },
  prerequisites = {"高温防护"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 800,
  time = "35s"
}

--------------------------------------rocket-------------------------------------
prototype "电磁学3" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电动机3"},
    unlock_item = {"电动机III"},
  },
  prerequisites = {"物理研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 800,
  time = "40s"
}

prototype "研究设施3" {
  desc = "研究可以开展大规模研发的设施",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"科研中心3"},
    unlock_item = {"科研中心III"},
  },
  prerequisites = {"物理研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1000,
  time = "40s"
}

prototype "石墨分离" {
  desc = "研究将石墨分离成单层材料的工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"石墨烯"},
    unlock_item = {"石墨烯"},
  },
  prerequisites = {"研究设施3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 800,
  time = "40s"
}

prototype "地下水净化3" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"水电站3"},
    unlock_item = {"水电站III"},
  },
  prerequisites = {"电磁学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1000,
  time = "40s"
}

prototype "过滤3" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"空气过滤器3"},
    unlock_item = {"空气过滤器III"},
  },
  prerequisites = {"电磁学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1200,
  time = "40s"
}

prototype "冶金学3" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"熔炼炉3"},
    unlock_item = {"熔炼炉III"},
  },
  prerequisites = {"电磁学3","研究设施3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1300,
  time = "40s"
}

prototype "浮选3" {
  desc = "使用浮选设备对矿石实行筛选",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"浮选器3"},
    unlock_item = {"浮选器III"},
  },
  prerequisites = {"冶金学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1400,
  time = "40s"
}

prototype "蒸馏3" {
  desc = "将液体混合物汽化并分离的技术",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蒸馏厂3"},
    unlock_item = {"蒸馏厂III"},
  },
  prerequisites = {"冶金学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1500,
  time = "40s"
}

prototype "发电机3" {
  desc = "使用蒸汽作为工质将热能转为机械能的发电装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蒸汽发电机3"},
    unlock_item = {"蒸汽发电机III"},
  },
  prerequisites = {"浮选3","蒸馏3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1500,
  time = "40s"
}

prototype "微型化" {
  desc = "研究更加精密的电容元器件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电容2"},
    unlock_item = {"电容II"},
  },
  prerequisites = {"发电机3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1600,
  time = "40s"
}

prototype "电池存储2" {
  desc = "研究可以储存和释放电能的小型装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电池2"},
    unlock_item = {"电池II"},
  },
  prerequisites = {"微型化"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1600,
  time = "40s"
}

prototype "电解3" {
  desc = "使用电化学手段制取工业气体",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"电解厂3"},
    unlock_item = {"电解厂III"},
  },
  prerequisites = {"电池存储2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1600,
  time = "40s"
}

prototype "电子器件3" {
  desc = "研究更加精密的电容元器件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"处理器2"},
    unlock_item = {"处理器II"},
  },
  prerequisites = {"电池存储2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1600,
  time = "40s"
}

prototype "地热3" {
  desc = "研究开发地热资源的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"地热井3"},
    unlock_item = {"地热井III"},
  },
  prerequisites = {"电解3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1700,
  time = "40s"
}

prototype "化学工程3" {
  desc = "使用特殊设施生产化工产品",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"化工厂3"},
    unlock_item = {"化工厂III"},
  },
  prerequisites = {"电解3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1800,
  time = "40s"
}

prototype "太阳能3" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"太阳能板3"},
    unlock_item = {"太阳能板III"},
  },
  prerequisites = {"地热3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1800,
  time = "40s"
}

prototype "优化3" {
  desc = "研究提高生产效率的插件",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"效能插件3","速度插件3","产能插件3"},
    unlock_item = {"效能插件III","速度插件III","产能插件III"},
  },
  prerequisites = {"太阳能3","化学工程3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 2200,
  time = "45s"
}

prototype "太阳能存储3" {
  desc = "研究将太阳能板转化的电能进行储存的电池",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"蓄电池3"},
    unlock_item = {"蓄电池III"},
  },
  prerequisites = {"优化3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 2600,
  time = "45s"
}

prototype "广播3" {
  desc = "研究可影响周边生产设施工作效率的装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"广播塔3"},
    unlock_item = {"广播塔III"},
  },
  prerequisites = {"太阳能3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 2800,
  time = "45s"
}

prototype "火箭化学" {
  desc = "研究可供火箭运行的燃料",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"火箭燃料1"},
    unlock_item = {"火箭燃料"},
  },
  prerequisites = {"广播3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 3500,
  time = "45s"
}

prototype "火箭控制" {
  desc = "研究控制火箭运行的仪器",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"火箭控制器1"},
    unlock_item = {"火箭控制器"},
  },
  prerequisites = {"火箭化学"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 4000,
  time = "45s"
}

prototype "火箭架构" {
  desc = "研究组成火箭外部框架",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"火箭区段1"},
    unlock_item = {"火箭区段"},
  },
  prerequisites = {"火箭化学"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 4200,
  time = "45s"
}

prototype "火箭保护" {
  desc = "研究保护火箭前端的特殊材料",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"火箭整流罩1"},
    unlock_item = {"火箭整流罩"},
  },
  prerequisites = {"火箭化学"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 5000,
  time = "45s"
}

