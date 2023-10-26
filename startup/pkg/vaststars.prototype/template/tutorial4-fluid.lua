local entities = { {
  dir = "N",
  items = { { "停车站", 1 },{ "物流站", 3}, { "轻型运输车", 2 },{"砖石公路-X型",20},},
  prototype_name = "机身残骸",
  x = 109,
  y = 138
}, {
  dir = "N",
  items = { { "仓库I", 4 }, { "蓄电池I", 4 }, { "无人机平台I", 2 },{ "轻型太阳能板", 2 } },
  prototype_name = "机头残骸",
  x = 140,
  y = 136
}, {
  dir = "N",
  items = { { "碎石", 45 }, { "碎石", 45 }, { "铁矿石", 51 }, { "铁矿石", 50 } },
  prototype_name = "仓库I",
  x = 111,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 109,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 113,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 109,
  y = 135
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 110,
  y = 130
}, {
  dir = "N",
  prototype_name = "轻型采矿机",
  recipe = "铁矿石挖掘",
  x = 105,
  y = 136
}, {
  dir = "N",
  prototype_name = "轻型采矿机",
  recipe = "碎石挖掘",
  x = 115,
  y = 127
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 150,
  y = 122
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "熔炼炉I",
  x = 152,
  y = 126
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "科研中心I",
  x = 156,
  y = 126
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 150,
  y = 130
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 113,
  y = 131
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 150,
  y = 129
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 150,
  y = 128
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 150,
  y = 127
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 150,
  y = 126
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 150,
  y = 125
}, {
  amount = 0,
  dir = "N",
  prototype_name = "物流中心",
  x = 152,
  y = 114
} }
local road = {}

local mineral = {
  ["115,127"] = "碎石",
  ["105,136"] = "铁矿石",
  ["156,100"] = "铝矿石",
}

return {
    name = "教学:液网搭建",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide.guide4",
    show = true,
    mode = "adventure",
    start_tech = "流体教学",
}