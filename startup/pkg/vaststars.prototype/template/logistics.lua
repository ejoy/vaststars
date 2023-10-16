local entities = { {
  dir = "N",
  prototype_name = "指挥中心",
  amount = 50,
  x = 120,
  y = 118
}, {
  dir = "N",
  items = { { "水电站I", 2 }, { "物流站", 2 }, { "无人机平台I", 5 }, { "物流站", 2 }, { "铁制电线杆", 10 }, { "熔炼炉I", 2 } },
  prototype_name = "机身残骸",
  x = 107,
  y = 134
}, {
  dir = "S",
  items = { { "采矿机I", 2 }, { "无人机平台I", 4 }, { "科研中心I", 1 }, { "组装机I", 4 } },
  prototype_name = "机尾残骸",
  x = 110,
  y = 120
}, {
  dir = "W",
  items = { { "空气过滤器I", 4 }, { "电解厂I", 1 }, { "地下水挖掘机I", 4 }, { "化工厂I", 3 } },
  prototype_name = "机头残骸",
  x = 125,
  y = 108
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 143,
  y = 147
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 146,
  y = 147
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 141,
  y = 145
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 164,
  y = 129
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 160,
  y = 130
}, {
  dir = "N",
  items = {{"铁矿石",0}},
  prototype_name = "仓库I",
  x = 160,
  y = 127
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 162,
  y = 127
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 115,
  y = 129
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 113,
  y = 123
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 118,
  y = 127
}, {
  dir = "N",
  items = {{"碎石", 0}},
  prototype_name = "仓库I",
  x = 118,
  y = 126
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 136,
  y = 112
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 136,
  y = 116
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 133,
  y = 116
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "石砖",
  x = 133,
  y = 111
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 131,
  y = 112
}, {
  dir = "N",
  items = {{"石砖",0}},
  prototype_name = "仓库I",
  x = 131,
  y = 113
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 131,
  y = 116
}, {
  dir = "N",
  items = {{"铁板",0}},
  prototype_name = "仓库I",
  x = 131,
  y = 117
}, {
  dir = "N",
  prototype_name = "铁制电线杆",
  x = 134,
  y = 119
}, {
  dir = "N",
  prototype_name = "铁制电线杆",
  x = 134,
  y = 114
}, {
  dir = "N",
  prototype_name = "铁制电线杆",
  x = 128,
  y = 114
}, {
  dir = "N",
  prototype_name = "铁制电线杆",
  x = 122,
  y = 114
}, {
  dir = "N",
  prototype_name = "铁制电线杆",
  x = 114,
  y = 114
}, {
  dir = "N",
  prototype_name = "铁制电线杆",
  x = 114,
  y = 118
}, {
  dir = "S",
  items = {{"supply", "碎石", "1"}},
  prototype_name = "物流站",
  x = 120,
  y = 126
}, {
  dir = "S",
  items = {{"supply", "铁矿石", "1"}},
  prototype_name = "物流站",
  x = 154,
  y = 126
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 158,
  y = 127
}, {
  dir = "W",
  items = {{"demand", "铁矿石", "1"}},
  prototype_name = "物流站",
  x = 136,
  y = 118
}, {
  dir = "W",
  items = {{"demand", "碎石", "1"}},
  prototype_name = "物流站",
  x = 136,
  y = 108
}, {
  dir = "S",
  prototype_name = "停车站",
  x = 146,
  y = 116
}}
local road = { {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 124
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 138,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 124
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 158,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 112
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 116
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 116,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 108
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 106
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 138,
  y = 104
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 138,
  y = 114
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 114
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 114
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 114
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 150,
  y = 114
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 114
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 114
} }
local mineral = {
  ["102,62"] = "铁矿石",
  ["115,129"] = "碎石",
  ["138,174"] = "铁矿石",
  ["144,86"] = "碎石",
  ["145,149"] = "碎石",
  ["150,95"] = "铁矿石",
  ["164,129"] = "铁矿石",
  ["170,112"] = "碎石",
  ["173,76"] = "铁矿石",
  ["180,193"] = "铁矿石",
  ["192,132"] = "碎石",
  ["196,117"] = "铁矿石",
  ["209,162"] = "铁矿石",
  ["61,118"] = "铁矿石",
  ["62,185"] = "铁矿石",
  ["72,132"] = "碎石",
  ["75,93"] = "铁矿石",
  ["91,158"] = "铁矿石",
  ["93,102"] = "碎石"
}

return {
  name = "物流测试",
  entities = entities,
  road = road,
  mineral = mineral,
  order = 6,
  guide = "guide",
  mode = "free",
}