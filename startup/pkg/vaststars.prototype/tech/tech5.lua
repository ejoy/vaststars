local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


  prototype "自动化教学" {
    desc = "自动化教学",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
      unlock_item = {"管道1-X型","碎石","石砖"},
    },
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

  -- prototype "修复道路" {
  --   desc = "修复断开的砖石公路",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = {"task" },
  --   task = {"unknown", 0, 1},
  --   task_params = {
  --       path = {
  --               {{136, 122}, {136, 98}},
  --             }
  --   },
  --   prerequisites = {"拾取物资1"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   guide_focus = {
  --     {
  --       prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --       x = 136.5,
  --       y = 116.5,
  --       w = 1.2,
  --       h = 10,
  --       color = {0.3, 1, 0, 1},
  --       show_arrow = true,
  --     },
  --     {
  --       prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --       x = 136.5,
  --       y = 103.5,
  --       w = 1.2,
  --       h = 8,
  --       color = {0.3, 1, 0, 1},
  --       show_arrow = true,
  --     },
  --     {
  --       camera_x = 136,
  --       camera_y = 110,
  --       w = 2,
  --       h = 6.4,
  --     },
  --   },
  --   sign_desc = {
  --     { desc = "修补断开的公路", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "运输车派遣" {
    desc = "派遣5辆运输车",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 2},                          
    prerequisites = {"拾取物资1"},
    count = 1,
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
        camera_y = 118,
        w = 5.2,
        h = 5.2,
      },
    },
    sign_desc = {
      { desc = "指挥中心派遣5辆运输车", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "地质科技包量产" {
    desc = "生产地质科技包",
    type = { "task" },
    task = {"stat_production", 0, "地质科技包"},
    count = 3,
    prerequisites = {"运输车派遣"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "生产3个地质科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "气候科技包量产" {
    desc = "生产地质科技包",
    type = { "task" },
    task = {"stat_production", 0, "气候科技包"},
    count = 3,
    prerequisites = {"地质科技包量产"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
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
    prerequisites = {"运输车派遣"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的自动化结束教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }