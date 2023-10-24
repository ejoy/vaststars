local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


  prototype "物流教学" {
    desc = "物流教学",
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

  prototype "废墟搜索" {
    desc = "从废墟中搜索物资",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 6},
    task_params = {ui = "pickup_item", building = "机身残骸"},
    prerequisites = {"物流教学"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 111,
        y = 140,
        w = 4.0,
        h = 4.0,
        show_arrow = true,
      },
      {
        camera_x = 111,
        camera_y = 138,
      },
    },
    sign_desc = {
      { desc = "搜索机身残骸获取有用物资", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "道路维修" {
    desc = "维修砖石公路",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 1},
    task_params = {
        path = {
                {{112, 134}, {145, 134}},
                {{162, 132}, {162, 122}},
              }
    },
    prerequisites = {"废墟搜索"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    -- effects = {
    --   unlock_recipe = {"石砖","砖石公路打印"},
    --   unlock_item = {"石砖","砖石公路-X型"},
    -- },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 138.5,
        y = 134.5,
        w = 6.4,
        h = 2,
        show_arrow = true,
      },
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 162.5,
        y = 126.5,
        w = 2,
        h = 6.4,
        show_arrow = true,
      },
      {
        camera_x = 148,
        camera_y = 134,
      },
    },
    sign_desc = {
      { desc = "修补2处断开的砖石公路", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }
  
  prototype "停车站放置" {
    desc = "放置1座停车站",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"select_entity", 0, "停车站"},
    prerequisites = {"道路维修"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 165.5,
        y = 122.5,
        w = 4.2,
        h = 2.1,
        show_arrow = true,
      },
      {
        camera_x = 164,
        camera_y = 122,
      },
    },
    effects = {
      unlock_item = {"碎石","铁矿石"},
    },
    sign_desc = {
      { desc = "在放置1座停车站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  -- prototype "物流站放置" {
  --   desc = "放置1座物流站",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = {"task" },
  --   task = {"select_entity", 0, "物流站"},
  --   prerequisites = {"停车站放置"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "放置1座物流站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  --   effects = {
  --     unlock_item = {"碎石","铁矿石"},
  --   },
  -- }

  prototype "物流站设置" {
    desc = "物流站发货设置",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = {"task" },
    task = {"unknown", 0, 8},
    task_params = {items = {"supply|碎石", "supply|铁矿石"}},
    prerequisites = {"停车站放置"},
    count = 1,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
    },
    guide_focus = {
      {
        prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
        x = 115.5,
        y = 132.5,
        w = 4.2,
        h = 2.1,
        show_arrow = true,
      },
      {
        camera_x = 114,
        camera_y = 132,
      },
    },
    sign_desc = {
      { desc = "物流站设置发货碎石和铁矿石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "派遣运输车" {
    desc = "派遣2辆运输车",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 2},                          
    prerequisites = {"物流站放置"},
    count = 2,
    tips_pic = {
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate1.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate2.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate3.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate4.texture",
      "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate5.texture",
    },
    effects = {
      unlock_recipe = {"石砖","砖石公路打印"},
      unlock_item = {"石砖","砖石公路-X型"},
    },
    sign_desc = {
      { desc = "指挥中心派遣2辆运输车", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }