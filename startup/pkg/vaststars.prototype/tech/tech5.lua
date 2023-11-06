local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


  prototype "自动化教学" {
    desc = "自动化教学",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    prerequisites = {},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "自动化教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "拾取物资1" {
    desc = "从废墟中搜索物资",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "pickup_item", building = "机头残骸"},
    prerequisites = {"自动化教学"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 132,
        y = 122,
        w = 3.0,
        h = 3.0,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 131,
        camera_y = 121,
        w = 4.0,
        h = 4.0,
      },
    },
    sign_desc = {
      { desc = "搜索机身残骸获取有用物资", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "修复道路" {
    desc = "修复断开的砖石公路",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 1},
    task_params = {
        path = {
                {{136, 122}, {136, 98}},
              }
    },
    prerequisites = {"拾取物资1"},
    effects = {
      unlock_item = {"碎石","铁矿石","铝矿石"},
    },
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 136.5,
        y = 116.5,
        w = 1.2,
        h = 10,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 136.5,
        y = 103.5,
        w = 1.2,
        h = 8,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 136,
        camera_y = 110,
        w = 2,
        h = 6.4,
      },
    },
    sign_desc = {
      { desc = "修补断开的公路", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "铝矿石发货设置" {
    desc = "铝矿石发货设置",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 8},
    task_params = {items = {"supply|铝矿石"}},
    prerequisites = {"修复道路"},
    count = 1,
    effects = {
      unlock_item = {"地质科技包"},
      unlock_recipe = {"地质科技包1"},
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 127.5,
        y = 98.5,
        w = 4.3,
        h = 2.3,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 127,
        camera_y = 98,
        w = 4.2,
        h = 2.1,
      },
    },
    sign_desc = {
      { desc = "物流站设置发货碎石和铁矿石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "运输车派遣" {
    desc = "派遣4辆运输车",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 2},                          
    prerequisites = {"铝矿石发货设置"},
    count = 4,
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 126.5,
        y = 120.5,
        w = 5.2,
        h = 5.2,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 124,
        camera_y = 120,
        w = 5.2,
        h = 5.2,
      },
    },
    sign_desc = {
      { desc = "指挥中心派遣4辆运输车", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "地质科技包量产" {
    desc = "生产地质科技包",
    type = { "task" },
    task = {"stat_production", 0, "地质科技包"},
    count = 3,
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 125,
        y = 146,
        w = 3,
        h = 3,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 125,
        camera_y = 146,
        w = 5.2,
        h = 5.2,
      },
    },
    prerequisites = {"运输车派遣"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "生产3个地质科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "气候研究" {
    desc = "对火星大气成分进行标本采集和研究",
    type = { "tech" },
    effects = {
      unlock_recipe = {"气候科技包T1"},
      unlock_item = {"气候科技包"},
    },
    prerequisites = {"地质科技包量产"},
    ingredients = {
        {"地质科技包", 1},
    },
    sign_desc = {
      { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture"},
    },
    sign_icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture",
    count = 5,
    time = "5s"
  }
  

  prototype "气候科技包量产" {
    desc = "生产地质科技包",
    type = { "task" },
    task = {"stat_production", 0, "气候科技包"},
    count = 3,
    prerequisites = {"气候研究"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 142,
        y = 119,
        w = 5.2,
        h = 5.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 146,
        camera_y = 118,
        w = 5.2,
        h = 5.2,
      },
    },
    sign_desc = {
      { desc = "生产3个气候科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }
  
  prototype "自动化结束" {
    desc = "教学结束",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {"气候科技包量产"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的自动化结束教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }