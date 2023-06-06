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
  mask = 7,
  prototype = "砖石公路-X型",
  x = 62,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 63,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 64,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 65,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 66,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 67,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 68,
  y = 62
}, {
  mask = 7,
  prototype = "砖石公路-X型",
  x = 69,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 70,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 71,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 72,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 73,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 74,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 75,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 76,
  y = 62
}, {
  mask = 13,
  prototype = "砖石公路-X型",
  x = 77,
  y = 62
}, {
  mask = 13,
  prototype = "砖石公路-X型",
  x = 78,
  y = 62
}, {
  mask = 1,
  prototype = "砖石公路-X型",
  x = 79,
  y = 62
}, {
  mask = 10,
  prototype = "砖石公路-X型",
  x = 69,
  y = 56
}, {
  mask = 11,
  prototype = "砖石公路-X型",
  x = 69,
  y = 60
}, {
  mask = 15,
  prototype = "砖石公路-X型",
  x = 61,
  y = 62
}, {
  mask = 10,
  prototype = "砖石公路-X型",
  x = 69,
  y = 58
}, {
  mask = 13,
  prototype = "砖石公路-X型",
  x = 60,
  y = 62
}, {
  mask = 11,
  prototype = "砖石公路-X型",
  x = 69,
  y = 55
}, {
  mask = 4,
  prototype = "砖石公路-X型",
  x = 58,
  y = 62
}, {
  mask = 5,
  prototype = "砖石公路-X型",
  x = 59,
  y = 62
}, {
  mask = 10,
  prototype = "砖石公路-X型",
  x = 69,
  y = 57
}, {
  mask = 10,
  prototype = "砖石公路-X型",
  x = 69,
  y = 61
}, {
  mask = 11,
  prototype = "砖石公路-X型",
  x = 69,
  y = 59
}, {
  mask = 11,
  prototype = "砖石公路-X型",
  x = 69,
  y = 54
}, {
  mask = 10,
  prototype = "砖石公路-X型",
  x = 69,
  y = 53
}, {
  mask = 8,
  prototype = "砖石公路-X型",
  x = 69,
  y = 52
} }
local mineral = {
["100,60"] = "铁矿石",
["113,127"] = "碎石",
["136,172"] = "铁矿石",
["142,84"] = "碎石",
["143,147"] = "碎石",
["148,93"] = "铁矿石",
["162,127"] = "铁矿石",
["168,110"] = "碎石",
["171,74"] = "铁矿石",
["178,191"] = "铁矿石",
["190,130"] = "碎石",
["194,115"] = "铁矿石",
["207,160"] = "铁矿石",
["59,116"] = "铁矿石",
["60,183"] = "铁矿石",
["70,130"] = "碎石",
["73,91"] = "铁矿石",
["89,156"] = "铁矿石",
["91,100"] = "碎石"
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
  