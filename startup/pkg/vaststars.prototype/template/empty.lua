local guide = require "guide"
local mountain = require "mountain"

local items = {}
for _ = 1, 16 do
  items[#items+1] = {"", 0}
end

local entities = { {
    dir = "N",
    items = items,
    prototype_name = "指挥中心",
    x = 124,
    y = 120
  }, {
    dir = "N",
    items = { { "水电站I", 2 }, { "收货车站", 2 }, { "出货车站", 2 }, { "熔炼炉I", 2 }, { "无人机平台I", 5 } },
    prototype_name = "机身残骸",
    x = 107,
    y = 134
  }, {
    dir = "S",
    items = { { "无人机平台I", 4 }, { "采矿机I", 2 }, { "科研中心I", 1 }, { "组装机I", 4 } },
    prototype_name = "机尾残骸",
    x = 110,
    y = 120
  }, {
    dir = "S",
    items = { { "风力发电机I", 1 }, { "锅炉I", 4 }, { "蓄电池I", 10 }, { "运输车辆I", 100 }, { "太阳能板I", 6 }, { "蒸汽发电机I", 8 } },
    prototype_name = "机翼残骸",
    x = 133,
    y = 122
  }, {
    dir = "W",
    items = { { "化工厂I", 3 }, { "空气过滤器I", 4 }, { "地下水挖掘机I", 4 }, { "电解厂I", 1 } },
    prototype_name = "机头残骸",
    x = 125,
    y = 108
  } }
local road = {}

local mineral = {
  ["138,174"] = "铁矿石",
  ["102,62"] = "铁矿石",
  ["164,129"] = "铁矿石",
  ["91,158"] = "铁矿石",
  ["62,185"] = "铁矿石",
  ["61,118"] = "铁矿石",
  ["75,93"] = "铁矿石",
  ["173,76"] = "铁矿石",
  ["196,117"] = "铁矿石",
  ["209,162"] = "铁矿石",
  ["180,193"] = "铁矿石",
  ["150,95"] = "铁矿石",
  ["170,112"] = "碎石",
  ["144,86"] = "碎石",
  ["115,129"] = "碎石",
  ["72,132"] = "碎石",
  ["93,102"] = "碎石",
  ["145,149"] = "碎石",
  ["192,132"] = "碎石",
}

return {
  name = "纯净模式",
  entities = entities,
  road = road,
  mineral = mineral,
  mountain = mountain,
  order = 1,
  guide = guide,
  show = false,
  start_tech = "迫降火星",
  init_ui = {
    "/pkg/vaststars.resources/ui/construct.rml",
    "/pkg/vaststars.resources/ui/message_pop.rml"
  },
  init_instances = {
  },
  debugger = {
    skip_guide = true,
    recipe_unlocked = true,
    item_unlocked = true,
    infinite_item = true,
  },
  camera = "/pkg/vaststars.resources/camera_default.prefab",
}