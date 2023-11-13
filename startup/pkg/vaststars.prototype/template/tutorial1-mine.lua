local guide = require "guide.guide1"
local mountain = require "mountain"

local entities = { {
    dir = "N",
    items = {{ "仓库I", 1 }, { "采矿机I", 3 }},
    prototype_name = "机身残骸",
    x = 121,
    y = 129
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 115,
    y = 135
  }, {
    dir = "N",
    prototype_name = "组装机I",
    x = 122,
    y = 121
  }, {
    dir = "N",
    prototype_name = "无人机平台I",
    x = 120,
    y = 123
  },}
local road = {}

local mineral = {
  ["134,121"] = "铝矿石",
  ["126,135"] = "铁矿石",
  ["115,129"] = "碎石",
}

return {
    name = "矿物挖掘",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 1,
    guide = guide,
    show = true,
    start_tech = "采矿教学",
    init_ui = {
      "/pkg/vaststars.resources/ui/construct.rml",
      "/pkg/vaststars.resources/ui/message_pop.rml"
    },
    init_instances = {
    },
    debugger = {
      skip_guide = false,
      recipe_unlocked = false,
      item_unlocked = false,
      infinite_item = false,
    },
    camera = "/pkg/vaststars.resources/camera_default.prefab",
}