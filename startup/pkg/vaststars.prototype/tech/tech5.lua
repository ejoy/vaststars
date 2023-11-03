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

  

  prototype "自动化教学结束" {
    desc = "教学结束",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {"自动化教学"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的物流教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }