local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


  prototype "流体教学" {
    desc = "流体教学",
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
      { desc = "流体教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "管道接收" {
    desc = "仓库选择碎石",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 9},                 
    task_params = {building = "仓库I", item = "管道1-X型", },
    count = 10,
    prerequisites = {"流体教学"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 124,
        y = 134,
        w = 1.2,
        h = 1.2,
        show_arrow = true,
      },
      {
        camera_x = 124,
        camera_y = 134,
      },
    },
    sign_desc = {
      { desc = "仓库设置收货选择“管道1-X型”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "连接液罐" {
    desc = "连接液罐",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 9},    
    task_params = {building = "仓库I", item = "管道1-X型", },
    count = 1,
    effects = {
      unlock_item = {"地下管1-JI型"},
      unlock_recipe = {"地下管1"},
    },
    prerequisites = {"管道接收"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 118,
        y = 142,
        w = 1.0,
        h = 1.0,
        show_arrow = false,
      },      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 119,
        y = 142,
        w = 1.0,
        h = 1.0,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 120,
        y = 142,
        w = 1.0,
        h = 1.0,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 121,
        y = 142,
        w = 1.0,
        h = 1.0,
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 122,
        y = 142,
        w = 1.0,
        h = 1.0,
        show_arrow = false,
      },
      {
        camera_x = 120,
        camera_y = 142,
      },
    },
    sign_desc = {
      { desc = "地下水挖掘机连接液罐", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }


  prototype "地下管生产设置" {
    desc = "组装机配方选择地下管",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "地下管1"},
    count = 1,
    prerequisites = {"连接液罐"},
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 124,
        y = 136,
        w = 3.0,
        h = 3.0,
        show_arrow = true,
      },
      {
        camera_x = 124,
        camera_y = 136,
      },
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "组装机生产设置为“地下管1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "生产地下管" {
    desc = "生产地下管",
    type = { "task" },
    icon = "/pkg/vaststars.resources/ui/textures/science/book.texture",
    task = {"stat_production", 0, "地下管1-JI型"},
    count = 2,
    prerequisites = {"地下管生产设置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "使用组装机生产2个地下管", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "完成流体研究" {
    desc = "完成新的科技研究",
    type = { "tech" },
    icon = "/pkg/vaststars.resources/ui/textures/science/book.texture",
    prerequisites = {"生产地下管"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 8,
    time = "1s"
  }

  prototype "流体教学结束" {
    desc = "教学结束",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {"完成科技研究"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的物流教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }