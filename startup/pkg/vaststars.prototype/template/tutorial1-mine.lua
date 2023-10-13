local entities = { {
    dir = "N",
    prototype_name = "指挥中心",
    amount = 50,
    x = 124,
    y = 120
  }, {
    dir = "N",
    items = { { "采矿机I", 3 }, { "仓库I", 1 }, { "铁制电线杆", 10 }},
    prototype_name = "机身残骸",
    x = 121,
    y = 129
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 121,
    y = 121
  }, }
local road = {}

local mineral = {
  ["134,121"] = "铝矿石",
  ["127,135"] = "铁矿石",
  ["115,129"] = "碎石",
}

return {
    name = "教学:矿物挖掘",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide",
    show = false,
}
    