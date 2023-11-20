local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

  --task = {"stat_production", 0, "铁矿石"},            生产XX个物品
  --task = {"stat_consumption", 0, "铁矿石"},           消耗XX个物品
  --task = {"select_entity", 0, "组装机"},              拥有XX台机器
  --task = {"select_chest", 0, "指挥中心", "铁丝"},     向指挥中心转移X个物品
  --task = {"power_generator", 0},                      电力发电到达X瓦
  --task = {"unknown", 0},                              自定义任务
  
  --task = {"unknown", 0, 2},                           派遣运输车

  --task = {"unknown", 0, 3},                           自定义任务，组装机指定选择配方
  --task_params = {recipe = "地质科技包1"},
  --count = 1,
  --time是指1个count所需的时间

  -- task = {"unknown", 0, 5},                          自定义任务，无人机平台I指定选择物品
  -- task_params = {item = "采矿机框架"},

  -- task = {"unknown", 0, 6},
  -- task_params = {ui = "pickup_item", building = "xxx"},    收取物品

  -- task = {"unknown", 0, 6},
  -- task_params = {ui = "place_item",  building = "xxx"},  放置物品

  -- task = {"unknown", 0, 7},
  -- task_params = {building = "xx", item = "xx", count = xx,}  放置物品到指定建筑

  -- task = {"unknown", 0, 8},
  -- task_params = {items = {"demand|xx", "supply|xx", ...}}     车站设置多个收货/发货物品
  
  -- task = {"unknown", 0, 8},
  -- task_params = {items = {"transit|碎石", "transit|铁矿石","transit|铝矿石"}}, 仓库任务

  -- task = {"unknown", 0, 9},                 从指定建筑提出指定物品指定数量
  -- task_params = {building = xx, item = xx, }
  -- count = xx

  -- task = {"unknown", 0, 10},           x个建筑处于通电状态
  -- task_params = {building = xx, }
  -- count = xx

  -- task = {"unknown", 0, 11},               X建筑的指定水口连接液体
  -- task_params = {building = xx, fluids = {xx, xx}}
  -- count = 1

  prototype "采矿教学" {
    desc = "学习如何在游戏中采矿",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "正式进入采矿教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "拾取物资" {
    desc = "从废墟中搜索物资",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "pickup_item", building = "机身残骸"},
    prerequisites = {"采矿教学"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 123,
        y = 131,
        w = 4.0,
        h = 4.0,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 129,
        w = 4.0,
        h = 4.0,
      },
    },
    sign_desc = {
      { desc = "搜索机身残骸获取有用物资", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "放置指挥中心" {
    desc = "将物资放置至指挥中心",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 7},
    task_params = {building = "指挥中心", item = "采矿机I", count = 3,},
    prerequisites = {"拾取物资"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 132.5,
        y = 114.5,
        w = 5.2,
        h = 5.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 130,
        camera_y = 112,
        w = 4.0,
        h = 4.0,
      },
    },
    sign_desc = {
      { desc = "将废墟获取的采矿机放置至指挥中心", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "采矿机放置" {
    desc = "放置3台采矿机",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "采矿机I"},
    prerequisites = {"拾取物资"},
    count = 3,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 130,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 132,
        y = 124,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 127,
        y = 136,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 126,
        camera_y = 128,
        w = 3.2,
        h = 3.2,
      },
    },
    sign_desc = {
      { desc = "在石矿、铁矿、铝矿各放置1台采矿机", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "仓库放置" {
    desc = "放置1座仓库",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "仓库I"},
    prerequisites = {"采矿机放置"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 120,
        y = 121,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 120,
        camera_y = 121,
        w = 1.2,
        h = 1.2,
      },
    },
    effects = {
       unlock_item = {"碎石","铁矿石","铝矿石"},
    },
    sign_desc = {
      { desc = "放置1座仓库", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "收货设置1" {
    desc = "仓库选择碎石",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 8},
    task_params = {items = {"transit|碎石", "transit|铁矿石","transit|铝矿石"}},
    count = 1,
    prerequisites = {"仓库放置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    effects = {
      unlock_item = {"地质科技包"},
      unlock_recipe = {"地质科技包1"},
    },
    sign_desc = {
      { desc = "仓库设置收货选择“碎石”、“铁矿石”、“铝矿石”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "获取碎石" {
    desc = "从采矿机获取碎石",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },                     
    task = {"unknown", 0, 6},
    task_params = {ui = "pickup_item", building = "采矿机I"},
    prerequisites = {"收货设置1"},
    count = 1,
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 130,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 116,
        camera_y = 130,
        w = 3.2,
        h = 3.2,
      },
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "从采矿机上获取1块碎石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "仓库存储矿石" {
    desc = "仓库存储碎石",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },                     
    task = {"unknown", 0, 7},
    task_params = {building = "仓库I", item = "碎石"},
    prerequisites = {"获取碎石"},
    count = 6,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "向仓库里放置6块碎石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "组装机配方设置" {
    desc = "组装机配方选择地质科技包1",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "地质科技包1"},
    count = 1,
    prerequisites = {"仓库存储矿石"},
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 123,
        y = 122,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 123,
        camera_y = 116,
        w = 3.2,
        h = 3.2,
      },
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "组装机生产设置为“地质科技包1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "收货设置2" {
    desc = "配方选择地质科技包",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 5},                          
    task_params = {item = "地质科技包"},
    count = 1,
    prerequisites = {"组装机配方设置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    effects = {
    },
    sign_desc = {
      { desc = "仓库设置收货选择“地质科技包”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "科技包生产" {
    desc = "组装机生产3个地质科技包",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "地质科技包"},
    prerequisites = {"收货设置2"},
    count = 3,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack3.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack4.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack5.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack6.texture",
    },
    sign_desc = {
      { desc = "供应碎石、铁矿石、铝矿石各6个作为原料供组装机生产", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "挖矿教学结束" {
    desc = "教学结束",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {"科技包生产"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的挖矿教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }