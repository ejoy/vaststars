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
  

  prototype "电网教学" {
    desc = "电网教学",
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
      { desc = "初次进入火星", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "检查废墟" {
    desc = "从废墟中搜索物资",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "pickup_item", building = "机身残骸"},
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
        show_arrow = true,
      },
      {
        camera_x = 117,
        camera_y = 125,
      },
    },
    sign_desc = {
      { desc = "搜索机身残骸获取有用物资", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "矿区搭建" {
    desc = "放置3台采矿机",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "采矿机I"},
    prerequisites = {"检查废墟"},
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
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 116,
        y = 132,
        w = 3.2,
        h = 3.2,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 107,
        y = 138,
        w = 3.2,
        h = 3.2,
        show_arrow = false,
      },
      {
        camera_x = 113,
        camera_y = 134,
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
    desc = "放置1座旧风力发电机",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "旧风力发电机"},
    prerequisites = {"矿区搭建"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 112,
        y = 130,
        w = 3.2,
        h = 3.2,
        show_arrow = true,
      },
      {
        camera_x = 112,
        camera_y = 130,
      },
    },
    sign_desc = {
      { desc = "放置1座旧风力发电机供电给矿区的无人机平台", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  

  prototype "收集矿石" {
    desc = "仓库选择收货类型",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 8},
    task_params = {items = {"transit|碎石", "transit|铁矿石","transit|铝矿石"}},
    count = 1,
    prerequisites = {"风力发电机放置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 111,
        y = 133,
        w = 1.2,
        h = 1.2,
        show_arrow = true,
      },
      {
        camera_x = 111,
        camera_y = 133,
      },
    },
    sign_desc = {
      { desc = "仓库设置收货选择“碎石”、“铁矿石”、“铝矿石”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "电力铺设" {
    desc = "使得3台组装机通电",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "铁制电线杆"},
    prerequisites = {"收集矿石"},
    count = 3,
    effects = {
      unlock_item = {"地质科技包"},
      unlock_recipe = {"地质科技包1"},
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置电线杆连接风力发电机让3台组装机处于电网范围内", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "生产设置" {
    desc = "组装机配方选择地质科技包1",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "地质科技包1"},
    count = 1,
    prerequisites = {"电力铺设"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "组装机生产设置为“地质科技包1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }