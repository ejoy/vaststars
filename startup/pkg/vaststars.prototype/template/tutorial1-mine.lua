local entities = { {
    dir = "N",
    items = {{ "仓库I", 1 }, { "采矿机I", 3 },  { "铁制电线杆", 9 }},
    prototype_name = "机身残骸",
    x = 121,
    y = 129
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 121,
    y = 121
  }, {
    dir = "N",
    prototype_name = "组装机I",
    x = 122,
    y = 115
  }, {
    dir = "N",
    prototype_name = "无人机平台I",
    x = 120,
    y = 116
  },}
local road = {}

local mineral = {
  ["134,121"] = "铝矿石",
  ["126,135"] = "铁矿石",
  ["115,129"] = "碎石",
}

return {
    name = "教学:矿物挖掘",
    entities = entities,
    road = road,
    mineral = mineral,
    order = 7,
    guide = "guide.guide1",
    show = true,
    mode = "adventure",
    start_tech = "采矿教学",
}