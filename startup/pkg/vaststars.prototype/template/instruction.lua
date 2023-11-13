local guide = require "guide"
local mountain = require "mountain"

local entities = { {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 182,
  y = 71
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 185,
  y = 71
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 182,
  y = 74
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 185,
  y = 74
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "地质科技包1",
  x = 123,
  y = 83
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "机械科技包1",
  x = 123,
  y = 86
}, {
  dir = "N",
  fluid_name = {
    input = { "润滑油" },
    output = {}
  },
  prototype_name = "组装机I",
  recipe = "电子科技包1",
  x = 123,
  y = 90
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "物理科技包1",
  x = 123,
  y = 93
}, {
  dir = "N",
  items = { { "机械科技包", 28 }, { "化学科技包", 28 }, { "物理科技包", 28 }, { "地质科技包", 28 } },
  prototype_name = "仓库I",
  x = 127,
  y = 89
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 127,
  y = 91
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 127,
  y = 87
}, {
  dir = "N",
  prototype_name = "科研中心I",
  x = 129,
  y = 88
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 142,
  y = 60
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 115,
  y = 129
}, {
  dir = "N",
  items = { { "碎石", 29 }, { "碎石", 28 } },
  prototype_name = "仓库I",
  x = 117,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 116,
  y = 132
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 130,
  y = 129
}, {
  dir = "N",
  items = { { "铝矿石", 35 } },
  prototype_name = "仓库I",
  x = 132,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 131,
  y = 132
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 120,
  y = 129
}, {
  dir = "N",
  items = { { "铁矿石", 55 } },
  prototype_name = "仓库I",
  x = 122,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 132
} }
local backpack = { {
  count = 1,
  prototype_name = "仓库I"
}, {
  count = 46,
  prototype_name = "碎石"
}, {
  count = 24,
  prototype_name = "铁矿石"
}, {
  count = 16,
  prototype_name = "铝矿石"
}, {
  count = 29,
  prototype_name = "地质科技包"
} }
local road = {}
local mineral = {
["115,129"] = "碎石",
["120,129"] = "铁矿石",
["125,129"] = "地热气",
["130,129"] = "铝矿石",
["135,129"] = "砂岩"
}

return {
  name = "游戏教程",
  entities = entities,
  road = road,
  mineral = mineral,
  mountain = mountain,
  order = 2,
  guide = guide,
  start_tech = "润滑",
  init_ui = {
    "/pkg/vaststars.resources/ui/construct.rml",
    "/pkg/vaststars.resources/ui/message_pop.rml"
  },
  init_instances = {
  },
  debugger = {
    skip_guide = false,
    recipe_unlocked = true,
    item_unlocked = true,
    infinite_item = true,
  },
  camera = "/pkg/vaststars.resources/camera_default.prefab",
}