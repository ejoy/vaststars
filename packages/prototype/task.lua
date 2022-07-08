local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


prototype "拆除3个废墟建筑" {
    desc = "矿区里放置采矿机",
    icon = "textures/construct/industry.texture",
    type = { "tech", "task" },
    task = {"select_entity", 0, "采矿机I"},
    -- task = {"select_chest", 0, "指挥中心", "铁矿石"},
    prerequisites = {"地质研究"},
    count = 2,
    tips_pic = {
      "textures/task_tips_pic/task_click_build.texture",
      "textures/task_tips_pic/task_produce_ore1.texture",
      "textures/task_tips_pic/task_produce_ore2.texture",
      "textures/task_tips_pic/start_construct.texture",
    },
    sign_desc = {
      { desc = "拆除指挥中心附近的3个废墟建筑", icon = "textures/construct/industry.texture"},
    },
  }

