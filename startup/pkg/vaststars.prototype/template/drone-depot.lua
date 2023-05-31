local entities = { {
    dir = "N",
    items = {},
    prototype_name = "指挥中心",
    recipe = "车辆装配",
    x = 125,
    y = 120
  }, {
    dir = "N",
    items = { { "收货车站", 2 }, { "送货车站", 2 }, { "铁制电线杆", 10 }, { "熔炼炉I", 2 }, { "无人机仓库I", 5 }, { "水电站I", 2 } },
    prototype_name = "机身残骸",
    x = 107,
    y = 134
  }, {
    dir = "S",
    items = { { "无人机仓库I", 4 }, { "采矿机I", 2 }, { "科研中心I", 1 }, { "组装机I", 4 } },
    prototype_name = "机尾残骸",
    x = 110,
    y = 120
  }, {
    dir = "S",
    items = { { "风力发电机I", 1 }, { "蓄电池I", 10 }, { "运输车框架", 100 }, { "太阳能板I", 6 }, { "蒸汽发电机I", 8 }, { "锅炉I", 4 } },
    prototype_name = "机翼残骸",
    x = 133,
    y = 122
  }, {
    dir = "W",
    items = { { "化工厂I", 3 }, { "地下水挖掘机", 4 }, { "电解厂I", 1 }, { "空气过滤器I", 4 } },
    prototype_name = "机头残骸",
    x = 125,
    y = 108
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 121,
    y = 121
  }, {
    dir = "N",
    prototype_name = "采矿机I",
    recipe = "碎石挖掘",
    x = 115,
    y = 129
  }, {
    dir = "N",
    item = "碎石",
    prototype_name = "无人机仓库I",
    x = 117,
    y = 127
  }, {
    dir = "N",
    prototype_name = "组装机I",
    recipe = "石砖",
    x = 119,
    y = 124
  }, {
    dir = "N",
    prototype_name = "组装机I",
    recipe = "石砖",
    x = 119,
    y = 129
  }, {
    dir = "N",
    item = "石砖",
    prototype_name = "无人机仓库I",
    x = 122,
    y = 127
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 162,
    y = 123
  }, {
    dir = "N",
    prototype_name = "采矿机I",
    recipe = "铁矿石挖掘",
    x = 164,
    y = 129
  }, {
    dir = "N",
    item = "铁矿石",
    prototype_name = "无人机仓库I",
    x = 162,
    y = 127
  }, {
    dir = "N",
    prototype_name = "熔炼炉I",
    recipe = "铁板1",
    x = 158,
    y = 124
  }, {
    dir = "N",
    prototype_name = "熔炼炉I",
    recipe = "铁板1",
    x = 158,
    y = 128
  }, {
    dir = "N",
    item = "铁板",
    prototype_name = "无人机仓库I",
    x = 155,
    y = 127
  } }
local road = {}

local mineral = {
  ["136,172"] = "铁矿石",
  ["100,60"] = "铁矿石",
  ["162,127"] = "铁矿石",
  ["89,156"] = "铁矿石",
  ["60,183"] = "铁矿石",
  ["59,116"] = "铁矿石",
  ["73,91"] = "铁矿石",
  ["171,74"] = "铁矿石",
  ["194,115"] = "铁矿石",
  ["207,160"] = "铁矿石",
  ["178,191"] = "铁矿石",
  ["148,93"] = "铁矿石",
  ["168,110"] = "碎石",
  ["142,84"] = "碎石",
  ["113,127"] = "碎石",
  ["70,130"] = "碎石",
  ["91,100"] = "碎石",
  ["143,147"] = "碎石",
  ["190,130"] = "碎石",
}

return {
    name = "无人机测试",
    entities = entities,
    road = road,
    mineral = mineral,
}
    