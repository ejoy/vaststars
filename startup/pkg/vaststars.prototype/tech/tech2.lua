local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

  -- prototype "电网教学" {
  --   desc = "电网教学",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"unknown", 0, 4},
  --   effects = {
  --     -- unlock_recipe = {"采矿机打印"},
  --   },
  --   prerequisites = {},
  --   count = 1,
  --   tips_pic = {
  --     "",
  --   },
  --   sign_desc = {
  --     { desc = "初次进入火星", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "检查废墟" {
    desc = "从废墟中搜索物资",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "set_transfer_source", building = "机身残骸"},
    prerequisites = {"电网教学"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 117,
        y = 125,
        w = 4.0,
        h = 4.0,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 117,
        camera_y = 125,
        w = 4.0,
        h = 4.0,
      },
    },
    sign_desc = {
      { desc = "搜索机身残骸获取有用物资", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "放置资源" {
    desc = "将物资放置至指挥中心",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 7},
    task_params = {building = "指挥中心", item = "采矿机I", count = 3,},
    prerequisites = {"检查废墟"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 128.5,
        y = 122.5,
        w = 5.2,
        h = 5.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 128,
        camera_y = 122,
        w = 4.0,
        h = 4.0,
      },
    },
    sign_desc = {
      { desc = "将废墟获取的采矿机放置至指挥中心", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
}

  prototype "矿区搭建" {
    desc = "放置3台采矿机",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "采矿机I"},
    prerequisites = {"放置资源"},
    count = 3,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 106,
        y = 128,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 132,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 107,
        y = 137,
        w = 3.2,
        h = 3.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 113,
        camera_y = 134,
        w = 3.2,
        h = 3.2,
      },
    },
    effects = {
      unlock_item = {"碎石","铁矿石","铝矿石"},
    },
    sign_desc = {
      { desc = "在石矿、铁矿、铝矿上各放置1台采矿机", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "风力发电机放置" {
    desc = "放置1座轻型风力发电机",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 10},
    task_params = {building = "采矿机I"},
    count = 3,
    effects = {
      unlock_item = {"轻质石砖"},
      unlock_recipe = {"轻质石砖"},
    },
    prerequisites = {"矿区搭建"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        camera_x = 112,
        camera_y = 131,
        w = 3.2,
        h = 3.2,
      },
    },
    sign_desc = {
      { desc = "放置1座轻型风力发电机给基地供电", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "生产设置" {
    desc = "组装机配方选择地质科技包1",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "轻质石砖"},
    count = 1,
    prerequisites = {"风力发电机放置"},
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 124,
        y = 131,
        w = 3.0,
        h = 3.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 132,
        y = 131,
        w = 3.0,
        h = 3.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 128,
        camera_y = 130,
        w = 3.0,
        h = 3.0,
      },
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "组装机生产设置为“轻质石砖”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "新仓库设置" {
    desc = "仓库选择碎石",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 8},
    task_params = {items = {"transit|碎石", "transit|铁矿石","transit|铝矿石","transit|轻质石砖"}},
    count = 1,
    prerequisites = {"生产设置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 128,
        y = 133,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 128,
        camera_y = 132,
        w = 1.2,
        h = 1.2,
      },
    },
    sign_desc = {
      { desc = "仓库设置收货选择“碎石”、“铁矿石”、“铝矿石”、“轻质石砖”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "仓库互转" {
    desc = "仓库放置铝矿石",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },                     
    task = {"unknown", 0, 7},
    task_params = {building = "仓库I", item = "铝矿石"},
    prerequisites = {"新仓库设置"},
    count = 10,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 128,
        y = 133,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 111,
        y = 133,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 128,
        camera_y = 132,
        w = 1.2,
        h = 1.2,
      },
    },
    sign_desc = {
      { desc = "向新仓库里放置10块铝矿石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "生产轻质石砖" {
    desc = "规模生产生产轻质石砖",
    type = { "task" },
    task = {"stat_production", 0, "轻质石砖"},
    count = 2,
    prerequisites = {"仓库互转"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产2个轻质石砖", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "太阳能板获取" {
    desc = "检查废墟获取资源",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 7},
    task_params = {building = "指挥中心", item = "轻型太阳能板", count = 1,},
    count = 1,
    prerequisites = {"生产轻质石砖"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 141,
        y = 137,
        w = 2.2,
        h = 2.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 141,
        camera_y = 137,
        w = 2.2,
        h = 2.2,
      },
    },
    sign_desc = {
      { desc = "从废墟里获取1个太阳能板放置入指挥中心", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "太阳能板铺设" {
    desc = "太阳能板接入电网",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 10},
    task_params = {building = "轻型太阳能板"},
    count = 1,
    prerequisites = {"太阳能板获取"},
    effects = {
      unlock_item = {"铁板"},
      unlock_recipe = {"铁板1"},
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置1个轻型太阳能板", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "蓄电池铺设" {
    desc = "蓄电池接入电网",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 10},
    task_params = {building = "蓄电池I"},
    count = 4,
    prerequisites = {"太阳能板铺设"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置4个蓄电池", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  -- prototype "太阳能制造技术" {
  --   desc = "研究生产太阳能板工艺",
  --   type = { "tech" },
  --   effects = {
  --     unlock_item = {"轻型太阳能板","铁板"},
  --     unlock_recipe = {"轻型太阳能板","铁板1"},
  --   },
  --   prerequisites = {"太阳能发电"},
  --   ingredients = {
  --     {"地质科技包", 1},
  --   },
  --   count = 3,
  --   time = "5s"
  -- }

  prototype "铁板生产" {
    desc = "规模生产铁板",
    type = { "task" },
    task = {"unknown", 0, 3}, 
    task_params = {recipe = "铁板1"},
    count = 1,
    prerequisites = {"蓄电池铺设"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 128,
        y = 131,
        w = 3.0,
        h = 3.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 128,
        camera_y = 131,
        w = 3.0,
        h = 3.0,
      },
    },
    effects = {
      unlock_item = {"轻型太阳能板"},
      unlock_recipe = {"轻型太阳能板"},
    },
    sign_desc = {
      { desc = "在熔炼炉进行铁板生产", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "太阳能板制造" {
    desc = "制造轻型太阳能板",
    type = { "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "set_transfer_source", building = "组装机I"}, 
    count = 1,
    prerequisites = {"铁板生产"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "用组装机生产并获取1个轻型太阳能板", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "太阳能发电" {
    desc = "铺设发电设施让基地供电充足",
    type = { "task" },
    task = {"power_generator", 3},
    count = 600,
    prerequisites = {"太阳能板制造"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "铺设太阳能板让基地发电量达到600kW", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "发电机获取" {
    desc = "检查废墟获取资源",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "set_transfer_source", building = "机尾残骸"},
    count = 1,
    prerequisites = {"太阳能发电"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 130,
        y = 115,
        w = 3.1,
        h = 3.1,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 130,
        camera_y = 115,
        w = 3.1,
        h = 3.1,
      },
    },
    sign_desc = {
      { desc = "从废墟里获取4个太阳能板", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "锅炉放置" {
    desc = "放置锅炉",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "锅炉I"},
    count = 1,
    effects = {
      unlock_recipe = {"卤水沸腾"},
    },
    prerequisites = {"发电机获取"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置1座锅炉", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "锅炉设置" {
    desc = "锅炉设置生产配方",
    type = { "task" },
    task = {"unknown", 0, 3}, 
    task_params = {recipe = "卤水沸腾"},
    count = 1,
    prerequisites = {"锅炉放置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "锅炉设置“卤水沸腾”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "地下水挖掘机放置" {
    desc = "放置地下水挖掘机",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 11},
    task_params = {building = "锅炉I", fluids = {"地下卤水"}},
    count = 1,
    prerequisites = {"锅炉设置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    effects = {
      unlock_recipe = {"蒸汽发电"},
    },
    sign_desc = {
      { desc = "放置1台地下水挖掘机连接锅炉对应液口", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "发电机放置" {
    desc = "放置蒸汽发电机",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 11},
    task_params = {building = "蒸汽发电机I", fluids = {"蒸汽"}},
    count = 1,
    prerequisites = {"地下水挖掘机放置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    effects = {
      unlock_item = {"地质科技包"},
      unlock_recipe = {"地质科技包1"},
    },
    sign_desc = {
      { desc = "放置1台蒸汽发电机并连接锅炉对应液口", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "生产科技包" {
    desc = "规模生产地质科技包",
    type = { "task" },
    task = {"stat_production", 0, "地质科技包"},
    count = 3,
    prerequisites = {"发电机放置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产3个地质科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "启动科技研究" {
    desc = "进行地质科学分析",
    type = { "tech" },
    prerequisites = {"生产科技包"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 5,
    time = "1s"
  }

  prototype "电网教学结束" {
    desc = "教学结束",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {"启动科技研究"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的电网教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }