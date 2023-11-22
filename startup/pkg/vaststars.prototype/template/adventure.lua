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
},{
  dir = "E",
  amount = 0,
  prototype_name = "物流中心",
  x = 138,
  y = 126
}, {
  dir = "N",
  items = { { "无人机平台I", 8 } , { "风力发电机I", 1 }, { "采矿机I", 4 }, { "仓库I", 8 } ,},
  prototype_name = "机身残骸",
  x = 123,
  y = 130
},{
  dir = "E",
  items = { { "地下水挖掘机框架", 6},{ "空气过滤器框架", 4},{ "水电站框架", 2}, },
  prototype_name = "机尾残骸",
  x = 118,
  y = 114
}, {
  dir = "S",
  items = {  { "破损运输车辆", 16}, { "物流站框架", 6 }, {"停车站框架",2}},
  prototype_name = "机尾残骸",
  x = 133,
  y = 123
}, {
  dir = "S",
  items = { { "太阳能板框架", 6},{ "蓄电池I", 10 }, { "锅炉I", 4 }, { "蒸汽发电机框架", 4 } },
  prototype_name = "机翼残骸",
  x = 105,
  y = 111
}, {
  dir = "W",
  items = {{ "科研中心I", 2 },{ "组装机I", 8 },{ "熔炼炉I", 2 }},
  prototype_name = "机翼残骸",
  x = 143,
  y = 145
}, {
  dir = "E",
  items = { { "无人机平台框架", 6 },{ "太阳能板I", 2 } },
  prototype_name = "机头残骸",
  x = 120,
  y = 145
}, {
  dir = "N",
  items = { { "组装机框架", 6 },{ "电解厂框架", 2 }, { "蒸馏厂框架", 2 },{ "化工厂框架", 3}},
  prototype_name = "机头残骸",
  x = 136,
  y = 105
},
-- {
--   dir = "N",
--   prototype_name = "采矿机I",
--   recipe = "碎石挖掘",
--   x = 115,
--   y = 133
-- },
}
local road = {}

local mineral = {
  --9个碎石矿
  ["115,133"] = "碎石",
  ["144,86"] = "碎石",
  ["150,112"] = "碎石",
  ["192,132"] = "碎石",
  ["72,132"] = "碎石",
  ["93,102"] = "碎石",
  ["108,31"] = "碎石",
  ["62,167"] = "碎石",
  ["72,74"] = "碎石",
  ------------------------
  --19个铁矿
  ["75,93"] = "铁矿石",
  ["91,165"] = "铁矿石",
  ["138,174"] = "铁矿石",
  ["150,95"] = "铁矿石",
  ["138,140"] = "铁矿石",
  ["173,76"] = "铁矿石",
  ["180,193"] = "铁矿石",
  ["197,117"] = "铁矿石",
  ["209,162"] = "铁矿石",
  ["61,118"] = "铁矿石",
  ["62,185"] = "铁矿石",
  ["114,81"] = "铁矿石",
  ["58,19"] = "铁矿石",
  ["31,167"] = "铁矿石",
  ["42,205"] = "铁矿石",
  ["182,234"] = "铁矿石",
  ["226,241"] = "铁矿石",
  ["28,139"] = "铁矿石",
  ["66,147"] = "铁矿石",
  ------------------------
  --8个铝矿
  ["102,62"] = "铝矿石",
  ["166,159"] = "铝矿石",
  ["151,33"] = "铝矿石",
  ["103,190"] = "铝矿石",
  ["175,208"] = "铝矿石",
  ["216,189"] = "铝矿石",
  ["33,30"] = "铝矿石",
  ["145,149"] = "铝矿石",
  -----------------------
  --6个地热
  ["210,142"] = "地热气",
  ["93,203"] = "地热气",
  ["46,153"] = "地热气",
  ["129,70"] = "地热气",
  ["220,77"] = "地热气",
  ["229,223"] = "地热气",
}

return {
  name = "默认模板",
  entities = entities,
  road = road,
  mineral = mineral,
  mountain = mountain,
  show = false,
  guide = guide,
  start_tech = "迫降火星",
  init_ui = {
    "/pkg/vaststars.resources/ui/construct.rml",
    "/pkg/vaststars.resources/ui/message_pop.rml"
  },
  init_instances = {
  },
  debugger = {
    skip_guide = false,
    recipe_unlocked = false,
    item_unlocked = false,
    infinite_item = false,
  },
  camera = "/pkg/vaststars.resources/camera_default.prefab",
}
