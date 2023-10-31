local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

  prototype "登录科技" {
    desc = "获得火星岩石加工成石砖的工艺",
    type = { "tech" },
    icon = "/pkg/vaststars.resources/ui/textures/science/book.texture",
    prerequisites = {},
    ingredients = {
        {"地质科技包", 1},
        {"气候科技包", 1},
    },
    count = 100000,
    time = "1s"
  }

  prototype "登录结束" {
    desc = "教学结束",
    icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
    type = { "task" },
    task = {"unknown", 0, 4},
    effects = {
    },
    prerequisites = {"登录科技"},
    count = 1,
    tips_pic = {
      "",
    },
    sign_desc = {
      { desc = "完成所有的挖矿教学", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
    },
  }

 