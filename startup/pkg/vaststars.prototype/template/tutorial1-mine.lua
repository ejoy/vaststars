local entities = { {
    dir = "N",
    prototype_name = "指挥中心",
    amount = 50,
    x = 124,
    y = 120
  }, {
    dir = "N",
    items = { { "收货车站", 2 }, { "出货车站", 2 }, { "铁制电线杆", 10 }, { "熔炼炉I", 2 }, { "无人机平台I", 5 }, { "水电站I", 2 } },
    prototype_name = "机身残骸",
    x = 125,
    y = 129
  }, {
    dir = "S",
    items = { { "无人机平台I", 4 }, { "采矿机I", 2 }, { "科研中心I", 1 }, { "组装机I", 4 } },
    prototype_name = "机尾残骸",
    x = 110,
    y = 120
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 121,
    y = 121
  }, }
local road = {}

local mineral = {
  ["138,115"] = "铝矿石",
  ["133,135"] = "铁矿石",
  ["115,129"] = "碎石",
}

return {
    name = "教学:矿物挖掘",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide.guide1",
}
    