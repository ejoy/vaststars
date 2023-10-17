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


  prototype "采矿教学" {
    desc = "学习如何在游戏中采矿",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
      -- unlock_recipe = {"采矿机打印"},
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
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 129,
      },
    },
    sign_desc = {
      { desc = "搜索机身残骸获取有用物资", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
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
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 135,
        y = 122,
        w = 3.2,
        h = 3.2,
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 127,
        y = 136,
        w = 3.2,
        h = 3.2,
        show_arrow = true,
      },
      {
        camera_x = 126,
        camera_y = 128,
      },
    },
    sign_desc = {
      { desc = "在石矿、铁矿、铝矿各放置1台采矿机", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "电网搭建" {
    desc = "使得3台采矿机通电",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "铁制电线杆"},
    prerequisites = {"采矿机放置"},
    count = 6,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 122,
        y = 122,
        w = 3.2,
        h = 3.2,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 128,
        y = 122,
        w = 1.2,
        h = 1.2,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 133,
        y = 122,
        w = 1.2,
        h = 1.2,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 122,
        w = 1.2,
        h = 1.2,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 128,
        w = 1.2,
        h = 1.2,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 136,
        w = 1.2,
        h = 1.2,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 124,
        y = 136,
        w = 1.2,
        h = 1.2,
        show_arrow = false,
      },
      {
        camera_x = 126,
        camera_y = 128,
      },
    },
    sign_desc = {
      { desc = "放置电线杆连接风力发电机让3台采矿机处于电网范围内", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "仓库放置" {
    desc = "放置1座仓库",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "仓库I"},
    prerequisites = {"电网搭建"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 120,
        y = 117,
        w = 1.2,
        h = 1.2,
        show_arrow = false,
      },
      {
        camera_x = 120,
        camera_y = 117,
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
      { desc = "仓库设置收货选择“碎石”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "仓库存储矿石" {
    desc = "仓库存储碎石",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },                     
    task = {"unknown", 0, 7},
    task_params = {building = "仓库I", item = "碎石"},
    prerequisites = {"收货设置1"},
    count = 4,
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 130,
        w = 3.2,
        h = 3.2,
        show_arrow = false,
      },
      {
        camera_x = 116,
        camera_y = 130,
      },
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "向仓库里放置4块碎石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
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
        y = 116,
        w = 3.2,
        h = 3.2,
        show_arrow = true,
      },
      {
        camera_x = 123,
        camera_y = 116,
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