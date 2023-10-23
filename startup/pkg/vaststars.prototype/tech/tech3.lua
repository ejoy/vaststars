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