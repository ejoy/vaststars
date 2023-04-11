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

  -- task = {"unknown", 0, 5},                          自定义任务，无人机仓库指定选择物品
  -- task_params = {item = "采矿机设计图"},

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
      unlock_recipe = {"采矿机设计图","采矿机打印"},
      unlock_item = {"采矿机设计图"},
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

  prototype "采矿机调度" {
    desc = "选择采矿机设计图",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 3},
    task_params = {recipe = "采矿机打印"},
    count = 1,
    prerequisites = {"迫降火星"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 122,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "建造中心选择采矿机打印", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "继电器废墟传送" {
    desc = "收集废墟物资准备传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_subscribe", building = "继电器废墟"},
    count = 1,
    prerequisites = {"采矿机调度"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 114,
        y = 121,
        w = 1.5,
        h = 1.5,
        show_arrow = true,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 109,
        y = 136,
        w = 2.5,
        h = 2.5,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 134,
        y = 122.5,
        w = 1.5,
        h = 1.5,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 126,
        y = 109,
        w = 1.5,
        h = 1.5,
      },
      {
        camera_x = 119,
        camera_y = 125,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "收集废墟物资准备传送", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "采矿机传送接收" {
    desc = "建造中心接收废墟的物资传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_place", building = "建造中心"},
    count = 1,
    prerequisites = {"继电器废墟传送"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 122,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "建造中心接收废墟的物资传送", icon = "textures/construct/industry.texture"},
    },
  }


  prototype "建造采矿机" {
    desc = "",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_consumption", 0, "采矿机设计图"},
    prerequisites = {"采矿机传送接收"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "使用建造中心建造1个采矿机", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "石矿放置采矿机" {
    desc = "放置1台采矿机",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "采矿机I"},
    prerequisites = {"建造采矿机"},
    effects = {
       unlock_recipe = {"电线杆打印"},
       unlock_item = {"电线杆设计图"},
    },
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 115,
        y = 129,
        w = 3,
        h = 3,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
        show_arrow = true,
      },
      {
        camera_x = 115,
        camera_y = 129,
      },
    },
    sign_desc = {
      { desc = "在石矿上放置1个采矿机", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "电线杆调度" {
    desc = "选择电线杆设计图",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 3},
    task_params = {recipe = "电线杆打印"},
    count = 1,
    prerequisites = {"石矿放置采矿机"},
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 5,
        h = 5,
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 122,
      },
    },
    sign_desc = {
      { desc = "建造中心选择电线杆打印", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "排水口废墟传送" {
    desc = "收集废墟物资准备传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_subscribe", building = "排水口废墟"},
    count = 1,
    prerequisites = {"电线杆调度"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 134,
        y = 122.5,
        w = 1.5,
        h = 1.5,
        show_arrow = true,
      },
      {
        camera_x = 134,
        camera_y = 122.5,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "收集废墟物资准备传送", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "电线杆传送接收" {
    desc = "建造中心接收废墟的物资传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_place", building = "建造中心"},
    count = 1,
    prerequisites = {"排水口废墟传送"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 122,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "建造中心接收废墟的物资传送", icon = "textures/construct/industry.texture"},
    },
  }

prototype "建造电线杆" {
    desc = "建造5个电线杆",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_consumption", 0, "电线杆设计图"},
    prerequisites = {"电线杆传送接收"},
    count = 5,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "在“建造中心”建造4个电线杆", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置电线杆" {
    desc = "放置3个铁制电线杆",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "铁制电线杆"},
    prerequisites = {"建造电线杆"},
    count = 3,
    effects = {
       unlock_recipe = {"无人机仓库打印"},
       unlock_item = {"无人机仓库设计图"},
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_pole1.texture",
      "textures/task_tips_pic/task_place_pole2.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 117,
        y = 115,
        w = 1,
        h = 1,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 117,
        y = 123,
        w = 1,
        h = 1,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 117,
        y = 131,
        w = 1,
        h = 1,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 123,
        y = 115,
        w = 1.5,
        h = 1.5,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
        show_arrow = true,
      },
      {
        camera_x = 118,
        camera_y = 119,
      },
    },
    sign_desc = {
      { desc = "放置4个铁制电线杆构成电网", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "无人机仓库调度" {
    desc = "选择无人机仓库设计图",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 3},
    task_params = {recipe = "无人机仓库打印"},
    count = 1,
    prerequisites = {"放置电线杆"},
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 5,
        h = 5,
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 122,
      },
    },
    sign_desc = {
      { desc = "建造中心选择无人机仓库打印", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "铁箱废墟传送" {
    desc = "收集废墟物资准备传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_subscribe", building = "铁箱废墟"},
    count = 1,
    prerequisites = {"无人机仓库调度"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 126,
        y = 109,
        w = 1.5,
        h = 1.5,
        show_arrow = true,
      },
      {
        camera_x = 126,
        camera_y = 109,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "收集废墟物资准备传送", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "无人机仓库传送接收" {
    desc = "建造中心接收废墟的物资传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_place", building = "建造中心"},
    count = 1,
    prerequisites = {"铁箱废墟传送"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 122,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "建造中心接收废墟的物资传送", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "采矿机传送" {
    desc = "收集废墟物资准备传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_subscribe", building = "采矿机I"},
    count = 1,
    prerequisites = {"无人机仓库传送接收"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 115,
        y = 129,
        w = 3,
        h = 3,
        show_arrow = true,
      },
      {
        camera_x = 115,
        camera_y = 129,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "无人机仓库传送接收", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "碎石传送接收" {
    desc = "建造中心接收废墟的物资传送",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_place", building = "建造中心"},
    count = 1,
    prerequisites = {"采矿机传送"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
        show_arrow = true,
      },
      {
        camera_x = 121,
        camera_y = 122,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "建造中心接收废墟的物资传送", icon = "textures/construct/industry.texture"},
    },
  }

    prototype "建造无人机仓库" {
    desc = "建造1个无人机仓库",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_consumption", 0, "无人机仓库设计图"},
    prerequisites = {"碎石传送接收"},
    count = 1,
    effects = {
      unlock_item = {"碎石"},
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "在“建造中心”建造1个无人机仓库", icon = "textures/construct/industry.texture"},
    },
  }

    prototype "放置无人机仓库" {
    desc = "放置1个无人机仓库",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "无人机仓库"},
    prerequisites = {"建造无人机仓库"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_pole1.texture",
      "textures/task_tips_pic/task_place_pole2.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 123.5,
        y = 126,
        w = 1.5,
        h = 1.5,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 123.5,
        y = 129.5,
        w = 1.5,
        h = 1.5,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 118.5,
        y = 126,
        w = 1.5,
        h = 1.5,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 118.5,
        y = 129.5,
        w = 1.5,
        h = 1.5,
      },
      {
        camera_x = 120,
        camera_y = 128,
      },
    },
    sign_desc = {
      { desc = "放置1个无人机仓库", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "无人机仓库设置" {
    desc = "无人机仓库选择碎石",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
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


  prototype "收集碎石矿" {
    desc = "挖掘足够的碎石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_production", 0, "碎石"},
    prerequisites = {"无人机仓库设置"},
    count = 16,
    effects = {
       unlock_recipe = {"科研中心打印"},
       unlock_item = {"科研中心设计图"},
    },
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "在碎石矿上放置挖矿机并挖掘16个碎石矿", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "无人机仓库传送" {
    desc = "无人机仓库传送设置",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_subscribe", building = "无人机仓库"},
    count = 1,
    prerequisites = {"收集碎石矿"},
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "无人机仓库传送设置", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "更多无人机仓库" {
    desc = "再建造3个无人机仓库",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_consumption", 0, "无人机仓库设计图"},
    prerequisites = {"无人机仓库传送"},
    count = 4,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "建造总共4个无人机仓库", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "建造科研中心" {
    desc = "建造一座科研中心",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_consumption", 0, "科研中心设计图"},
    count = 1,
    prerequisites = {"更多无人机仓库"},
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 114,
        y = 121,
        w = 1.5,
        h = 1.5,
        show_arrow = true,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 122,
        w = 4,
        h = 4,
      },
      {
        camera_x = 119,
        camera_y = 125,
      },
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "继电器废墟里找寻科研中心设计图，再前往建造中心打印一座科研中心", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置科研中心" {
    desc = "放置可以研究火星科技的建筑",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "科研中心I"},
    prerequisites = {"建造科研中心"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_click_build.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 127,
        y = 130,
        w = 3,
        h = 3,
      },
      {
        camera_x = 128,
        camera_y = 131,
      },
    },
    sign_desc = {
      { desc = "使用“建造”放置1座科研中心", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "地质研究" {
    desc = "对火星地质结构进行标本采集和研究",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"地质科技包1","组装机打印"},
      unlock_item = {"组装机设计图"},
    },
    ingredients = {
    },
    count = 10,
    time = "1.2s",
    prerequisites = {"放置科研中心"},
    sign_desc = {
      { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
    },
    sign_icon = "textures/science/tech-important.texture",
}


   prototype "建造组装机" {
    desc = "建造组装机",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_consumption", 0, "组装机设计图"},
    prerequisites = {"地质研究"},
    effects = {
      unlock_item = {"地质科技包"},
    },
    count = 2,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "在“建造中心”建造2台组装机", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置组装机" {
    desc = "放置组装机",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "组装机I"},
    prerequisites = {"建造组装机"},
    count = 3,
    tips_pic = {
      "textures/task_tips_pic/task_click_build.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 126,
        w = 2.5,
        h = 2.5,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 121,
        y = 130,
        w = 2.5,
        h = 2.5,
      },
      {
        camera_x = 119,
        camera_y = 126,
      },
    },
    sign_desc = {
      { desc = "放置3台组装机", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "科技包产线搭建" {
    desc = "选择地质科技包配方",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 3},
    task_params = {recipe = "地质科技包1"},
    count = 1,
    prerequisites = {"放置组装机"},
    tips_pic = {
      "textures/task_tips_pic/task_produce_geopack3.texture",
      "textures/task_tips_pic/task_produce_geopack4.texture",
      "textures/task_tips_pic/task_produce_geopack5.texture",
      "textures/task_tips_pic/task_produce_geopack6.texture",
    },
    sign_desc = {
      { desc = "在组装机里选择地质科技包配方", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "自动化生产" {
    desc = "自动化生产科技包用于科技研究",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_production", 0, "地质科技包"},
    prerequisites = {"科技包产线搭建"},
    count = 8,
    tips_pic = {
      "textures/task_tips_pic/task_produce_geopack3.texture",
      "textures/task_tips_pic/task_produce_geopack4.texture",
      "textures/task_tips_pic/task_produce_geopack5.texture",
      "textures/task_tips_pic/task_produce_geopack6.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产至8个地质科技包", icon = "textures/construct/industry.texture"},
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
    prerequisites = {"自动化生产"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 8,
    time = "1s"
  }

  prototype "石砖产线搭建" {
    desc = "选择地质科技包配方",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 3},
    task_params = {recipe = "石砖"},
    count = 1,
    prerequisites = {"石头处理1"},
    tips_pic = {
      "textures/task_tips_pic/task_produce_geopack3.texture",
      "textures/task_tips_pic/task_produce_geopack4.texture",
      "textures/task_tips_pic/task_produce_geopack5.texture",
      "textures/task_tips_pic/task_produce_geopack6.texture",
    },
    sign_desc = {
      { desc = "在组装机里选择石砖配方", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "生产石砖" {
    desc = "挖掘足够的碎石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_production", 0, "石砖"},
    prerequisites = {"石砖产线搭建"},
    count = 10,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产10个石砖", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "道路研究" {
    desc = "掌握使用石砖制造道路的技术",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"修路站设计","修路站打印","砖石公路打印"},
      unlock_item = {"修路站设计图"},
    },
    prerequisites = {"生产石砖"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 12,
    time = "1.5s"
  }

  prototype "道路设计" {
    desc = "制造1张修路站设计图",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_production", 0, "修路站设计图"},
    prerequisites = {"道路研究"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "组装机生产1张修路站设计图", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "建造道路站" {
    desc = "建造组装机",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_consumption", 0, "修路站设计图"},
    prerequisites = {"道路设计"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "在“建造中心”建造1个修路站", icon = "textures/construct/industry.texture"},
    },
  }

    prototype "放置修路站" {
    desc = "放置1座修路站",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "修路站"},
    prerequisites = {"建造道路站"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置1个修路站", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "通向铁矿" {
    desc = "修建35节公路",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"unknown", 0, 1},
    task_params = {},
    prerequisites = {"放置修路站"},
    count = 35,
    tips_pic = {
      "textures/task_tips_pic/task_place_road1.texture",
      "textures/task_tips_pic/task_place_road2.texture",
      "textures/task_tips_pic/task_place_road3.texture",
    },
    guide_focus = {
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 126,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 127,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 128,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 129,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 130,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 131,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 132,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 133,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 134,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 135,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 136,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 137,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 138,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 139,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 140,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 141,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 142,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 143,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 144,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 145,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 146,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 147,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 148,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 149,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 150,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 151,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 152,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 153,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 154,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 155,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 156,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 157,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 158,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 159,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 160,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 161,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 162,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 163,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        prefab = "prefabs/selected-box-guide.prefab",
        x = 164,
        y = 125,
        w = 0.25,
        h = 0.25,
      },
      {
        camera_x = 125,
        camera_y = 122,
      },
    },
    sign_desc = {
      { desc = "修建道路从指挥中心到东边的铁矿", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "物流学I" {
    desc = "研究送货车站和收货车站建造工艺",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"送货车站打印","收货车站打印"},
      unlock_item = {"送货车站设计图","收货车站设计图","铁矿石"},
    },
    prerequisites = {"通向铁矿"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 10,
    time = "1s"
  }

  prototype "放置送货车站" {
    desc = "放置1座修路站",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "送货车站"},
    prerequisites = {"物流学I"},
    count = 1,
    effects = {
      unlock_recipe = {"车辆装配"},
      unlock_item = {"运输车框架"},
    },
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置1个送货车站", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "放置收货车站" {
    desc = "放置1座修路站",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "收货车站"},
    prerequisites = {"物流学I"},
    count = 1,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "放置1个收货车站", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "生产运输车辆" {
    desc = "挖掘足够的铁矿石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_production", 0, "运输车辆I"},
    prerequisites = {"放置送货车站","放置收货车站"},
    count = 4,
    tips_pic = {
      "textures/task_tips_pic/task_produce_ore3.texture",
    },
    sign_desc = {
      { desc = "组装机维修4辆运输车辆", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "铁矿放置采矿机" {
    desc = "放置1台采矿机",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "采矿机I"},
    prerequisites = {"生产运输车辆"},
    count = 2,
    tips_pic = {
      "textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "在铁矿上放置1台采矿机", icon = "textures/construct/industry.texture"},
    },
  }

  prototype "生产铁矿石" {
    desc = "挖掘足够的铁矿石可以开始进行锻造",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_production", 0, "铁矿石"},
    prerequisites = {"铁矿放置采矿机"},
    count = 10,
    effects = {
      unlock_recipe = {"熔炼炉打印"},
      unlock_item = {"熔炼炉设计图"},
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
    type = { "tech", "task" },
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
    type = { "tech", "task" },
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
    type = { "tech", "task" },
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

  prototype "机械运输" {
    desc = "研究生产运输车辆工艺",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"运输汽车制造"},
    },
    prerequisites = {"生产铁齿轮"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 16,
    time = "5s"
  }

  prototype "电磁学1" {
    desc = "研究电能转换成机械能的基础供能装置",
    type = { "tech" },
    icon = "textures/science/tech-research.texture",
    effects = {
      unlock_recipe = {"电动机1"},
      unlock_item = {"电动机I"},
    },
    prerequisites = {"机械运输"},
    ingredients = {
      {"地质科技包", 1},
    },
    count = 20,
    time = "6s"
  }

  prototype "量产运输车辆" {
    desc = "生产8辆运输车",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"stat_production", 0, "运输车辆I"},
    prerequisites = {"电磁学1"},
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

prototype "物流学II" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"送货车站设计","收货车站设计"},
  },
  prerequisites = {"量产运输车辆"},
  ingredients = {
    {"地质科技包", 1},
  },
  count = 20,
  time = "6s"
}

prototype "气候研究" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"气候科技包1","空气过滤器打印","地下水挖掘机打印"},
    unlock_item = {"气候科技包","空气过滤器设计图","地下水挖掘机设计图"},
  },
  prerequisites = {"物流学II"},
  ingredients = {
      {"地质科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
  },
  sign_icon = "textures/science/tech-important.texture",
  count = 12,
  time = "1.5s"
}

prototype "管道系统1" {
  desc = "研究装载和运输液体或气体的管道",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"修管站设计","管道1","管道2","液罐1"},
    unlock_item = {"液罐I","修管站设计图","管道1-X型"},
  },
  prerequisites = {"气候研究"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 12,
  time = "1s"
}

prototype "生产管道" {
  desc = "管道用于液体传输",
  icon = "textures/construct/industry.texture",
  type = { "tech", "task" },
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

prototype "排放" {
  desc = "研究气体和液体的排放工艺",
  type = { "tech" },
  icon = "textures/science/tech-research.texture",
  effects = {
    unlock_recipe = {"烟囱1","排水口1"},
    unlock_item = {"烟囱I","排水口I"},
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
    unlock_recipe = {"地下水挖掘机","水电站打印"},
    unlock_item = {"水电站设计图"},
  },
  prerequisites = {"排放"},
  ingredients = {
      {"地质科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
  },
  sign_icon = "textures/science/tech-important.texture",
  count = 12,
  time = "1.5s"
}

prototype "建造地下水挖掘机" {
  desc = "生产科技包用于科技研究",
  icon = "textures/construct/industry.texture",
  type = { "tech", "task" },
  task = {"stat_production", 0, "地下水挖掘机"},
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
  type = { "tech", "task" },
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
  type = { "tech", "task" },
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

  -- prototype "放置太阳能板" {
  --   desc = "放置4座太阳能板",
  --   icon = "textures/construct/industry.texture",
  --   type = { "tech", "task" },
  --   task = {"select_entity", 0, "太阳能板I"},
  --   prerequisites = {"地质研究"},
  --   count = 4,
  --   tips_pic = {
  --     "textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "放置4个太阳能板", icon = "textures/construct/industry.texture"},
  --   },
  -- }

-- prototype "放置车辆厂" {
--   desc = "放置1座车辆厂",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"select_entity", 0, "车辆厂I"},
--   prerequisites = {"放置太阳能板"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_place_logistics.texture",
--   },
--   sign_desc = {
--     { desc = "放置1个车辆厂", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产运输车辆" {
--   desc = "生产运输车辆2辆",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, 运输车辆设计图},
--   prerequisites = {"放置车辆厂"},
--   task_params = {},
--   count = 2,
--   tips_pic = {
--     "textures/task_tips_pic/task_click_build.texture",
--     "textures/task_tips_pic/task_demolish2.texture",
--     "textures/task_tips_pic/task_demolish3.texture",
--   },
--   sign_desc = {
--     { desc = "在车辆厂生产2辆运输车辆", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "增添运输车辆" {
--   desc = "增加运输车辆至5辆",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"unknown", 0, 2},
--   prerequisites = {"地质研究"},
--   task_params = {},
--   count = 5,
--   tips_pic = {
--     "textures/task_tips_pic/task_click_build.texture",
--     "textures/task_tips_pic/task_demolish2.texture",
--     "textures/task_tips_pic/task_demolish3.texture",
--   },
--   sign_desc = {
--     { desc = "在物流中心需求运输车辆至5辆", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "维修运输汽车" {
--   desc = "维修运输车参与物流",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, "破损运输车辆"},
--   prerequisites = {"基地生产1"},
--   count = 2,
--   tips_pic = {
--     "textures/task_tips_pic/task_repair_truck.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修2辆破损运输车辆", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "维修物流中心" {
--   desc = "维修运输车参与物流",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, "破损物流中心"},
--   prerequisites = {"基地生产1"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_repair_logistics.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修1个破损物流中心", icon = "textures/construct/industry.texture"},
--   },
-- }


-- prototype "铁矿熔炼" {
--   desc = "掌握熔炼铁矿石冶炼成铁板的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"铁板1"},
--   },
--   prerequisites = {"基地生产1"},
--   ingredients = {
--       {"地质科技包", 1},
--   },
--   count = 8,
--   time = "3s"
-- }

-- prototype "放置熔炼炉" {
--   desc = "放置熔炼炉",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"select_entity", 0, "熔炼炉I"},
--   prerequisites = {"铁矿熔炼"},
--   count = 2,
--   tips_pic = {
--     "textures/task_tips_pic/task_click_build.texture",
--     "textures/task_tips_pic/task_produce_geopack1.texture",
--     "textures/task_tips_pic/task_produce_geopack2.texture",
--     "textures/task_tips_pic/start_construct.texture",
--   },
--   sign_desc = {
--     { desc = "使用“建造”放置2台熔炼炉", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产铁板" {
--   desc = "铁板可以打造坚固器材，对于基地建设多多益善",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "铁板"},
--   prerequisites = {"放置熔炼炉"},
--   count = 4,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_ironplate1.texture",
--     "textures/task_tips_pic/task_produce_ironplate2.texture",
--     "textures/task_tips_pic/task_produce_ironplate3.texture",
--     "textures/task_tips_pic/task_produce_ironplate4.texture",
--     "textures/task_tips_pic/task_produce_ironplate5.texture",
--   },
--   sign_desc = {
--     { desc = "使用熔炼炉生产4个铁板", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "石头处理1" {
--   desc = "获得火星岩石加工成石砖的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"石砖"},
--   },
--   prerequisites = {"生产铁板"},
--   ingredients = {
--       {"地质科技包", 1},
--   },
--   count = 8,
--   time = "1s"
-- }

-- prototype "生产石砖" {
--   desc = "石砖可以打造基础建筑，对于基地建设多多益善",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "石砖"},
--   prerequisites = {"石头处理1"},
--   count = 4,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_stonebrick.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机生产4个石砖", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "气候研究" {
--   desc = "对火星大气成分进行标本采集和研究",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"气候科技包1"},
--     unlock_building = {"空气过滤器I","地下水挖掘机"},
--   },
--   prerequisites = {"生产石砖"},
--   ingredients = {
--       {"地质科技包", 1},
--   },
--   sign_desc = {
--     { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
--   },
--   sign_icon = "textures/science/tech-important.texture",
--   count = 12,
--   time = "1.5s"
-- }

-- prototype "维修破损空气过滤器" {
--   desc = "将破损的机器修复会大大节省建设时间和资源",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, "空气过滤器设计图"},
--   prerequisites = {"气候研究"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_repair_airfilter.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修1个破损空气过滤器", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "维修破损地下水挖掘机" {
--   desc = "将破损的机器修复会大大节省建设时间和资源",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, "地下水挖掘机设计图"},
--   prerequisites = {"气候研究"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_repair_digger.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修1个破损地下水挖掘机", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "修建水电站" {
--   desc = "修建水电站收集气体和液体",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"select_entity", 0, "水电站I"},
--   prerequisites = {"维修破损空气过滤器","维修破损地下水挖掘机"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_click_build.texture",
--     "textures/task_tips_pic/task_place_hydro.texture",
--   },
--   sign_desc = {
--     { desc = "修建1座水电站", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产气候科技包" {
--   desc = "生产科技包用于科技研究",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "气候科技包"},
--   prerequisites = {"修建水电站"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_climatepack2.texture",
--     "textures/task_tips_pic/task_produce_climatepack3.texture",
--     "textures/task_tips_pic/task_produce_climatepack4.texture",
--     "textures/task_tips_pic/task_produce_climatepack5.texture",
--   },
--   sign_desc = {
--     { desc = "使用水电站生产1个气候科技包", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "管道系统1" {
--   desc = "研究装载和运输液体或气体的管道",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"管道1","管道2","液罐1"},
--     unlock_building = {"液罐I","管道1-X型"},
--   },
--   prerequisites = {"生产气候科技包"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"气候科技包", 1},
--   },
--   count = 4,
--   time = "1s"
-- }

-- prototype "生产管道" {
--   desc = "管道可以承载液体和气体，将需要相同气液的机器彼此联通起来",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "管道1-X型"},
--   prerequisites = {"管道系统1"},
--   count = 10,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_pipe1.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机生产10个管道", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "水利研究" {
--   desc = "对火星地层下的水源进行开采",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"水电站设计"},
--     unlock_building = {"水电站I"},
--   },
--   prerequisites = {"生产管道"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"气候科技包", 1},
--   },
--   count = 8,
--   time = "1s"
-- }


-- prototype "电解" {
--   desc = "科技的描述",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"地下卤水电解","隔膜电解","电解厂设计"},
--     unlock_building = {"电解厂I"},
--   },
--   prerequisites = {"水利研究"},
--   ingredients = {
--       {"气候科技包", 1},
--   },
--   count = 10,
--   time = "2s"
-- }

-- prototype "空气分离" {
--   desc = "获得火星大气分离出纯净气体的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"空气分离1"},
--   },
--   prerequisites = {"维修破损组装机","电解"},
--   ingredients = {
--       {"气候科技包", 1},
--   },
--   count = 8,
--   time = "1.5s"
-- }

-- prototype "收集空气" {
--   desc = "采集火星上的空气",
--   type = { "tech", "task" },
--   icon = "textures/construct/industry.texture",
--   task = {"stat_production", 1, "空气"},
--   prerequisites = {"空气分离"},
--   count = 4000,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_air1.texture",
--     "textures/task_tips_pic/task_produce_air2.texture",
--   },
--   sign_desc = {
--     { desc = "用空气过滤器生产40000单位空气", icon = "textures/construct/industry.texture",},
--   },
-- }

-- prototype "铁加工1" {
--   desc = "获得铁板加工铁齿轮的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"铁齿轮","维修组装机"},
--     unlock_building = {"组装机I"},
--   },
--   prerequisites = {"生产管道"},
--   ingredients = {
--       {"地质科技包", 1},
--   },
--   count = 12,
--   time = "2s"
-- }

-- prototype "维修破损组装机" {
--   desc = "将破损的机器修复会大大节省建设时间和资源",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, "组装机设计图"},
--   prerequisites = {"铁加工1"},
--   count = 3,
--   tips_pic = {
--     "textures/task_tips_pic/task_repair_assembler.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修3个破损组装机", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "石头处理2" {
--   desc = "对火星岩石成分的研究",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"维修太阳能板","维修蓄电池"},
--     unlock_building = {"太阳能板I","蓄电池I"},
--   },
--   prerequisites = {"空气分离"},
--   ingredients = {
--       {"地质科技包", 1},
--   },
--   count = 16,
--   time = "2s"
-- }

-- prototype "修理太阳能板" {
--   desc = "维修太阳能板并利用太阳能板技术发电",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, "太阳能板设计图"},
--   prerequisites = {"石头处理2"},
--   count = 2,
--   tips_pic = {
--     "textures/task_tips_pic/task_repair_solarpanel.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修2个破损太阳能板", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "放置太阳能板" {
--   desc = "放置太阳能板将光热转换成电能",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"select_entity", 0, "太阳能板I"},
--   prerequisites = {"修理太阳能板"},
--   count = 8,
--   tips_pic = {
--     "textures/task_tips_pic/task_place_solarpanel.texture",
--   },
--   sign_desc = {
--     { desc = "放置8个太阳能板", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "基地生产2" {
--   desc = "提高指挥中心的生产效率",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     modifier = {["headquarter-mining-speed"] = 0.1},
--     unlock_recipe = {"维修铁制电线杆","建造中心"},
--     unlock_building = {"铁制电线杆"},
--   },
--   prerequisites = {"空气分离"},
--   ingredients = {
--       {"地质科技包", 1},
--   },
--   count = 16,
--   time = "1s",
--   sign_desc = {
--     { desc = "该科技可以持续地提高某项能力", icon = "textures/science/recycle.texture"},
--   },
--   sign_icon = "textures/science/tech-cycle.texture",
-- }

-- prototype "储存1" {
--   desc = "研究更便捷的存储方式",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"小铁制箱子1"},
--     unlock_building = {"小铁制箱子I"},
--   },
--   prerequisites = {"维修破损组装机","基地生产2"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"气候科技包", 1},
--   },
--   count = 12,
--   time = "2s"
-- }

-- prototype "生产铁制箱子" {
--   desc = "生产小铁制箱子用于存储基地的资源",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "小铁制箱子I"},
--   prerequisites = {"储存1"},
--   count = 3,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_chest.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机生产3个小铁制箱子", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "碳处理1" {
--   desc = "含碳气体化合成其他物质的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"二氧化碳转甲烷","化工厂打印"},
--     unlock_building = {"化工厂I"},
--   },
--   prerequisites = {"电解","空气分离","放置太阳能板"},
--   ingredients = {
--       {"气候科技包", 1},
--   },
--   count = 8,
--   time = "2s"
-- }

-- prototype "生产氢气" {
--   desc = "生产工业气体氢气",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "氢气"},
--   prerequisites = {"碳处理1"},
--   count = 500,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_h21.texture",
--     "textures/task_tips_pic/task_produce_h22.texture",
--   },
--   sign_desc = {
--     { desc = "电解厂电解卤水生产500个单位氢气", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产二氧化碳" {
--   desc = "生产工业气体二氧化碳",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "二氧化碳"},
--   prerequisites = {"碳处理1"},
--   count = 500,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_co21.texture",
--     "textures/task_tips_pic/task_produce_co22.texture",
--   },
--   sign_desc = {
--     { desc = "蒸馏厂分离空气生产500个单位二氧化碳", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "碳处理2" {
--   desc = "含碳气体化合成其他物质的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"甲烷转乙烯","二氧化碳转一氧化碳","一氧化碳转石墨"},
--   },
--   prerequisites = {"生产氢气","生产二氧化碳"},
--   ingredients = {
--       {"气候科技包", 1},
--   },
--   count = 16,
--   time = "2s"
-- }

-- prototype "地质研究2" {
--   desc = "对火星地质结构进行标本采集和研究",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"地质科技包2"},
--   },
--   ingredients = {
--       {"地质科技包", 1},
--   },
--   count = 10,
--   time = "1.2s",
--   prerequisites = {"碳处理2"},
--   sign_desc = {
--     { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
--   },
--   sign_icon = "textures/science/tech-important.texture",
-- }

-- prototype "管道系统2" {
--   desc = "研究装载和运输液体或气体的管道",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"地下管1"},
--     unlock_building = {"地下管1-JI型"},
--   },
--   prerequisites = {"收集空气","放置太阳能板"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"气候科技包", 1},
--   },
--   count = 10,
--   time = "2s"
-- }

-- prototype "排放" {
--   desc = "研究气体和液体的排放工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"烟囱1","排水口1"},
--     unlock_building = {"烟囱I","排水口I"},
--   },
--   prerequisites = {"管道系统2"},
--   ingredients = {
--     {"气候科技包", 1},
--   },
--   count = 16,
--   time = "2s"
-- }

-- prototype "冶金学1" {
--   desc = "研究工业高温熔炼的装置",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"熔炼炉1"},
--     unlock_building = {"熔炼炉I"},
--   },
--   prerequisites = {"放置太阳能板","生产铁制箱子"},
--   ingredients = {
--     {"地质科技包", 1},
--   },
--   count = 10,
--   time = "4s"
-- }

-- prototype "维修化工厂" {
--   desc = "维修化工厂生成化工原料",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_consumption", 0, "化工厂设计图"},
--   prerequisites = {"碳处理2"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_repair_chemicalplant1.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修1个破损化工厂", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "放置化工厂" {
--   desc = "放置化工厂生产化工产品",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"select_entity", 0, "化工厂I"},
--   prerequisites = {"维修化工厂"},
--   count = 1,
--   tips_pic = {
--     "textures/task_tips_pic/task_click_build.texture",
--     "textures/task_tips_pic/task_place_chemicalplant.texture",
--   },
--   sign_desc = {
--     { desc = "放置1座化工厂", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产甲烷" {
--   desc = "生产工业气体甲烷",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "甲烷"},
--   prerequisites = {"放置化工厂"},
--   count = 1000,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_ch4.texture",
--   },
--   sign_desc = {
--     { desc = "用化工厂生产1000个单位甲烷", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "有机化学" {
--   desc = "研究碳化合物组成、结构和制备方法",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"塑料1"},
--   },
--   prerequisites = {"生产甲烷"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--   },
--   count = 12,
--   time = "10s"
-- }

-- prototype "生产乙烯" {
--   desc = "生产工业气体乙烯",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "乙烯"},
--   prerequisites = {"有机化学"},
--   count = 1000,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_ch4.texture",
--   },
--   sign_desc = {
--     { desc = "用化工厂生产1000个单位乙烯", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产塑料" {
--   desc = "使用有机化学的科学成果生产质量轻、耐腐蚀的工业材料塑料",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "塑料"},
--   prerequisites = {"生产乙烯"},
--   count = 30,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_plastic.texture",
--   },
--   sign_desc = {
--     { desc = "用化工厂生产30个塑料", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "电磁学1" {
--   desc = "研究电能转换成机械能的基础供能装置",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"电动机1"},
--   },
--   prerequisites = {"生产塑料","排放"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--   },
--   count = 20,
--   time = "6s"
-- }

-- --研究机械科技瓶
-- prototype "机械研究" {
--   desc = "对适合在火星表面作业的机械装置进行改进和开发",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"机械科技包1"},
--   },
--   prerequisites = {"电磁学1"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--   },
--   count = 12,
--   time = "2s",
--   sign_desc = {
--     { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
--   },
--   sign_icon = "textures/science/tech-important.texture",
-- }

-- prototype "生产机械科技包" {
--   desc = "生产科技包用于科技研究",
--   icon = "textures/construct/industry.texture",
--   type = { "tech", "task" },
--   task = {"stat_production", 0, "机械科技包"},
--   prerequisites = {"机械研究"},
--   count = 3,
--   tips_pic = {
--     "textures/task_tips_pic/task_produce_plastic.texture",
--   },
--   sign_desc = {
--     { desc = "用组装机生产3个机械科技包", icon = "textures/construct/industry.texture"},
--   },
-- }

-- prototype "挖掘1" {
--   desc = "研究对火星岩石的开采技术",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"采矿机1"},
--     unlock_building = {"采矿机I"},
--   },
--   prerequisites = {"生产机械科技包"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--   },
--   count = 8,
--   time = "7s"
-- }

-- -- prototype "驱动1" {
-- --   desc = "使用机械手臂快速转移物品",
-- --   type = { "tech" },
-- --   icon = "textures/science/tech-research.texture",
-- --   effects = {
-- --     unlock_recipe = {"机器爪1"},
-- --   },
-- --   prerequisites = {"生产机械科技包"},
-- --   ingredients = {
-- --     {"机械科技包", 1},
-- --   },
-- --   count = 6,
-- --   time = "8s"
-- -- }

-- prototype "蒸馏1" {
--   desc = "将液体混合物汽化进行成分分离的技术",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"蒸馏厂1"},
--     unlock_building = {"蒸馏厂I"},
--   },
--   prerequisites = {"挖掘1"},
--   ingredients = {
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 8,
--   time = "7s"
-- }

-- prototype "电力传输1" {
--   desc = "将电能远距离传输的技术",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"铁制电线杆"},
--     unlock_building = {"铁制电线杆"},
--   },
--   prerequisites = {"生产机械科技包"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 4,
--   time = "12s"
-- }

-- prototype "泵系统1" {
--   desc = "使用机械方式加快液体流动",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"压力泵1"},
--     unlock_building = {"压力泵I"},
--   },
--   prerequisites = {"电力传输1"},
--   ingredients = {
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 8,
--   time = "6s"
-- }

-- prototype "自动化1" {
--   desc = "使用3D打印技术快速复制物品",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"组装机1"},
--     unlock_building = {"组装机I"},
--   },
--   prerequisites = {"挖掘1","电力传输1"},
--   ingredients = {
--     {"机械科技包", 1},
--   },
--   count = 8,
--   time = "9s"
-- }

-- prototype "地下水净化" {
--   desc = "火星地下开采卤水进行过滤净化工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"地下卤水净化","地下水挖掘机","水电站1"},
--     unlock_building = {"地下水挖掘机","水电站I"},
--   },
--   prerequisites = {"蒸馏1"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 8,
--   time = "10s"
-- }

-- prototype "炼钢" {
--   desc = "将铁再锻造成更坚硬金属的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"钢板1"},
--   },
--   prerequisites = {"挖掘1"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 10,
--   time = "9s"
-- }

-- prototype "发电机1" {
--   desc = "使用蒸汽作为工质将热能转为机械能的发电装置",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"蒸汽发电机1"},
--     unlock_building = {"蒸汽发电机I"},
--   },
--   prerequisites = {"电力传输1"},
--   ingredients = {
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 8,
--   time = "15s"
-- }

-- prototype "物流1" {
--   desc = "使用交通工具进行远程运输",
--   type = { "tech" },
--   icon = "textures/science/tech-logistics.texture",
--   effects = {
--     unlock_recipe ={"物流中心1","运输车辆1"},
--     unlock_building = {"物流中心I"},
--   },
--   prerequisites = {"发电机1"},
--   ingredients = {
--     {"机械科技包", 1},
--   },
--   count = 10,
--   time = "10s"
-- }

-- prototype "空气过滤技术" {
--   desc = "研究将火星混合气体分离的装置",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"空气过滤器1"},
--     unlock_building = {"空气过滤器I"},
--   },
--   prerequisites = {"泵系统1","发电机1"},
--   ingredients = {
--     {"气候科技包", 1},
--   },
--   count = 10,
--   time = "10s"
-- }

-- prototype "矿物处理1" {
--   desc = "将矿物进行碾碎并收集的机械工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"粉碎机1","沙子1"},
--     unlock_building = {"粉碎机I"},
--   },
--   prerequisites = {"挖掘1","自动化1"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 10,
--   time = "10s"
-- }

-- prototype "钢加工" {
--   desc = "钢制产品更多的铸造技术",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"钢齿轮"},
--   },
--   prerequisites = {"炼钢"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 16,
--   time = "8s"
-- }

-- prototype "浮选" {
--   desc = "使用浮选对矿石实行筛选",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"浮选器1"},
--     unlock_building = {"浮选器I"},
--   },
--   prerequisites = {"矿物处理1","地下水净化"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 16,
--   time = "8s"
-- }

-- prototype "硅处理" {
--   desc = "从沙子中提炼硅的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"硅1","玻璃"},
--   },
--   prerequisites = {"浮选"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 16,
--   time = "8s"
-- }

-- prototype "铁矿熔炼2" {
--   desc = "熔炼铁矿石冶炼成铁板的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"铁板2"},
--   },
--   prerequisites = {"钢加工","空气过滤技术"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 12,
--   time = "8s"
-- }

-- prototype "能量存储" {
--   desc = "更多的有机化学制取工业气体工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"电解厂1"},
--     unlock_building = {"电解厂I"},
--   },
--   prerequisites = {"空气过滤技术"},
--   ingredients = {
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 8,
--   time = "12s"
-- }

