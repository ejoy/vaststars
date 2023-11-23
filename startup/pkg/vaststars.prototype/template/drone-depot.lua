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
    items = { { "收货车站", 2 }, { "出货车站", 2 }, { "熔炼炉I", 2 }, { "无人机平台I", 5 }, { "水电站I", 2 } },
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
    items = { { "风力发电机I", 1 }, { "蓄电池I", 10 }, { "运输车辆I", 100 }, { "太阳能板I", 6 }, { "蒸汽发电机I", 8 }, { "锅炉I", 4 }, {"地质科技包",50}},
    prototype_name = "机翼残骸",
    x = 133,
    y = 122
  }, {
    dir = "W",
    items = { { "化工厂I", 3 }, { "地下水挖掘机I", 4 }, { "电解厂I", 1 }, { "空气过滤器I", 4 } },
    prototype_name = "机头残骸",
    x = 125,
    y = 108
  },{
    dir = "N",
    items = {"地质科技包"},
    prototype_name = "无人机平台I",
    x = 130,
    y = 123
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
    items = {"碎石"},
    prototype_name = "无人机平台I",
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
    items = {"石砖"},
    prototype_name = "无人机平台I",
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
    items = {"铁矿石"},
    prototype_name = "无人机平台I",
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
    items = {"铁板"},
    prototype_name = "无人机平台I",
    x = 155,
    y = 127
  },{
    dir = "N",
    items = {"碎石"},
    prototype_name = "无人机平台I",
    x = 121,
    y = 136
  }, {
    dir = "N",
    items = {"铁板"},
    prototype_name = "无人机平台I",
    x = 125,
    y = 136
  }, {
    dir = "N",
    items = {"石砖"},
    prototype_name = "无人机平台I",
    x = 129,
    y = 136
  },  {
    dir = "N",
    items = {"粉碎机框架"},
    prototype_name = "无人机平台I",
    x = 133,
    y = 136
  }, {
    dir = "N",
    items = {"无人机平台I"},
    prototype_name = "无人机平台I",
    x = 117,
    y = 136
  },{
    dir = "N",
    items = {"碎石","铁板"},
    prototype_name = "无人机平台II",
    x = 125,
    y = 143
  },{
    dir = "N",
    items = {"碎石","碎石"},
    prototype_name = "无人机平台II",
    x = 125,
    y = 146
  },{
    dir = "W",
    items = { { "碎石", 100 }},
    prototype_name = "机翼残骸",
    x = 121,
    y = 144
  }, {
    dir = "E",
    items = { { "铁板", 100 }},
    prototype_name = "机翼残骸",
    x = 128,
    y = 144
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 125,
    y = 140
  }, }
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
    name = "无人机测试",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 3,
    guide = guide,
    show = false,
    start_tech = "迫降火星",
    init_ui = {
      "/pkg/vaststars.resources/ui/construct.rml",
      "/pkg/vaststars.resources/ui/message_pop.rml"
    },
    init_instances = {
    },
    game_settings = {
      skip_guide = true,
      recipe_unlocked = true,
      item_unlocked = true,
      infinite_item = true,
    },
    camera = "/pkg/vaststars.resources/camera_default.prefab",
}