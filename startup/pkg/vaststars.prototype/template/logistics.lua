local entities = { {
    dir = "N",
    items = {},
    prototype_name = "指挥中心",
    recipe = "车辆装配",
    x = 126,
    y = 120
  }, {
    dir = "N",
    items = { { "水电站I", 2 }, { "铁制电线杆", 10 }, { "收货车站", 2 }, { "送货车站", 2 }, { "熔炼炉I", 2 }, { "无人机仓库I", 5 } },
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
    items = { { "风力发电机I", 1 }, { "蓄电池I", 10 }, { "锅炉I", 4 }, { "蒸汽发电机I", 8 }, { "太阳能板I", 6 } },
    prototype_name = "机翼残骸",
    x = 133,
    y = 122
  }, {
    dir = "W",
    items = { { "电解厂I", 1 }, { "空气过滤器I", 4 }, { "地下水挖掘机", 4 }, { "化工厂I", 3 } },
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
    prototype_name = "铁制电线杆",
    x = 120,
    y = 119
  }, {
    dir = "N",
    prototype_name = "铁制电线杆",
    x = 128,
    y = 119
  }, {
    dir = "N",
    item = "碎石",
    prototype_name = "无人机仓库I",
    x = 117,
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
  }, }
local road = {
  [28298] = 8,
  [28554] = 10,
  [28810] = 14,
  [28811] = 73,
  [29066] = 14,
  [29067] = 115,
  [29322] = 10,
  [29578] = 10,
  [29834] = 14,
  [29835] = 73,
  [30090] = 14,
  [30091] = 115,
  [30346] = 10,
  [30602] = 10,
  [30858] = 10,
  [31114] = 10,
  [31370] = 10,
  [31626] = 10,
  [31862] = 76,
  [31863] = 121,
  [31870] = 76,
  [31871] = 121,
  [31882] = 10,
  [31901] = 76,
  [31902] = 121,
  [32116] = 4,
  [32117] = 5,
  [32118] = 7,
  [32119] = 7,
  [32120] = 5,
  [32121] = 5,
  [32122] = 5,
  [32123] = 5,
  [32124] = 5,
  [32125] = 5,
  [32126] = 7,
  [32127] = 7,
  [32128] = 5,
  [32129] = 5,
  [32130] = 5,
  [32131] = 5,
  [32132] = 5,
  [32133] = 5,
  [32134] = 5,
  [32135] = 5,
  [32136] = 5,
  [32137] = 5,
  [32138] = 7,
  [32139] = 5,
  [32140] = 5,
  [32141] = 5,
  [32142] = 5,
  [32143] = 5,
  [32144] = 5,
  [32145] = 5,
  [32146] = 5,
  [32147] = 5,
  [32148] = 5,
  [32149] = 5,
  [32150] = 5,
  [32151] = 5,
  [32152] = 5,
  [32153] = 5,
  [32154] = 5,
  [32155] = 5,
  [32156] = 5,
  [32157] = 7,
  [32158] = 7,
  [32159] = 1
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
  world:container_set(e.chest, idx, {amount = 25, limit = 25})
end

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
    name = "路网测试",
    entities = entities,
    road = road,
    prepare = prepare,
    mineral = mineral,
}