-- prototype "有机化学2" {
--   desc = "更多的有机化学制取工业气体工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"乙烯转丁二烯","纯水转蒸汽"},
--   },
--   prerequisites = {"硅处理","能量存储"},
--   ingredients = {
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 16,
--   time = "8s"
-- }

-- prototype "化学工程" {
--   desc = "使用大型设施生产化工产品",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"化工厂1","纯水电解"},
--     unlock_building = {"化工厂I"},
--   },
--   prerequisites = {"有机化学2"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 10,
--   time = "10s"
-- }

-- prototype "管道系统3" {
--   desc = "研究装载和运输液体或气体的管道",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"地下管2"},
--     unlock_building = {"地下管2-JI型"},
--   },
--   prerequisites = {"空气过滤技术","浮选"},
--   ingredients = {
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 12,
--   time = "10s"
-- }

-- prototype "无机化学" {
--   desc = "使用无机化合物合成物质的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"酸碱中和","碱性溶液","盐酸"},
--   },
--   prerequisites = {"化学工程","管道系统3"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 20,
--   time = "5s"
-- }

-- prototype "废料回收1" {
--   desc = "回收工业废料",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"铁矿石回收","碎石回收","沙子回收","废料中和"},
--   },
--   prerequisites = {"无机化学"},
--   ingredients = {
--       {"地质科技包", 1},
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 24,
--   time = "6s"
-- }

-- prototype "石头处理3" {
--   desc = "获得将硅加工成坩埚的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"坩埚"},
--   },
--   prerequisites = {"硅处理"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 24,
--   time = "8s"
-- }

-- prototype "有机化学3" {
--   desc = "更多的有机化学制取工业气体工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"橡胶"},
--   },
--   prerequisites = {"化学工程"},
--   ingredients = {
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 24,
--   time = "8s"
-- }

-- prototype "储存2" {
--   desc = "研究更便捷的存储方式",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"大铁制箱子1","小铁制箱子2"},
--     unlock_building = {"大铁制箱子I","小铁制箱子II"},
--   },
--   prerequisites = {"有机化学3","炼钢"},
--   ingredients = {
--       {"气候科技包", 1},
--       {"机械科技包", 1},
--   },
--   count = 30,
--   time = "8s"
-- }

-- prototype "冶金学2" {
--   desc = "研究工业高温熔炼的装置",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"熔炼炉2"},
--     unlock_building = {"熔炼炉II"},
--   },
--   prerequisites = {"石头处理3","铁矿熔炼2"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 40,
--   time = "6s"
-- }

-- prototype "铝生产" {
--   desc = "加工铝矿的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"碾碎铝矿石","铝矿石浮选","氧化铝","铝板1"},
--   },
--   prerequisites = {"无机化学"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 40,
--   time = "6s"
-- }

-- prototype "硅生产" {
--   desc = "将硅加工硅板的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"硅板1"},
--   },
--   prerequisites = {"无机化学","冶金学2"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 60,
--   time = "6s"
-- }

-- prototype "润滑" {
--   desc = "研究工业润滑油制作工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"润滑油"},
--   },
--   prerequisites = {"硅生产"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 60,
--   time = "5s"
-- }

-- prototype "铝加工" {
--   desc = "使用铝加工其他零器件的工艺",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"铝丝1","铝棒1"},
--   },
--   prerequisites = {"铝生产","冶金学2"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 50,
--   time = "8s"
-- }

-- prototype "沸腾实验" {
--   desc = "生产精密的电子元器件",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"换热器1","热管1","纯水沸腾","卤水沸腾"},
--     unlock_building = {"换热器I","热管1-X型"},
--   },
--   prerequisites = {"铝生产"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 30,
--   time = "5s"
-- }

-- prototype "电子器件" {
--   desc = "生产精密的电子元器件",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"电容1","绝缘线1","逻辑电路1"},
--   },
--   prerequisites = {"铝加工","硅生产"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 80,
--   time = "5s"
-- }

-- prototype "批量生产1" {
--   desc = "研究大规模生产的技术",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"组装机2","采矿机2"},
--   },
--   prerequisites = {"废料回收1"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   count = 60,
--   time = "6s"
-- }

-- prototype "电子研究" {
--   desc = "对电子设备进行深度研究",
--   type = { "tech" },
--   icon = "textures/science/tech-research.texture",
--   effects = {
--     unlock_recipe = {"电子科技包1"},
--   },
--   prerequisites = {"批量生产1","电子器件"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--   },
--   sign_desc = {
--     { desc = "该科技是火星探索的前沿科技，它可以引导更多的科技研究", icon = "textures/science/important.texture"},
--   },
--   sign_icon = "textures/science/tech-important.texture",
--   count = 100,
--   time = "5s"
-- }