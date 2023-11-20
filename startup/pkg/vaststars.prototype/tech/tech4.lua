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
    task = {"unknown", 0, 6},
    task_params = {ui = "pickup_item", building = "仓库I"},
    count = 30,
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
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 124,
        camera_y = 134,
        w = 1.2,
        h = 1.2,
      },
    },
    sign_desc = {
      { desc = "仓库里获取30个“管道”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "连接液罐" {
    desc = "连接液罐",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "液罐I", fluids = {"地下卤水"}},
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
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 119,
        y = 142,
        w = 1.0,
        h = 1.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 120,
        y = 142,
        w = 1.0,
        h = 1.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 121,
        y = 142,
        w = 1.0,
        h = 1.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 122,
        y = 142,
        w = 1.0,
        h = 1.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 120,
        camera_y = 142,
        w = 1.0,
        h = 1.0,
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
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 124,
        camera_y = 136,
        w = 3.0,
        h = 3.0,
      },
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "组装机生产设置为“地下管1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "获取地下管" {
    desc = "获取打造的地下管",
    type = { "task" },
    task = {"stat_production", 0, "地下管1-JI型"},                
    count = 2,
    prerequisites = {"地下管生产设置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "从组装机里获取已生产的2个地下管", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "地下管连接" {
    desc = "连接水电站",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "水电站I", fluids = {"地下卤水"}},
    count = 1,
    prerequisites = {"获取地下管"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 126,
        y = 142,
        w = 1.0,
        h = 1.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      }, 
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 133,
        y = 142,
        w = 1.0,
        h = 1.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 129,
        y = 142,
        w = 3.1,
        h = 3.1,
        color = {1, 0, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 130,
        camera_y = 142,
        w = 1.0,
        h = 1.0,
      },
    },
    sign_desc = {
      { desc = "放置地下管绕过障碍连接液罐和水电站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  -- prototype "空气送入" {
  --   desc = "连接水电站",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"unknown", 0, 11},
  --   task_params = {building = "水电站I", fluids = {"空气"}},
  --   count = 1,
  --   prerequisites = {"卤水送入"},
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   guide_focus = {
  --     {
  --       prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --       x = 132.5,
  --       y = 144.5,
  --       w = 2.1,
  --       h = 2.1,
  --       color = {0.3, 1, 0, 1},
  --       show_arrow = false,
  --     },
  --     {
  --       camera_x = 133,
  --       camera_y = 144,
  --       w = 2.1,
  --       h = 2.1,
  --     },
  --   },
  --   sign_desc = {
  --     { desc = "放置空气过滤器在将空气连接入水电站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "气候科技包生产" {
    desc = "生产气候科技包",
    type = { "task" },
    task = {"stat_production", 0, "气候科技包"},
    count = 1,
    prerequisites = {"地下管连接"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "使用水电站生产1个气候科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "启动第二水电站" {
    desc = "连接水电站",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "水电站I", fluids = {"地下卤水","空气"}},
    count = 2,
    prerequisites = {"气候科技包生产"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 132,
        y = 147,
        w = 3.1,
        h = 3.1,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 132.5,
        y = 149.5,
        w = 2.0,
        h = 2.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 133,
        camera_y = 148,
        w = 2.0,
        h = 2.0,
      },
    },
    sign_desc = {
      { desc = "放置地下水挖掘机和空气过滤器启动第二个水电站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "液罐制造工艺" {
    desc = "火星地下开采卤水进行过滤净化工艺",
    type = { "tech" },
    effects = {
      unlock_item = {"液罐I"},
      unlock_recipe = {"液罐1"},
    },
    prerequisites = {"启动第二水电站"},
    ingredients = {
      {"气候科技包", 1},
    },
    count = 5,
    time = "4s"
  }

  prototype "液罐获取" {
    desc = "获取液罐",
    type = { "task" },
    task = {"stat_production", 0, "液罐I"},                 
    count = 2,
    prerequisites = {"液罐制造工艺"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 128,
        y = 136,
        w = 3.0,
        h = 3.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 128,
        camera_y = 136,
        w = 3.0,
        h = 3.0,
      },
    },
    effects = {
      unlock_recipe = {"地下卤水电解1"},
    },
    sign_desc = {
      { desc = "从组装机里获取已生产的2个液罐", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "电解厂配方设置" {
    desc = "电解厂配方选择",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "地下卤水电解1"},
    count = 1,
    prerequisites = {"液罐获取"},
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 98.5,
        y = 156.5,
        w = 4.4,
        h = 4.4,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 98,
        camera_y = 156,
        w = 4.4,
        h = 4.4,
      },
    },
    effects = {
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "电解厂选择配方“地下卤水电解1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "连接电解厂" {
    desc = "连接电解厂",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "电解厂I", fluids = {"地下卤水"}},
    count = 1,
    prerequisites = {"电解厂配方设置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 100,
        y = 160,
        w = 3.0,
        h = 3.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 100,
        camera_y = 160,
        w = 3.0,
        h = 3.0,
      },
    },
    sign_desc = {
      { desc = "放置地下水挖掘机连接电解厂", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "连接烟囱" {
    desc = "连接烟囱",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "烟囱I", fluids = {"氯气"}},
    count = 1,
    effects = {
      unlock_recipe = {"空气分离1"},
    },
    prerequisites = {"连接电解厂"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 97.5,
        y = 167.5,
        w = 2.0,
        h = 2.0,
        color = {0, 0.7, 0.95, 1},
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 97,
        y = 159,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 97,
        y = 166,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 97,
        camera_y = 167,
        w = 2.0,
        h = 2.0,
      },
    },
    sign_desc = {
      { desc = "放置地下水挖掘机连接电解厂", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "氢气存储" {
    desc = "液罐存储氢气",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "液罐I", fluids = {"氢气"}},
    prerequisites = {"连接烟囱"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack3.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack4.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack5.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack6.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 92,
        y = 150,
        w = 3.0,
        h = 3.0,
        color = {0, 0.7, 0.95, 1},
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 92,
        y = 152,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 90,
        y = 150,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 92,
        y = 147,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 94,
        y = 150,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 97,
        y = 154,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 94,
        camera_y = 152,
        w = 3.0,
        h = 3.0,
      },
    },
    sign_desc = {
      { desc = "电解厂生产氢气并用液罐存储", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "蒸馏厂配方设置" {
    desc = "组装机配方选择地质科技包1",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "空气分离1"},
    count = 1,
    prerequisites = {"氢气存储"},
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 110,
        y = 157,
        w = 5.1,
        h = 5.1,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 110,
        camera_y = 157,
        w = 4.1,
        h = 4.1,
      },
    },
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "蒸馏厂选择配方“空气分离1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "连接空气净化器" {
    desc = "连接烟囱",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "蒸馏厂I", fluids = {"空气"}},
    count = 1,
    prerequisites = {"蒸馏厂配方设置"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 111.5,
        y = 160.5,
        w = 2.0,
        h = 2.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 112,
        camera_y = 161,
        w = 2.0,
        h = 2.0,
      },
    },
    sign_desc = {
      { desc = "放置地下水挖掘机连接电解厂", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "二氧化碳存储" {
    desc = "液罐存储氢气",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "液罐I", fluids = {"二氧化碳"}},
    prerequisites = {"连接空气净化器"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack3.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack4.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack5.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack6.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 108,
        y = 154,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 108,
        camera_y = 154,
        w = 2.0,
        h = 2.0,
      },
    },
    effects = {
      unlock_recipe = {"二氧化碳转甲烷"},
    },
    sign_desc = {
      { desc = "电解厂生产氢气并用液罐存储", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "氮气清除" {
    desc = "排泄生产的氮气",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "烟囱I", fluids = {"氮气"}},
    count = 1,
    prerequisites = {"二氧化碳存储"},
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 111.5,
        y = 153.5,
        w = 2.0,
        h = 2.0,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 111,
        camera_y = 153,
        w = 2.0,
        h = 2.0,
      },
    },
    sign_desc = {
      { desc = "放置烟囱排泄氮气", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "化工厂配方设置" {
    desc = "组装机配方选择地质科技包1",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "二氧化碳转甲烷"},
    count = 1,
    prerequisites = {"氮气清除"},
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 104,
        y = 148,
        w = 3.1,
        h = 3.1,
        color = {0.3, 1, 0, 1},
        show_arrow = true,
      },
      {
        camera_x = 104,
        camera_y = 148,
        w = 3.1,
        h = 3.1,
      },
    },

    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    sign_desc = {
      { desc = "蒸馏厂选择配方“空气分离1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "化工厂原料添加" {
    desc = "向化工厂输送原料",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 11},
    task_params = {building = "化工厂I", fluids = {"二氧化碳","氢气"}},
    prerequisites = {"化工厂配方设置"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack3.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack4.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack5.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack6.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 103,
        y = 150,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 105,
        y = 150,
        w = 1.2,
        h = 1.2,
        color = {0.3, 1, 0, 1},
        show_arrow = false,
      },
      {
        camera_x = 104,
        camera_y = 150,
        w = 4.1,
        h = 4.1,
      },
    },
    sign_desc = {
      { desc = "化工厂输送氢气和二氧化碳", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "甲烷生产" {
    desc = "化工厂生产甲烷",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"stat_production", 0, "甲烷"}, 
    prerequisites = {"化工厂原料添加"},
    count = 300,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack3.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack4.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack5.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack6.texture",
    },
    sign_desc = {
      { desc = "化工厂生产300个单位甲烷", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  -- prototype "完成流体研究" {
  --   desc = "完成新的科技研究",
  --   type = { "tech" },
  --   prerequisites = {"甲烷生产"},
  --   ingredients = {
  --       {"气候科技包", 1},
  --   },
  --   count = 8,
  --   time = "1s"
  -- }

  prototype "流体教学结束" {
    desc = "教学结束",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {"甲烷生产"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的物流教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }