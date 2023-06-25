local entities = { {
  dir = "N",
  items = {},
  prototype_name = "指挥中心",
  recipe = "车辆装配",
  x = 121,
  y = 118
}, {
  dir = "N",
  items = { { "水电站I", 2 }, { "收货车站", 2 }, { "无人机仓库I", 5 }, { "出货车站", 2 }, { "铁制电线杆", 10 }, { "熔炼炉I", 2 } },
  prototype_name = "机身残骸",
  x = 107,
  y = 134
}, {
  dir = "S",
  items = { { "采矿机I", 2 }, { "无人机仓库I", 4 }, { "科研中心I", 1 }, { "组装机I", 4 } },
  prototype_name = "机尾残骸",
  x = 110,
  y = 120
}, {
  dir = "W",
  items = { { "空气过滤器I", 4 }, { "电解厂I", 1 }, { "地下水挖掘机", 4 }, { "化工厂I", 3 } },
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
  prototype_name = "无人机仓库I",
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
  item = "铁矿石",
  prototype_name = "无人机仓库I",
  x = 161,
  y = 126
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
  item = "碎石",
  prototype_name = "无人机仓库I",
  x = 118,
  y = 126
}, {
  dir = "N",
  item = "碎石",
  prototype_name = "无人机仓库I",
  x = 136,
  y = 112
}, {
  dir = "N",
  item = "铁矿石",
  prototype_name = "无人机仓库I",
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
  item = "石砖",
  prototype_name = "无人机仓库I",
  x = 131,
  y = 112
}, {
  dir = "N",
  item = "铁板",
  prototype_name = "无人机仓库I",
  x = 131,
  y = 116
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
  dir = "S",
  item = "碎石",
  prototype_name = "出货车站",
  x = 120,
  y = 126
}, {
  dir = "S",
  item = "铁矿石",
  prototype_name = "出货车站",
  x = 154,
  y = 126
}, {
  dir = "N",
  item = "铁矿石",
  prototype_name = "无人机仓库I",
  x = 158,
  y = 126
}, {
  dir = "W",
  item = "铁矿石",
  prototype_name = "收货车站",
  x = 136,
  y = 118
}, {
  dir = "W",
  item = "碎石",
  prototype_name = "收货车站",
  x = 136,
  y = 108
} }
local road = { {
  direction = "S",
  prototype = "砖石公路-T型",
  x = 124,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 126,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 128,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 130,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 132,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 134,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 136,
  y = 124
}, {
  direction = "S",
  prototype = "砖石公路-T型",
  x = 138,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 140,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 142,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 144,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 146,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 148,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 150,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 152,
  y = 124
}, {
  direction = "N",
  prototype = "砖石公路-T型",
  x = 154,
  y = 124
}, {
  direction = "N",
  prototype = "砖石公路-T型",
  x = 156,
  y = 124
}, {
  direction = "W",
  prototype = "砖石公路-U型",
  x = 158,
  y = 124
}, {
  direction = "N",
  prototype = "砖石公路-I型",
  x = 138,
  y = 112
}, {
  direction = "E",
  prototype = "砖石公路-T型",
  x = 138,
  y = 120
}, {
  direction = "N",
  prototype = "砖石公路-X型",
  x = 122,
  y = 124
}, {
  direction = "N",
  prototype = "砖石公路-I型",
  x = 138,
  y = 116
}, {
  direction = "N",
  prototype = "砖石公路-T型",
  x = 120,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-T型",
  x = 138,
  y = 110
}, {
  direction = "E",
  prototype = "砖石公路-U型",
  x = 116,
  y = 124
}, {
  direction = "E",
  prototype = "砖石公路-I型",
  x = 118,
  y = 124
}, {
  direction = "N",
  prototype = "砖石公路-I型",
  x = 138,
  y = 114
}, {
  direction = "N",
  prototype = "砖石公路-I型",
  x = 138,
  y = 122
}, {
  direction = "E",
  prototype = "砖石公路-T型",
  x = 138,
  y = 118
}, {
  direction = "E",
  prototype = "砖石公路-T型",
  x = 138,
  y = 108
}, {
  direction = "N",
  prototype = "砖石公路-I型",
  x = 138,
  y = 106
}, {
  direction = "S",
  prototype = "砖石公路-U型",
  x = 138,
  y = 104
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
local function prepare(world)
  local prototype = import_package "vaststars.gameplay".prototype
  local e = assert(world.ecs:first("base eid:in"))
  e = world.entity[e.eid]
  local pt = prototype.queryByName("运输车辆I")
  local slot, idx
  for i = 1, 256 do
      local s = world:container_get(e.chest, i)
      if not s then
          break
      end
      if s.item == pt.id then
          slot, idx = s, i
          break
      end
  end
  assert(slot)
  world:container_set(e.chest, idx, {amount = 10, limit = 50})
end

return {
  name = "物流测试",
  entities = entities,
  road = road,
  mineral = mineral,
  prepare = prepare,
}
  