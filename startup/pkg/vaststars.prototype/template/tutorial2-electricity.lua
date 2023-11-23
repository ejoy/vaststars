local guide = require "guide.guide2"
local mountain = require "mountain"

local items = {}
for _ = 1, 16 do
  items[#items+1] = {"", 0}
end

local entities = { {
    dir = "N",
    items = items,
    prototype_name = "指挥中心",
    x = 126,
    y = 120
  },{
    dir = "N",
    items = { { "采矿机I", 3 },{ "轻型风力发电机", 1 },},
    prototype_name = "机身残骸",
    x = 115,
    y = 123
  }, {
    dir = "N",
    items = {{ "轻型太阳能板", 1 },{ "蓄电池I", 4 }},
    prototype_name = "机头残骸",
    x = 140,
    y = 136
  }, {
    dir = "E",
    items = { { "地下水挖掘机I", 1},{ "蒸汽发电机I", 1},{ "锅炉I", 1} },
    prototype_name = "机尾残骸",
    x = 129,
    y = 114
  },{
    dir = "N",
    items = { { "碎石", 0},{ "铁矿石", 0},{ "铝矿石", 0} },
    prototype_name = "仓库I",
    x = 111,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 109,
    y = 131
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 109,
    y = 135
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 113,
    y = 135
  },{
    dir = "N",
    items = {},
    prototype_name = "组装机I",
    x = 123,
    y = 130
  },{
    dir = "N",
    items = {},
    prototype_name = "熔炼炉I",
    x = 127,
    y = 130
  },{
    dir = "N",
    items = {},
    prototype_name = "组装机I",
    x = 131,
    y = 130
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 126,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 127,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "仓库I",
    x = 128,
    y = 133
  },{
    dir = "N",
    items = {{ "铁板", 6 }},
    prototype_name = "仓库I",
    x = 128,
    y = 134
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 129,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 130,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "地质科研中心",
    x = 127,
    y = 135
  },}
local road = {}

local mineral = {
  ["115,131"] = "碎石",
  ["105,127"] = "铁矿石",
  ["106,136"] = "铝矿石",
}

return {
    name = "电力搭建",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 2,
    guide = guide,
    show = true,
    start_tech = "电网教学",
    init_ui = {
      "/pkg/vaststars.resources/ui/construct.rml",
      "/pkg/vaststars.resources/ui/message_pop.rml"
    },
    init_instances = {
    },
    game_settings = {
      skip_guide = false,
      recipe_unlocked = false,
      item_unlocked = false,
      infinite_item = false,
    },
    camera = "/pkg/vaststars.resources/camera_default.prefab",
}