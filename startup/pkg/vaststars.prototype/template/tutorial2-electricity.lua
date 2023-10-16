local entities = { {
    dir = "N",
    prototype_name = "指挥中心",
    amount = 50,
    x = 124,
    y = 120
  }, {
    dir = "N",
    items = { { "旧风力发电机", 1 },{ "采矿机I", 3 },},
    prototype_name = "机身残骸",
    x = 115,
    y = 123
  }, {
    dir = "N",
    items = {{ "太阳能板I", 5 },{ "蓄电池I", 10 },{ "铁制电线杆", 10}},
    prototype_name = "机头残骸",
    x = 140,
    y = 136
  },{
    dir = "S",
    items = { { "仓库I", 1 },{ "组装机I", 3 },{"科研中心I",1}, { "无人机平台I", 3}},
    prototype_name = "机头残骸",
    x = 135,
    y = 130
  }, {
    dir = "E",
    items = { { "地下水挖掘机I", 2},{ "锅炉I", 2},{ "蒸汽发电机I", 4}, },
    prototype_name = "机尾残骸",
    x = 129,
    y = 114
  },{
    dir = "N",
    items = {},
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
    y = 133
  },{
    dir = "N",
    items = {},
    prototype_name = "组装机I",
    x = 124,
    y = 129
  },{
    dir = "N",
    items = {},
    prototype_name = "组装机I",
    x = 127,
    y = 129
  },{
    dir = "N",
    items = {},
    prototype_name = "组装机I",
    x = 130,
    y = 129
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 127,
    y = 132
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 128,
    y = 132
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 129,
    y = 132
  },{
    dir = "N",
    items = {},
    prototype_name = "科研中心I",
    x = 127,
    y = 134
  },}
local road = {}

local mineral = {
  ["115,131"] = "碎石",
  ["105,127"] = "铁矿石",
  ["106,137"] = "铝矿石",
}

return {
    name = "教学:电力搭建",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide",
    show = true,
    mode = "adventure",
}