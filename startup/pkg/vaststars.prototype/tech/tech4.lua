local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


  prototype "流体教学" {
    desc = "流体教学",
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
      { desc = "流体教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

  prototype "完成流体研究" {
    desc = "完成新的科技研究",
    type = { "tech" },
    icon = "/pkg/vaststars.resources/ui/textures/science/book.texture",
    prerequisites = {"流体教学"},
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