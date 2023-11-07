local guide = require "guide"
local mountain = require "mountain"

local entities = { {
    dir = "N",
    prototype_name = "指挥中心",
    amount = 0,
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
    items = { { "风力发电机I", 1 }, { "蓄电池I", 10 }, { "运输车辆I", 100 }, { "太阳能板I", 6 }, { "蒸汽发电机I", 8 }, { "锅炉I", 4 } },
    prototype_name = "机翼残骸",
    x = 133,
    y = 122
  }, {
    dir = "W",
    items = { { "化工厂I", 3 }, { "地下水挖掘机I", 4 }, { "电解厂I", 1 }, { "空气过滤器I", 4 } },
    prototype_name = "机头残骸",
    x = 125,
    y = 108
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 119,
    y = 121
  }, {
    dir = "N",
    fluid_name = {
      input = {},
      output = { "地下卤水" }
    },
    prototype_name = "地下水挖掘机I",
    recipe = "离岸抽水",
    x = 119,
    y = 126
  }, {
    dir = "N",
    fluid_name = {
      input = {},
      output = { "地下卤水" }
    },
    prototype_name = "地下水挖掘机I",
    recipe = "离岸抽水",
    x = 119,
    y = 130
  }, {
    dir = "N",
    fluid_name = {
      input = {},
      output = { "地下卤水" }
    },
    prototype_name = "地下水挖掘机I",
    recipe = "离岸抽水",
    x = 119,
    y = 134
  }, {
    dir = "N",
    fluid_name = {
      input = {},
      output = { "地下卤水" }
    },
    prototype_name = "地下水挖掘机I",
    recipe = "离岸抽水",
    x = 119,
    y = 138
  }, {
    dir = "N",
    fluid_name = {
      input = {},
      output = { "地下卤水" }
    },
    prototype_name = "地下水挖掘机I",
    recipe = "离岸抽水",
    x = 119,
    y = 142
  }, {
    dir = "N",
    fluid_name = {
      input = {},
      output = { "地下卤水" }
    },
    prototype_name = "地下水挖掘机I",
    recipe = "离岸抽水",
    x = 119,
    y = 146
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 133,
    y = 126
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 133,
    y = 130
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 133,
    y = 134
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 133,
    y = 138
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 133,
    y = 142
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 128,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 129,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 130,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 131,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 132,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 122,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 123,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 124,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 125,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 126,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 127,
    y = 127
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 122,
    y = 131
  }, {
    dir = "W",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 132,
    y = 131
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 122,
    y = 134
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 125,
    y = 134
  }, {
    dir = "N",
    fluid_name = "地下卤水",
    prototype_name = "液罐I",
    x = 130,
    y = 134
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 129,
    y = 135
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 128,
    y = 135
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 123,
    y = 139
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 124,
    y = 139
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 122,
    y = 139
  }, {
    dir = "W",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 132,
    y = 139
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 126,
    y = 139
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 125,
    y = 139
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 122,
    y = 143
  }, {
    dir = "W",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 132,
    y = 143
  }, {
    dir = "W",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 124,
    y = 143
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 125,
    y = 143
  }, {
    dir = "W",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 128,
    y = 143
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "地下管1-JI型",
    x = 129,
    y = 143
  }, {
    dir = "N",
    fluid_name = {
      input = { "地下卤水" },
      output = { "蒸汽" }
    },
    prototype_name = "锅炉I",
    recipe = "卤水沸腾",
    x = 133,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 123,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 124,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 125,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 126,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 127,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 128,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 129,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 130,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 131,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 132,
    y = 147
  }, {
    dir = "E",
    fluid_name = "地下卤水",
    prototype_name = "管道1-I型",
    x = 122,
    y = 147
  }, {
    dir = "N",
    fluid_name = {
      input = { "蒸汽" },
      output = {}
    },
    prototype_name = "蒸汽发电机I",
    recipe = "蒸汽发电",
    x = 133,
    y = 149
  }, {
    dir = "N",
    fluid_name = {
      input = { "蒸汽" },
      output = {}
    },
    prototype_name = "蒸汽发电机I",
    recipe = "蒸汽发电",
    x = 133,
    y = 154
  }, {
    dir = "E",
    fluid_name = "",
    prototype_name = "排水口I",
    x = 136,
    y = 134
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
    name = "管道测试",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 5,
    guide = guide,
    mode = "free",
    show = false,
    start_tech = "迫降火星",
    init_ui = {
      "/pkg/vaststars.resources/ui/construct.rml",
      "/pkg/vaststars.resources/ui/message_pop.rml"
    },
}