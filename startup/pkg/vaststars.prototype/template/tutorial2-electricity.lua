local entities = { {
    dir = "N",
    items = { { "采矿机I", 3 },{ "铁制电线杆", 10},{ "轻型风力发电机", 1 },},
    prototype_name = "机身残骸",
    x = 115,
    y = 123
  }, {
    dir = "N",
    items = {{ "轻型太阳能板", 4 },{ "蓄电池I", 10 }},
    prototype_name = "机头残骸",
    x = 140,
    y = 136
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
    x = 123,
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
    x = 131,
    y = 129
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 126,
    y = 132
  },{
    dir = "N",
    items = {},
    prototype_name = "无人机平台I",
    x = 127,
    y = 132
  },{
    dir = "N",
    items = {},
    prototype_name = "仓库I",
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
    prototype_name = "无人机平台I",
    x = 130,
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
    name = "教学:电网搭建",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide.guide2",
    show = true,
    mode = "adventure",
    start_tech = "电网教学",
}