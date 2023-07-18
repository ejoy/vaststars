local entities = { {
  dir = "N",
  items = {},
  prototype_name = "指挥中心",
  x = 124,
  y = 120
}, {
  dir = "N",
  items = { { "水电站I", 1 }, { "铁制电线杆", 15 }, { "收货车站", 4 }, { "出货车站", 4 }, { "熔炼炉I", 2 }, { "无人机仓库I", 8 } },
  prototype_name = "机身残骸",
  x = 107,
  y = 134
}, {
  dir = "S",
  items = { { "空气过滤器框架", 2}, { "化工厂框架", 2},{ "地下水挖掘机框架", 3}, { "水电站框架", 1},  { "破损运输车辆", 16}, { "蒸馏厂框架", 2 },{ "无人机仓库框架", 6 },{ "电线杆框架", 15 },{ "组装机框架", 6 }},
  prototype_name = "机尾残骸",
  x = 110,
  y = 120
}, {
  dir = "S",
  items = { { "风力发电机I", 1 }, { "锅炉I", 4 }, { "蓄电池I", 10 }, { "运输车辆I", 10 }, { "太阳能板I", 6 }, { "蒸汽发电机I", 8 } },
  prototype_name = "机翼残骸",
  x = 133,
  y = 122
}, {
  dir = "W",
  items = { { "化工厂I", 2 }, { "空气过滤器I", 2 }, { "地下水挖掘机I", 1 }, { "电解厂I", 1 },{ "砖石公路-X型", 50 }, { "采矿机I", 4 }, { "科研中心I", 2 }, { "组装机I", 8 } },
  prototype_name = "机头残骸",
  x = 125,
  y = 108
} }
local road = {}

local mineral = {
  ["102,62"] = "铁矿石",
  ["115,133"] = "碎石",
  ["138,174"] = "铁矿石",
  ["144,86"] = "碎石",
  ["145,149"] = "碎石",
  ["150,95"] = "铁矿石",
  ["164,127"] = "铁矿石",
  ["170,112"] = "碎石",
  ["173,76"] = "铁矿石",
  ["180,193"] = "铁矿石",
  ["192,132"] = "碎石",
  ["197,117"] = "铁矿石",
  ["209,162"] = "铁矿石",
  ["210,142"] = "地热气",
  ["61,118"] = "铁矿石",
  ["62,185"] = "铁矿石",
  ["72,132"] = "碎石",
  ["75,93"] = "铁矿石",
  ["91,165"] = "铁矿石",
  ["93,102"] = "碎石",
  ["93,203"] = "地热气",
  ["131,100"] = "铝矿石",
}

return {
  name = "纯净模式",
  entities = entities,
  road = road,
  mineral = mineral,
}
