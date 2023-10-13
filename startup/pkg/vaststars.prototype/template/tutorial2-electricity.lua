local entities = { {
    dir = "N",
    prototype_name = "指挥中心",
    amount = 50,
    x = 124,
    y = 120
  }, {
    dir = "N",
    items = { { "风力发电机I", 1 },{ "采矿机I", 3 }, { "无人机平台I", 3 }},
    prototype_name = "机身残骸",
    x = 115,
    y = 123
  }, {
    dir = "N",
    items = {{ "太阳能板I", 5 },{ "蓄电池I", 10 }},
    prototype_name = "机头残骸",
    x = 140,
    y = 136
  },{
    dir = "S",
    items = { { "铁制电线杆", 20 },{ "组装机I", 3 },{"仓库I",1}, { "无人机平台I", 3}},
    prototype_name = "机头残骸",
    x = 130,
    y = 130
  }, {
    dir = "E",
    items = { { "地下水挖掘机I", 2},{ "锅炉I", 2},{ "蒸汽发电机I", 4}, },
    prototype_name = "机尾残骸",
    x = 135,
    y = 114
  },{
    dir = "E",
    items = {},
    prototype_name = "仓库I",
    x = 111,
    y = 133
  },}
local road = {}

local mineral = {
  ["115,131"] = "碎石",
  ["105,127"] = "碎石",
  ["106,137"] = "碎石",
}

return {
    name = "教学:电力搭建",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide",
    show = true,
}
    