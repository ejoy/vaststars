local entities = { {
    dir = "N",
    items = { { "物流站", 3 },{ "停车站", 1},{"砖石公路-X型",50},{"组装机I",15}},
    prototype_name = "机身残骸",
    x = 109,
    y = 121
  }, {
    dir = "N",
    items = {{ "轻型太阳能板", 2 },{ "蓄电池I", 4 },{ "仓库I", 1 }},
    prototype_name = "机头残骸",
    x = 140,
    y = 136
  }, {
    dir = "E",
    items = { { "地下水挖掘机I", 1},{ "锅炉I", 1},{ "蒸汽发电机I", 1}, },
    prototype_name = "机尾残骸",
    x = 129,
    y = 114
  },{
    dir = "N",
    items = {{"碎石", 0},{"碎石", 0},{"铁矿石", 0},{"铁矿石", 0},},
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
    prototype_name = "轻型风力发电机",
    x = 110,
    y = 130
  },{
    dir = "N",
    recipe = "铁矿石挖掘",
    prototype_name = "采矿机I",
    x = 105,
    y = 127
  },{
    dir = "N",
    recipe = "碎石挖掘",
    prototype_name = "采矿机I",
    x = 105,
    y = 136
  },{
    dir = "N",
    recipe = "铁矿石挖掘",
    prototype_name = "采矿机I",
    x = 115,
    y = 136
  },{
    dir = "N",
    recipe = "碎石挖掘",
    prototype_name = "采矿机I",
    x = 115,
    y = 127
  },{
    dir = "N",
    items = {},
    prototype_name = "组装机I",
    x = 122,
    y = 130
  },{
    dir = "N",
    items = {},
    prototype_name = "熔炼炉I",
    x = 126,
    y = 130
  },{
    dir = "N",
    items = {},
    prototype_name = "组装机I",
    x = 130,
    y = 130
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 113,
    y = 135
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 113,
    y = 131
  },  {
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 125,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 126,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "仓库I",
    x = 127,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 128,
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 129,
    y = 133
  },{
    dir = "N",
    prototype_name = "铁制电线杆",
    x = 117,
    y = 131
  },{
    dir = "N",
    prototype_name = "铁制电线杆",
    x = 125,
    y = 131
  },{
    dir = "N",
    prototype_name = "铁制电线杆",
    x = 133,
    y = 131
  },{
    dir = "N",
    prototype_name = "铁制电线杆",
    x = 141,
    y = 131
  },{
    dir = "N",
    prototype_name = "铁制电线杆",
    x = 149,
    y = 131
  },{
    dir = "N",
    prototype_name = "指挥中心",
    amount = 0,
    x = 149,
    y = 125
  }, }
local road = {}

local mineral = {
  ["115,127"] = "碎石",
  ["105,127"] = "铁矿石",
  ["105,136"] = "碎石",
  ["115,136"] = "铁矿石",
}

return {
    name = "教学:物流搭建",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide.guide3",
    show = true,
    mode = "adventure",
    start_tech = "物流教学",
}