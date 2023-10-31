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



 