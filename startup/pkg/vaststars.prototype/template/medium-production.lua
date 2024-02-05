local guide = require "guide"
local mountain = require "mountain"

local items = {}
for _ = 1, 16 do
  items[#items+1] = {"", 0}
end

local entities = { {
  amount = 0,
  dir = "N",
  items = items,
  prototype_name = "指挥中心",
  x = 124,
  y = 120
}, {
  dir = "W",
  amount = 50,
  prototype_name = "物流中心",
  x = 152,
  y = 142
},  {
  dir = "N",
  items = { { "铁矿石", 0 } },
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 138,
  y = 140
}, {
  dir = "N",
  items = { { "铝矿石", 0 } },
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 145,
  y = 149
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 120,
  y = 120
}, {
  dir = "N",
  items = { { "铁矿石", 60 }, { "铝矿石", 60 }, { "碎石", 59 }, { "铁板", 30 } },
  prototype_name = "仓库I",
  x = 121,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 119,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 134
}, {
  dir = "N",
  items = { { "铁矿石", 0 }, { "铝矿石", 0 } },
  prototype_name = "仓库I",
  x = 144,
  y = 146
}, {
  dir = "N",
  items = { { "铁板", 8 }, { "铁棒", 9 } },
  prototype_name = "组装机I",
  recipe = "铁棒1",
  x = 118,
  y = 130
}, {
  dir = "N",
  items = { { "碎石", 4 }, { "铁矿石", 4 }, { "铝矿石", 4 }, { "地质科技包", 2 } },
  prototype_name = "组装机I",
  recipe = "地质科技包1",
  x = 122,
  y = 130
}, {
  dir = "N",
  items = { { "碎石", 4 }, { "石砖", 2 } },
  prototype_name = "组装机I",
  recipe = "石砖",
  x = 118,
  y = 135
}, {
  dir = "N",
  items = { { "电动机I", 2 }, { "铁齿轮", 6 }, { "机械科技包", 2 }, { "石砖", 0 }, { "管道1-X型", 10 } },
  prototype_name = "组装机I",
  recipe = "机械科技包T1",
  x = 122,
  y = 135
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 6 }, { "石墨", 2 }, { "铁板", 0 }, { "碎石", 0 }, { "铁矿石", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板2",
  x = 115,
  y = 130
}, {
  dir = "N",
  items = { { "地质科技包", 3 }, { "气候科技包", 2 }, { "机械科技包", 3 }, { "电子科技包", 2 }, { "化学科技包", 2 }, { "物理科技包", 1 } },
  prototype_name = "科研中心I",
  x = 125,
  y = 133
}, {
  dir = "N",
  items = { { "石砖", 30 }, { "机械科技包", 30 }, { "地质科技包", 30 }, { "铁棒", 30 } },
  prototype_name = "仓库I",
  x = 121,
  y = 134
}, {
  dir = "N",
  items = { { "地质科技包", 3 }, { "气候科技包", 2 }, { "机械科技包", 3 }, { "电子科技包", 2 }, { "化学科技包", 2 }, { "物理科技包", 1 } },
  prototype_name = "科研中心I",
  x = 125,
  y = 130
}, {
  dir = "N",
  items = { { "supply", "铁矿石", 2 }, { "supply", "铝矿石", 2 } },
  prototype_name = "物流站",
  x = 138,
  y = 148
}, {
  dir = "S",
  items = { { "demand", "铝矿石", 2 }, { "demand", "铁板", 1 }, { "supply", "碎石", 2 }, { "demand", "铁矿石", 1 }, { "demand", "电子科技包", 1 }, { "demand", "化学科技包", 1 } },
  prototype_name = "物流站",
  x = 120,
  y = 128
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 7 }, { "石墨", 2 }, { "铁板", 0 }, { "碎石", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板2",
  x = 107,
  y = 130
}, {
  dir = "N",
  items = { { "管道1-X型", 60 }, { "气候科技包", 30 }, { "地下管1-JI型", 1 }, { "液罐I", 1 } },
  prototype_name = "仓库I",
  x = 125,
  y = 136
}, {
  dir = "N",
  items = { { "铁矿石", 0 } },
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 150,
  y = 95
}, {
  dir = "W",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  items = { { "空气", 6000 }, { "地下卤水", 4000 }, { "气候科技包", 2 } },
  prototype_name = "水电站I",
  recipe = "气候科技包1",
  x = 129,
  y = 131
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 200 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 131,
  y = 128
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 200 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 129,
  y = 129
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 127,
  y = 136
}, {
  dir = "E",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  items = { { "空气", 6000 }, { "地下卤水", 4000 }, { "气候科技包", 2 } },
  prototype_name = "水电站I",
  recipe = "气候科技包1",
  x = 129,
  y = 136
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 200 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 129,
  y = 141
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 200 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 132,
  y = 141
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 59,
  y = 224
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 62,
  y = 224
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 65,
  y = 224
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 68,
  y = 224
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 56,
  y = 230
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 56,
  y = 227
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 65,
  y = 221
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 73,
  y = 230
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 59,
  y = 227
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 61,
  y = 227
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 227
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 227
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 227
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 63,
  y = 227
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 59,
  y = 229
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 61,
  y = 229
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 63,
  y = 229
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 229
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  items = { { "地下卤水", 90 }, { "氧气", 0 }, { "氢气", 0 }, { "氯气", 0 } },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 85,
  y = 142
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 134 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 90,
  y = 142
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "液罐I",
  x = 97,
  y = 144
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "液罐I",
  x = 66,
  y = 168
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "液罐I",
  x = 73,
  y = 158
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  items = { { "空气", 300 }, { "氮气", 0 }, { "二氧化碳", 61 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 85,
  y = 136
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 125 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 83,
  y = 137
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 94,
  y = 139
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "液罐I",
  x = 78,
  y = 131
}, {
  dir = "W",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "甲烷", "纯水" }
  },
  items = { { "二氧化碳", 64 }, { "氢气", 204 }, { "甲烷", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转甲烷",
  x = 85,
  y = 152
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  items = { { "地下卤水", 90 }, { "氧气", 0 }, { "氢气", 0 }, { "氯气", 0 } },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 85,
  y = 147
}, {
  dir = "E",
  fluid_name = {
    input = { "氧气", "甲烷" },
    output = { "乙烯", "纯水" }
  },
  items = { { "氧气", 80 }, { "甲烷", 80 }, { "乙烯", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "甲烷转乙烯",
  x = 85,
  y = 161
}, {
  dir = "W",
  fluid_name = {
    input = { "乙烯", "氯气" },
    output = { "盐酸" }
  },
  items = { { "乙烯", 60 }, { "氯气", 60 }, { "塑料", 2 }, { "盐酸", 0 } },
  prototype_name = "化工厂I",
  recipe = "塑料1",
  x = 107,
  y = 145
}, {
  dir = "N",
  items = { { "塑料", 15 }, { "塑料", 15 }, { "塑料", 15 }, { "塑料", 15 } },
  prototype_name = "仓库I",
  x = 115,
  y = 141
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 115,
  y = 139
}, {
  dir = "N",
  items = { { "铁齿轮", 4 }, { "塑料", 2 }, { "电动机I", 2 } },
  prototype_name = "组装机I",
  recipe = "电动机T1",
  x = 117,
  y = 139
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 138
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 138
}, {
  dir = "N",
  items = { { "铁齿轮", 30 }, { "铁齿轮", 30 }, { "电动机I", 15 }, { "采矿机I", 15 } },
  prototype_name = "仓库I",
  x = 121,
  y = 137
}, {
  dir = "N",
  items = { { "电动机I", 4 }, { "石砖", 8 }, { "无人机平台I", 2 } },
  prototype_name = "组装机I",
  recipe = "无人机平台1",
  x = 122,
  y = 139
}, {
  dir = "E",
  fluid_name = {
    input = { "乙烯", "蒸汽" },
    output = { "丁二烯", "氢气" }
  },
  items = { { "乙烯", 100 }, { "蒸汽", 73 }, { "丁二烯", 0 }, { "氢气", 0 } },
  prototype_name = "蒸馏厂I",
  recipe = "乙烯转丁二烯",
  x = 96,
  y = 158
}, {
  dir = "N",
  fluid_name = {
    input = { "氧气" },
    output = { "二氧化碳" }
  },
  items = { { "铁板", 2 }, { "氧气", 60 }, { "钢板", 2 }, { "二氧化碳", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "钢板1",
  x = 94,
  y = 129
}, {
  dir = "N",
  fluid_name = {
    input = { "氧气" },
    output = { "二氧化碳" }
  },
  items = { { "铁板", 2 }, { "氧气", 60 }, { "钢板", 1 }, { "二氧化碳", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "钢板1",
  x = 98,
  y = 129
}, {
  dir = "S",
  items = { { "supply", "钢板", 2 }, { "demand", "铁板", 4 } },
  prototype_name = "物流站",
  x = 96,
  y = 124
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 1 }, { "石墨", 2 }, { "铁板", 0 }, { "碎石", 0 }, { "铁矿石", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板2",
  x = 111,
  y = 130
}, {
  dir = "S",
  items = { { "demand", "铁矿石", 2 }, { "supply", "碎石", 2 }, { "supply", "铁板", 2 }, { "demand", "碾碎铁矿石", 1 }, { "demand", "石墨", 1 } },
  prototype_name = "物流站",
  x = 110,
  y = 128
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 114,
  y = 130
}, {
  dir = "N",
  items = { { "铁矿石", 2 } },
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 61,
  y = 118
}, {
  dir = "W",
  items = { { "supply", "铁矿石", 2 } },
  prototype_name = "物流站",
  x = 64,
  y = 118
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 63,
  y = 121
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 165 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 24,
  y = 225
}, {
  dir = "N",
  items = { { "碎石", 2 }, { "沙子", 0 } },
  prototype_name = "粉碎机I",
  recipe = "沙子1",
  x = 116,
  y = 149
}, {
  dir = "N",
  items = { { "碎石", 3 }, { "沙子", 0 } },
  prototype_name = "粉碎机I",
  recipe = "沙子1",
  x = 119,
  y = 149
}, {
  dir = "N",
  items = { { "铝矿石", 14 }, { "碾碎铝矿石", 7 }, { "碾碎铁矿石", 0 }, { "沙子", 0 } },
  prototype_name = "粉碎机I",
  recipe = "碾碎铝矿石",
  x = 125,
  y = 146
}, {
  dir = "S",
  items = { { "supply", "碾碎铝矿石", 3 }, { "demand", "铝矿石", 2 }, { "supply", "碾碎铁矿石", 1 }, { "demand", "碎石", 1 }, { "demand", "沙子", 1 } },
  prototype_name = "物流站",
  x = 120,
  y = 146
}, {
  dir = "N",
  items = { { "沙子", 40 }, { "沙子", 40 }, { "碾碎铝矿石", 60 }, { "碾碎铝矿石", 60 } },
  prototype_name = "仓库I",
  x = 121,
  y = 148
}, {
  dir = "N",
  items = { { "demand", "钢板", 4 }, { "supply", "钢齿轮", 4 } },
  prototype_name = "物流站",
  x = 96,
  y = 120
}, {
  dir = "N",
  items = { { "钢板", 6 }, { "钢齿轮", 4 } },
  prototype_name = "组装机I",
  recipe = "钢齿轮",
  x = 94,
  y = 117
}, {
  dir = "N",
  items = { { "钢板", 6 }, { "钢齿轮", 4 } },
  prototype_name = "组装机I",
  recipe = "钢齿轮",
  x = 99,
  y = 117
}, {
  dir = "N",
  items = { { "钢齿轮", 30 }, { "钢齿轮", 30 } },
  prototype_name = "仓库I",
  x = 98,
  y = 118
}, {
  dir = "N",
  items = { { "铁板", 4 }, { "铁棒", 2 }, { "铁齿轮", 4 } },
  prototype_name = "组装机I",
  recipe = "铁齿轮",
  x = 115,
  y = 136
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 119,
  y = 138
}, {
  dir = "N",
  items = { { "碎石", 1 } },
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 115,
  y = 133
}, {
  dir = "N",
  fluid_name = "",
  items = {},
  prototype_name = "组装机I",
  x = 125,
  y = 137
}, {
  dir = "N",
  items = { { "铁矿石", 2 } },
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 91,
  y = 165
}, {
  dir = "N",
  items = { { "碎石", 2 } },
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 93,
  y = 102
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "废水" }
  },
  items = { { "地下卤水", 120 }, { "沙子", 16 }, { "废水", 0 }, { "硅", 6 } },
  prototype_name = "浮选器I",
  recipe = "硅1",
  x = 117,
  y = 153
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "废水" }
  },
  items = { { "地下卤水", 120 }, { "沙子", 16 }, { "废水", 0 }, { "硅", 7 } },
  prototype_name = "浮选器I",
  recipe = "硅1",
  x = 122,
  y = 153
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 153 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 126,
  y = 153
}, {
  dir = "N",
  items = { { "硅", 30 }, { "硅", 30 }, { "坩埚", 15 }, { "坩埚", 15 } },
  prototype_name = "仓库I",
  x = 124,
  y = 158
}, {
  dir = "N",
  items = { { "硅", 30 }, { "坩埚", 2 } },
  prototype_name = "组装机I",
  recipe = "坩埚",
  x = 118,
  y = 158
}, {
  dir = "N",
  items = { { "supply", "硅", 2 }, { "supply", "玻璃", 2 } },
  prototype_name = "物流站",
  x = 122,
  y = 160
}, {
  dir = "N",
  items = { { "碎石", 2 } },
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 72,
  y = 132
}, {
  dir = "W",
  items = { { "supply", "碎石", 2 } },
  prototype_name = "物流站",
  x = 74,
  y = 128
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 73,
  y = 131
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 152
}, {
  dir = "N",
  fluid_name = "蒸汽",
  prototype_name = "液罐I",
  x = 105,
  y = 163
}, {
  dir = "S",
  fluid_name = "蒸汽",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 162
}, {
  dir = "S",
  fluid_name = "蒸汽",
  prototype_name = "管道1-L型",
  x = 101,
  y = 161
}, {
  dir = "N",
  fluid_name = "蒸汽",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 163
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 103,
  y = 164
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 104,
  y = 164
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 102,
  y = 164
}, {
  dir = "N",
  fluid_name = "丁二烯",
  prototype_name = "液罐I",
  x = 94,
  y = 170
}, {
  dir = "N",
  items = { { "碎石", 2 } },
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 150,
  y = 112
}, {
  dir = "W",
  items = { { "supply", "碎石", 2 } },
  prototype_name = "物流站",
  x = 152,
  y = 116
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 151,
  y = 116
}, {
  dir = "W",
  fluid_name = {
    input = { "一氧化碳", "氢气" },
    output = { "纯水" }
  },
  items = { { "一氧化碳", 56 }, { "氢气", 35 }, { "石墨", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "一氧化碳转石墨",
  x = 85,
  y = 169
}, {
  dir = "N",
  items = { { "硅", 6 }, { "玻璃", 2 } },
  prototype_name = "组装机I",
  recipe = "玻璃1",
  x = 128,
  y = 158
}, {
  dir = "S",
  items = { { "demand", "石墨", 2 }, { "demand", "硅", 2 }, { "demand", "电容I", 1 }, { "demand", "绝缘线", 1 }, { "demand", "铝丝", 1 }, { "supply", "逻辑电路", 1 } },
  prototype_name = "物流站",
  x = 122,
  y = 164
}, {
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "一氧化碳", "纯水" }
  },
  items = { { "二氧化碳", 80 }, { "氢气", 32 }, { "一氧化碳", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转一氧化碳",
  x = 76,
  y = 165
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 155
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 164
}, {
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "一氧化碳", "纯水" }
  },
  items = { { "二氧化碳", 80 }, { "氢气", 2 }, { "一氧化碳", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转一氧化碳",
  x = 76,
  y = 169
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 79,
  y = 167
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 170
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 168
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 84,
  y = 147
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 84,
  y = 142
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 84,
  y = 145
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 146
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 149
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 84,
  y = 150
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 84,
  y = 151
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 89,
  y = 145
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 89,
  y = 150
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 90,
  y = 150
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 146
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 149
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 166
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 80,
  y = 167
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 163
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 151
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 76,
  y = 151
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 75,
  y = 168
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 75,
  y = 170
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-I型",
  x = 75,
  y = 165
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-I型",
  x = 75,
  y = 169
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 166
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 168
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-L型",
  x = 74,
  y = 165
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "液罐I",
  x = 73,
  y = 179
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-T型",
  x = 74,
  y = 169
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 178
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 170
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 88,
  y = 171
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 180
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 180
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  items = { { "空气", 300 }, { "氮气", 0 }, { "二氧化碳", 55 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 85,
  y = 130
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 200 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 83,
  y = 133
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 150 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 83,
  y = 125
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 92,
  y = 133
}, {
  dir = "N",
  items = { { "supply", "铁矿石", 1 }, { "supply", "石墨", 4 } },
  prototype_name = "物流站",
  x = 90,
  y = 172
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 89,
  y = 170
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 93,
  y = 170
}, {
  dir = "N",
  items = { { "铁矿石", 60 }, { "铁矿石", 60 }, { "石墨", 0 }, { "石墨", 0 } },
  prototype_name = "仓库I",
  x = 91,
  y = 170
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 89,
  y = 169
}, {
  dir = "N",
  items = { { "硅", 10 }, { "石墨", 4 }, { "硅板", 4 } },
  prototype_name = "熔炼炉I",
  recipe = "硅板1",
  x = 121,
  y = 167
}, {
  dir = "N",
  items = { { "硅", 10 }, { "石墨", 4 }, { "硅板", 5 } },
  prototype_name = "熔炼炉I",
  recipe = "硅板1",
  x = 124,
  y = 167
}, {
  dir = "N",
  items = { { "铝矿石", 14 }, { "碾碎铝矿石", 6 }, { "碾碎铁矿石", 0 }, { "沙子", 0 } },
  prototype_name = "粉碎机I",
  recipe = "碾碎铝矿石",
  x = 125,
  y = 150
}, {
  dir = "N",
  items = { { "硅板", 30 }, { "硅板", 30 }, { "石墨", 30 }, { "逻辑电路", 15 } },
  prototype_name = "仓库I",
  x = 123,
  y = 166
}, {
  dir = "N",
  items = { { "铝矿石", 0 } },
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 166,
  y = 159
}, {
  dir = "N",
  items = { { "supply", "铝矿石", 2 } },
  prototype_name = "物流站",
  x = 162,
  y = 160
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 165,
  y = 159
}, {
  dir = "N",
  items = { { "铝矿石", 1 } },
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 103,
  y = 190
}, {
  dir = "W",
  items = { { "supply", "铝矿石", 2 } },
  prototype_name = "物流站",
  x = 104,
  y = 186
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 103,
  y = 189
}, {
  dir = "S",
  items = { { "demand", "碾碎铝矿石", 8 } },
  prototype_name = "物流站",
  x = 148,
  y = 164
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 127,
  y = 156
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 126,
  y = 157
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 127,
  y = 157
}, {
  dir = "N",
  items = { { "demand", "玻璃", 1 }, { "demand", "钢板", 1 }, { "supply", "塑料", 4 }, { "supply", "无人机平台I", 1 } },
  prototype_name = "物流站",
  x = 120,
  y = 142
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 140
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氯气" }
  },
  items = { { "地下卤水", 80 }, { "氯气", 0 }, { "氢氧化钠", 2 } },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解2",
  x = 93,
  y = 149
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 148
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 158
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 159
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 147
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 92,
  y = 148
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 147
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 92,
  y = 147
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 92,
  y = 152
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 92,
  y = 151
}, {
  dir = "S",
  items = { { "supply", "氢氧化钠", 2 } },
  prototype_name = "物流站",
  x = 100,
  y = 152
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 98,
  y = 152
}, {
  dir = "N",
  items = { { "沙子", 40 }, { "沙子", 40 }, { "沙子", 41 }, { "沙子", 40 } },
  prototype_name = "仓库I",
  x = 124,
  y = 152
}, {
  dir = "S",
  fluid_name = {
    input = { "纯水" },
    output = { "碱性溶液" }
  },
  items = { { "纯水", 160 }, { "氢氧化钠", 1 }, { "碱性溶液", 0 } },
  prototype_name = "水电站I",
  recipe = "碱性溶液",
  x = 88,
  y = 179
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 87,
  y = 173
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 87,
  y = 181
}, {
  dir = "S",
  items = { { "demand", "氢氧化钠", 2 }, { "supply", "钠", 3 } },
  prototype_name = "物流站",
  x = 94,
  y = 176
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 103,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 104,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 93,
  y = 182
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 114,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 182
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "液罐I",
  x = 148,
  y = 181
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 147,
  y = 182
}, {
  dir = "N",
  items = { { "氢氧化钠", 0 }, { "氢氧化钠", 0 }, { "氢氧化钠", 0 }, { "氢氧化钠", 0 } },
  prototype_name = "仓库I",
  x = 92,
  y = 178
}, {
  dir = "S",
  fluid_name = {
    input = { "碱性溶液" },
    output = { "废水" }
  },
  items = { { "碾碎铝矿石", 5 }, { "碱性溶液", 7 }, { "氢氧化铝", 0 }, { "废水", 0 } },
  prototype_name = "浮选器I",
  recipe = "铝矿石浮选",
  x = 145,
  y = 167
}, {
  dir = "S",
  fluid_name = {
    input = { "碱性溶液" },
    output = { "废水" }
  },
  items = { { "碾碎铝矿石", 8 }, { "碱性溶液", 20 }, { "氢氧化铝", 0 }, { "废水", 0 } },
  prototype_name = "浮选器I",
  recipe = "铝矿石浮选",
  x = 152,
  y = 167
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 149,
  y = 167
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 151,
  y = 167
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 149,
  y = 180
}, {
  dir = "S",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 149,
  y = 172
}, {
  dir = "N",
  items = { { "氢氧化铝", 2 }, { "氧化铝", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "氧化铝",
  x = 145,
  y = 172
}, {
  dir = "N",
  items = { { "氢氧化铝", 3 }, { "氧化铝", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "氧化铝",
  x = 154,
  y = 172
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 148,
  y = 172
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 153,
  y = 172
}, {
  dir = "E",
  items = { { "氧化铝", 6 }, { "石墨", 5 }, { "铝板", 0 }, { "碳化铝", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铝板1",
  x = 148,
  y = 173
}, {
  dir = "N",
  items = { { "氧化铝", 0 }, { "石墨", 5 }, { "铝板", 0 }, { "碳化铝", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铝板1",
  x = 151,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = { "纯水" },
    output = { "甲烷" }
  },
  items = { { "碳化铝", 2 }, { "纯水", 120 }, { "氢氧化铝", 2 }, { "甲烷", 0 } },
  prototype_name = "化工厂I",
  recipe = "氢氧化铝",
  x = 142,
  y = 172
}, {
  dir = "S",
  fluid_name = {
    input = { "纯水" },
    output = { "甲烷" }
  },
  items = { { "碳化铝", 4 }, { "纯水", 120 }, { "氢氧化铝", 0 }, { "甲烷", 0 } },
  prototype_name = "化工厂I",
  recipe = "氢氧化铝",
  x = 157,
  y = 172
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 87,
  y = 182
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 184
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 121,
  y = 184
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 146,
  y = 175
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 144,
  y = 176
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 144,
  y = 183
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 144,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 145,
  y = 175
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 144,
  y = 175
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 156,
  y = 175
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 155,
  y = 175
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 159,
  y = 175
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 175
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 157,
  y = 175
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 170
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 105,
  y = 170
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 170
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 97,
  y = 170
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 169
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 164
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 96,
  y = 163
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 97,
  y = 163
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 159,
  y = 171
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 170
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 159,
  y = 170
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 144,
  y = 171
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 170
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 149,
  y = 170
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 144,
  y = 170
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 143,
  y = 171
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 142,
  y = 170
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
  x = 143,
  y = 170
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 170
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 135,
  y = 170
}, {
  dir = "N",
  items = { { "supply", "铝板", 4 }, { "demand", "石墨", 2 }, { "supply", "氧化铝", 2 } },
  prototype_name = "物流站",
  x = 150,
  y = 176
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 149,
  y = 176
}, {
  dir = "E",
  items = { { "demand", "铝板", 2 }, { "demand", "钢齿轮", 1 }, { "demand", "氧化铝", 1 }, { "demand", "石墨", 1 }, { "demand", "塑料", 1 }, { "supply", "铝丝", 1 }, { "demand", "硅板", 1 } },
  prototype_name = "物流站",
  x = 164,
  y = 168
}, {
  dir = "N",
  items = { { "铝棒", 10 }, { "铝丝", 14 } },
  prototype_name = "组装机I",
  recipe = "铝丝1",
  x = 166,
  y = 174
}, {
  dir = "N",
  items = { { "铝板", 8 }, { "铝棒", 9 } },
  prototype_name = "组装机I",
  recipe = "铝棒1",
  x = 166,
  y = 164
}, {
  dir = "N",
  items = { { "铝丝", 30 }, { "铝丝", 30 }, { "铝棒", 15 }, { "铝棒", 15 } },
  prototype_name = "仓库I",
  x = 169,
  y = 169
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "纯水", "废水" }
  },
  items = { { "地下卤水", 0 }, { "纯水", 0 }, { "废水", 0 } },
  prototype_name = "化工厂I",
  recipe = "地下卤水净化",
  x = 144,
  y = 186
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 143,
  y = 185
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 143,
  y = 186
}, {
  dir = "N",
  items = { { "石墨", 2 }, { "氧化铝", 2 }, { "塑料", 6 }, { "铝板", 4 }, { "电容I", 4 } },
  prototype_name = "组装机I",
  recipe = "电容1",
  x = 169,
  y = 166
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 125,
  y = 158
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 122,
  y = 158
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 154,
  y = 176
}, {
  dir = "N",
  items = { { "铝矿石", 2 } },
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 175,
  y = 208
}, {
  dir = "E",
  items = { { "supply", "铝矿石", 4 } },
  prototype_name = "物流站",
  x = 174,
  y = 204
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 176,
  y = 207
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 112,
  y = 144
}, {
  dir = "N",
  items = { { "氧化铝", 30 }, { "石墨", 30 }, { "塑料", 15 }, { "铝板", 17 } },
  prototype_name = "仓库I",
  x = 169,
  y = 170
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 118,
  y = 142
}, {
  dir = "W",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "甲烷", "纯水" }
  },
  items = { { "二氧化碳", 64 }, { "氢气", 97 }, { "甲烷", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转甲烷",
  x = 85,
  y = 156
}, {
  dir = "N",
  items = { { "橡胶", 4 }, { "铝丝", 6 }, { "绝缘线", 8 } },
  prototype_name = "组装机I",
  recipe = "绝缘线1",
  x = 169,
  y = 172
}, {
  dir = "W",
  fluid_name = {
    input = { "丁二烯" },
    output = {}
  },
  items = { { "丁二烯", 30 }, { "橡胶", 2 } },
  prototype_name = "浮选器I",
  recipe = "橡胶",
  x = 100,
  y = 169
}, {
  dir = "N",
  items = { { "supply", "橡胶", 2 } },
  prototype_name = "物流站",
  x = 104,
  y = 172
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 105,
  y = 171
}, {
  dir = "E",
  items = { { "demand", "橡胶", 2 }, { "supply", "电容I", 2 }, { "supply", "绝缘线", 2 }, { "demand", "硅板", 1 }, { "demand", "逻辑电路", 1 } },
  prototype_name = "物流站",
  x = 164,
  y = 172
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 167,
  y = 171
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 167,
  y = 169
}, {
  dir = "S",
  fluid_name = {
    input = { "盐酸", "甲烷" },
    output = { "润滑油" }
  },
  items = { { "硅板", 2 }, { "盐酸", 76 }, { "甲烷", 24 }, { "润滑油", 20 } },
  prototype_name = "化工厂I",
  recipe = "润滑油",
  x = 117,
  y = 167
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 116,
  y = 170
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 118,
  y = 170
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 170
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
  x = 117,
  y = 170
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 170
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 111,
  y = 171
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 121,
  y = 166
}, {
  dir = "W",
  fluid_name = {
    input = { "润滑油" },
    output = {}
  },
  items = { { "铝丝", 6 }, { "硅板", 8 }, { "润滑油", 10 }, { "逻辑电路", 4 }, { "电子科技包", 0 }, { "电容I", 0 }, { "绝缘线", 0 } },
  prototype_name = "组装机I",
  recipe = "逻辑电路1",
  x = 128,
  y = 164
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 126,
  y = 166
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 121,
  y = 132
}, {
  dir = "N",
  items = { { "电子科技包", 30 }, { "化学科技包", 30 } },
  prototype_name = "仓库I",
  x = 121,
  y = 135
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 121,
  y = 136
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 88,
  y = 154
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 155
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 157
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 88,
  y = 156
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 87,
  y = 151
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 88,
  y = 151
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 88,
  y = 152
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 153
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 155
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 89,
  y = 152
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 89,
  y = 156
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 153
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 84,
  y = 152
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 155
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 84,
  y = 154
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 155
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 157
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 83,
  y = 158
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 84,
  y = 158
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 83,
  y = 154
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 154
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 154
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
  x = 88,
  y = 158
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 159
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 163
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 75,
  y = 152
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 75,
  y = 162
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 163
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 75,
  y = 166
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 75,
  y = 164
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 75,
  y = 167
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 75,
  y = 163
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 163
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 162
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 157
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 162
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-X型",
  x = 84,
  y = 156
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 156
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 156
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 161
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 157
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 80,
  y = 162
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 85,
  y = 160
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 84,
  y = 160
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 95,
  y = 160
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 160
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-I型",
  x = 101,
  y = 159
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 102,
  y = 160
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 160
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "管道1-T型",
  x = 102,
  y = 159
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 103,
  y = 159
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 105,
  y = 159
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 158
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 106,
  y = 159
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 210 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 103,
  y = 166
}, {
  dir = "E",
  fluid_name = {
    input = { "氧气", "甲烷" },
    output = { "乙烯", "纯水" }
  },
  items = { { "氧气", 23 }, { "甲烷", 80 }, { "乙烯", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "甲烷转乙烯",
  x = 85,
  y = 165
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 162
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "管道1-T型",
  x = 84,
  y = 161
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 84,
  y = 165
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 164
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 162
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 164
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 88,
  y = 165
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 89,
  y = 165
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 164
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-X型",
  x = 88,
  y = 163
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 166
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 84,
  y = 167
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 83,
  y = 167
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 168
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 82,
  y = 167
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 87,
  y = 172
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 86,
  y = 172
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 172
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 171
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 82,
  y = 172
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 172
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 75,
  y = 171
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 75,
  y = 172
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 172
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 89,
  y = 142
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 144
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 89,
  y = 143
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 146
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-X型",
  x = 89,
  y = 147
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  items = { { "空气", 300 }, { "氮气", 0 }, { "二氧化碳", 69 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 85,
  y = 124
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "管道1-I型",
  x = 90,
  y = 128
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "管道1-I型",
  x = 90,
  y = 140
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "管道1-L型",
  x = 91,
  y = 128
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 129
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 139
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 90,
  y = 124
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 125
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 129
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 90,
  y = 130
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 131
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 132
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 96,
  y = 132
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 132
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 95,
  y = 133
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-X型",
  x = 95,
  y = 132
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 95,
  y = 136
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 95,
  y = 135
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 136
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 132
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 132
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 132
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 145
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 153
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 134
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 144
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 166
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 79,
  y = 169
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 168
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 79,
  y = 165
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "管道1-X型",
  x = 91,
  y = 134
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 135
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 133
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "管道1-I型",
  x = 90,
  y = 134
}, {
  dir = "S",
  items = { { "supply", "铝矿石", 2 } },
  prototype_name = "物流站",
  x = 210,
  y = 190
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 214,
  y = 191
}, {
  dir = "N",
  items = { { "铝矿石", 60 } },
  prototype_name = "仓库I",
  x = 214,
  y = 190
}, {
  dir = "N",
  items = { { "铝矿石", 2 } },
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 216,
  y = 189
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 143,
  y = 147
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 142,
  y = 145
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 121,
  y = 152
}, {
  dir = "S",
  items = { { "demand", "铝矿石", 2 }, { "supply", "碾碎铝矿石", 1 }, { "demand", "碎石", 1 }, { "demand", "沙子", 4 } },
  prototype_name = "物流站",
  x = 116,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 120,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 122,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 121,
  y = 154
}, {
  dir = "N",
  items = { { "电容I", 2 }, { "绝缘线", 4 }, { "逻辑电路", 2 }, { "电子科技包", 2 } },
  prototype_name = "组装机I",
  recipe = "电子科技包1",
  x = 128,
  y = 167
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 87,
  y = 183
}, {
  dir = "W",
  fluid_name = "润滑油",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 165
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  items = { { "地下卤水", 90 }, { "氧气", 0 }, { "氢气", 0 }, { "氯气", 0 } },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 73,
  y = 142
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  items = { { "地下卤水", 90 }, { "氧气", 0 }, { "氢气", 215 }, { "氯气", 0 } },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 73,
  y = 137
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 205 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 71,
  y = 127
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 144
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 141
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 72,
  y = 142
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 141
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 77,
  y = 137
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 138
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 141
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 72,
  y = 137
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 138
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 79,
  y = 171
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 80,
  y = 171
}, {
  dir = "W",
  fluid_name = {
    input = { "一氧化碳", "氢气" },
    output = { "纯水" }
  },
  items = { { "一氧化碳", 56 }, { "氢气", 21 }, { "石墨", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "一氧化碳转石墨",
  x = 85,
  y = 175
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 84,
  y = 169
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 169
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 170
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 83,
  y = 169
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 83,
  y = 175
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 84,
  y = 175
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 174
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-L型",
  x = 84,
  y = 180
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 179
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 88,
  y = 172
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 173
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 88,
  y = 177
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 176
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 89,
  y = 173
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-L型",
  x = 84,
  y = 171
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 172
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-T型",
  x = 84,
  y = 177
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 178
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 176
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 14 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 34,
  y = 234
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 14 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 34,
  y = 229
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "管道1-I型",
  x = 119,
  y = 170
}, {
  dir = "W",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 118,
  y = 171
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 73,
  y = 227
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 71,
  y = 224
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 59,
  y = 233
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 62,
  y = 233
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 65,
  y = 233
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 68,
  y = 233
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 71,
  y = 233
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 227
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 229
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 229
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 229
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 59,
  y = 231
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 61,
  y = 231
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 63,
  y = 231
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 231
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 231
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 231
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 231
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 59,
  y = 236
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 62,
  y = 236
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 65,
  y = 236
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 68,
  y = 236
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 71,
  y = 236
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 106,
  y = 147
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 148
}, {
  dir = "N",
  items = { { "绝缘线", 10 }, { "电容I", 4 }, { "数据线", 3 } },
  prototype_name = "组装机I",
  recipe = "数据线1",
  x = 171,
  y = 169
}, {
  dir = "N",
  items = { { "铁矿石", 2 } },
  prototype_name = "采矿机II",
  recipe = "铁矿石挖掘",
  x = 75,
  y = 93
}, {
  dir = "N",
  items = { { "数据线", 15 }, { "速度插件I", 15 }, { "效能插件I", 7 }, { "产能插件I", 15 } },
  prototype_name = "仓库I",
  x = 175,
  y = 170
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 174,
  y = 170
}, {
  dir = "E",
  fluid_name = {
    input = { "润滑油" },
    output = {}
  },
  items = { { "铝丝", 6 }, { "硅板", 12 }, { "润滑油", 10 }, { "逻辑电路", 3 }, { "电容I", 0 } },
  prototype_name = "组装机I",
  recipe = "逻辑电路1",
  x = 116,
  y = 164
}, {
  dir = "N",
  items = { { "电容I", 4 }, { "铝丝", 4 }, { "塑料", 4 }, { "硅板", 4 }, { "运算电路", 5 } },
  prototype_name = "组装机I",
  recipe = "运算电路1",
  x = 173,
  y = 172
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 170,
  y = 171
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 170,
  y = 169
}, {
  dir = "N",
  items = { { "硅板", 30 }, { "逻辑电路", 15 } },
  prototype_name = "仓库I",
  x = 169,
  y = 171
}, {
  dir = "E",
  fluid_name = "润滑油",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 165
}, {
  dir = "N",
  fluid_name = "润滑油",
  prototype_name = "管道1-T型",
  x = 119,
  y = 165
}, {
  dir = "N",
  fluid_name = "润滑油",
  prototype_name = "管道1-I型",
  x = 119,
  y = 166
}, {
  dir = "N",
  items = { { "数据线", 6 }, { "运算电路", 2 }, { "速度插件I", 2 } },
  prototype_name = "组装机I",
  recipe = "速度插件1",
  x = 173,
  y = 166
}, {
  dir = "N",
  items = { { "supply", "硅板", 2 }, { "supply", "电子科技包", 1 } },
  prototype_name = "物流站",
  x = 122,
  y = 172
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 125,
  y = 171
}, {
  dir = "N",
  fluid_name = "",
  items = {},
  prototype_name = "组装机I",
  x = 173,
  y = 163
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 167,
  y = 173
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 172,
  y = 173
}, {
  dir = "N",
  items = { { "数据线", 6 }, { "逻辑电路", 2 }, { "运算电路", 2 }, { "产能插件I", 2 } },
  prototype_name = "组装机I",
  recipe = "产能插件1",
  x = 173,
  y = 175
}, {
  dir = "N",
  items = { { "铝棒", 4 }, { "钢齿轮", 8 }, { "无人机平台I", 2 }, { "无人机平台II", 2 } },
  prototype_name = "组装机I",
  recipe = "无人机平台2",
  x = 170,
  y = 163
}, {
  dir = "E",
  fluid_name = {
    input = { "氮气", "氢气" },
    output = { "氨气" }
  },
  items = { { "氮气", 16 }, { "氢气", 23 }, { "氨气", 0 } },
  prototype_name = "化工厂I",
  recipe = "氨气",
  x = 61,
  y = 143
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 130
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 72,
  y = 140
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 139
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 89,
  y = 161
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 89,
  y = 160
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 88,
  y = 161
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 88,
  y = 160
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 87,
  y = 160
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 83,
  y = 147
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 87,
  y = 159
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 86,
  y = 159
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 159
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 159
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 159
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 135
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 90,
  y = 136
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 136
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 83,
  y = 142
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 143
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 95,
  y = 128
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 96,
  y = 128
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 98,
  y = 128
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 129
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 97,
  y = 128
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 138
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 139
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 145
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 90,
  y = 145
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 96,
  y = 145
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 100,
  y = 145
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 145
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 151
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 143
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 95,
  y = 143
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 97,
  y = 143
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 142
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 96,
  y = 143
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "管道1-T型",
  x = 91,
  y = 140
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "管道1-I型",
  x = 92,
  y = 140
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "管道1-I型",
  x = 93,
  y = 140
}, {
  dir = "N",
  fluid_name = "氨气",
  prototype_name = "液罐I",
  x = 49,
  y = 142
}, {
  dir = "E",
  items = { { "demand", "无人机平台I", 1 }, { "demand", "玻璃", 1 } },
  prototype_name = "物流站",
  x = 164,
  y = 164
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 167,
  y = 167
}, {
  dir = "N",
  items = { { "无人机平台II", 15 }, { "玻璃", 15 }, { "科研中心I", 3 } },
  prototype_name = "仓库I",
  x = 169,
  y = 165
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 172,
  y = 166
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 150 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 82,
  y = 127
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 84,
  y = 127
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 125 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 82,
  y = 139
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 84,
  y = 139
}, {
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "甲烷", "纯水" }
  },
  items = { { "二氧化碳", 64 }, { "氢气", 95 }, { "甲烷", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂II",
  recipe = "二氧化碳转甲烷",
  x = 63,
  y = 150
}, {
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "甲烷", "纯水" }
  },
  items = { { "二氧化碳", 64 }, { "氢气", 68 }, { "甲烷", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转甲烷",
  x = 63,
  y = 154
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 156
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 80,
  y = 156
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 78,
  y = 156
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 78,
  y = 154
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-X型",
  x = 79,
  y = 154
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 154
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 67,
  y = 154
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 66,
  y = 154
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 66,
  y = 153
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 66,
  y = 150
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 66,
  y = 151
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 66,
  y = 152
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 153
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 155
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 66,
  y = 156
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 156
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 156
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 167
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 157
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-X型",
  x = 67,
  y = 156
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 169
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 169
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 69,
  y = 169
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 62,
  y = 152
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 62,
  y = 156
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 153
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 155
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 61,
  y = 152
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 60,
  y = 152
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 151
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 151
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 151
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 151
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 75,
  y = 151
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 60,
  y = 151
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 158
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 158
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 158
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 81,
  y = 158
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 157
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 81,
  y = 157
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 157
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 90,
  y = 157
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 158
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 166
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
  x = 88,
  y = 167
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 89,
  y = 167
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 90,
  y = 167
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 151
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 62,
  y = 150
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 153
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
  x = 62,
  y = 154
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 155
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 157
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 62,
  y = 158
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 63,
  y = 158
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  items = { { "空气", 300 }, { "氮气", 0 }, { "二氧化碳", 48 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 63,
  y = 124
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  items = { { "空气", 300 }, { "氮气", 0 }, { "二氧化碳", 0 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 63,
  y = 130
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 68,
  y = 130
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 69,
  y = 129
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 69,
  y = 124
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 69,
  y = 125
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 70,
  y = 130
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 79,
  y = 130
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 78,
  y = 130
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 133
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 125 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 61,
  y = 125
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 125 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 60,
  y = 127
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 62,
  y = 127
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 175 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 61,
  y = 131
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 175 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 60,
  y = 133
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 62,
  y = 133
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  items = { { "空气", 300 }, { "氮气", 0 }, { "二氧化碳", 45 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 63,
  y = 136
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 68,
  y = 136
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-X型",
  x = 69,
  y = 130
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 69,
  y = 135
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 69,
  y = 136
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 69,
  y = 131
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "管道1-T型",
  x = 68,
  y = 134
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 135
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 150 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 61,
  y = 137
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 150 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 60,
  y = 139
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 62,
  y = 139
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 69,
  y = 139
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 139
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  items = { { "地下卤水", 90 }, { "氧气", 0 }, { "氢气", 0 }, { "氯气", 0 } },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 73,
  y = 147
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 77,
  y = 142
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 78,
  y = 143
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 78,
  y = 142
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 78,
  y = 147
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 78,
  y = 146
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 77,
  y = 147
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 148
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 155
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 77,
  y = 156
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 72,
  y = 145
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 146
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 72,
  y = 150
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 149
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 72,
  y = 147
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 71,
  y = 142
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 143
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 146
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 71,
  y = 147
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 14 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 28,
  y = 229
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 14 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 28,
  y = 234
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地热气" }
  },
  items = { { "地热气", 0 } },
  prototype_name = "地热井I",
  recipe = "地热采集",
  x = 228,
  y = 222
}, {
  dir = "N",
  fluid_name = {
    input = { "地热气" },
    output = {}
  },
  items = { { "地热气", 5 } },
  prototype_name = "蒸汽发电机I",
  recipe = "地热气发电",
  x = 229,
  y = 227
}, {
  dir = "N",
  fluid_name = {
    input = { "地热气" },
    output = {}
  },
  items = { { "地热气", 49 } },
  prototype_name = "蒸汽发电机I",
  recipe = "地热气发电",
  x = 229,
  y = 232
}, {
  dir = "N",
  fluid_name = {
    input = { "地热气" },
    output = {}
  },
  items = { { "地热气", 5 } },
  prototype_name = "蒸汽发电机I",
  recipe = "地热气发电",
  x = 229,
  y = 237
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "管道1-X型",
  x = 68,
  y = 140
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 141
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 64,
  y = 143
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 151
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 67,
  y = 152
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 64,
  y = 145
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 146
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 66,
  y = 145
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 67,
  y = 145
}, {
  dir = "W",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 60,
  y = 143
}, {
  dir = "E",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 143
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "管道1-L型",
  x = 68,
  y = 128
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 129
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 142
}, {
  dir = "W",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 143
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "管道1-T型",
  x = 68,
  y = 143
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 144
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "液罐I",
  x = 67,
  y = 161
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 153
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 152
}, {
  dir = "N",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 160
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 70,
  y = 161
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 112,
  y = 133
}, {
  dir = "N",
  items = { { "铁矿石", 6 }, { "铁板", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 111,
  y = 134
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 114,
  y = 132
}, {
  dir = "N",
  items = { { "铁矿石", 0 } },
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 138,
  y = 174
}, {
  dir = "E",
  items = { { "supply", "铁矿石", 2 } },
  prototype_name = "物流站",
  x = 138,
  y = 170
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 140,
  y = 173
}, {
  dir = "S",
  items = { { "demand", "铁矿石", 3 }, { "demand", "碾碎铁矿石", 1 }, { "supply", "铁板", 1 } },
  prototype_name = "物流站",
  x = 106,
  y = 128
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 110,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 110,
  y = 131
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 119,
  y = 134
}, {
  dir = "N",
  items = { { "铁矿石", 4 }, { "铁板", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 107,
  y = 134
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地热气" }
  },
  items = { { "地热气", 0 } },
  prototype_name = "地热井I",
  recipe = "地热采集",
  x = 45,
  y = 152
}, {
  dir = "N",
  fluid_name = "地热气",
  prototype_name = "液罐I",
  x = 46,
  y = 149
}, {
  dir = "E",
  fluid_name = {
    input = { "氧气", "纯水", "地热气" },
    output = { "硫酸" }
  },
  items = { { "氧气", 8 }, { "纯水", 32 }, { "地热气", 16 }, { "硫酸", 0 } },
  prototype_name = "化工厂I",
  recipe = "硫酸溶液",
  x = 53,
  y = 154
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 61,
  y = 156
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 60,
  y = 156
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 56,
  y = 156
}, {
  dir = "N",
  fluid_name = "地热气",
  prototype_name = "地下管1-JI型",
  x = 54,
  y = 153
}, {
  dir = "E",
  fluid_name = "地热气",
  prototype_name = "地下管1-JI型",
  x = 49,
  y = 150
}, {
  dir = "S",
  fluid_name = "地热气",
  prototype_name = "管道1-L型",
  x = 54,
  y = 150
}, {
  dir = "S",
  fluid_name = "地热气",
  prototype_name = "地下管1-JI型",
  x = 54,
  y = 151
}, {
  dir = "W",
  fluid_name = "地热气",
  prototype_name = "地下管1-JI型",
  x = 53,
  y = 150
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 77,
  y = 139
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 150
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 82,
  y = 148
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 82,
  y = 149
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 150
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 158
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 151
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 82,
  y = 150
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 82,
  y = 159
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 159
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 159
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 159
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 57,
  y = 159
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 56,
  y = 158
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 56,
  y = 159
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 56,
  y = 154
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 56,
  y = 155
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 83,
  y = 143
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 82,
  y = 142
}, {
  dir = "N",
  fluid_name = "硫酸",
  prototype_name = "液罐I",
  x = 51,
  y = 163
}, {
  dir = "N",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 162
}, {
  dir = "S",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 155
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 146
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 82,
  y = 147
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 82,
  y = 143
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 144
}, {
  dir = "E",
  fluid_name = {
    input = { "纯水" },
    output = {}
  },
  items = { { "纯水", 12 }, { "碎石", 8 }, { "沙子", 4 }, { "钢板", 10 }, { "混凝土", 6 } },
  prototype_name = "浮选器I",
  recipe = "混凝土",
  x = 130,
  y = 148
}, {
  dir = "E",
  fluid_name = {
    input = { "纯水" },
    output = {}
  },
  items = { { "纯水", 12 }, { "碎石", 8 }, { "沙子", 4 }, { "钢板", 10 }, { "混凝土", 9 } },
  prototype_name = "浮选器I",
  recipe = "混凝土",
  x = 130,
  y = 152
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 131,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 133,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 135,
  y = 184
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 142,
  y = 184
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 143,
  y = 184
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 127,
  y = 149
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 172
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 171
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 182
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 134,
  y = 183
}, {
  dir = "S",
  items = { { "demand", "碎石", 2 }, { "demand", "钢板", 2 }, { "supply", "混凝土", 4 } },
  prototype_name = "物流站",
  x = 132,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 128,
  y = 150
}, {
  dir = "S",
  fluid_name = {
    input = { "硫酸", "氨气" },
    output = {}
  },
  items = { { "橡胶", 10 }, { "硫酸", 36 }, { "混凝土", 12 }, { "氨气", 100 }, { "化学科技包", 4 } },
  prototype_name = "化工厂I",
  recipe = "化学科技包1",
  x = 50,
  y = 126
}, {
  dir = "N",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 50,
  y = 141
}, {
  dir = "W",
  fluid_name = "硫酸",
  prototype_name = "管道1-T型",
  x = 52,
  y = 154
}, {
  dir = "N",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 153
}, {
  dir = "S",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 145
}, {
  dir = "N",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 144
}, {
  dir = "S",
  items = { { "supply", "化学科技包", 1 }, { "demand", "橡胶", 4 }, { "demand", "混凝土", 3 } },
  prototype_name = "物流站",
  x = 52,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 53,
  y = 126
}, {
  dir = "S",
  fluid_name = {
    input = { "硫酸", "氨气" },
    output = {}
  },
  items = { { "橡胶", 10 }, { "硫酸", 36 }, { "混凝土", 12 }, { "氨气", 100 }, { "化学科技包", 4 } },
  prototype_name = "化工厂I",
  recipe = "化学科技包1",
  x = 54,
  y = 126
}, {
  dir = "N",
  fluid_name = "氨气",
  prototype_name = "管道1-I型",
  x = 50,
  y = 129
}, {
  dir = "N",
  fluid_name = "氨气",
  prototype_name = "管道1-I型",
  x = 54,
  y = 129
}, {
  dir = "N",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 50,
  y = 133
}, {
  dir = "S",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 50,
  y = 134
}, {
  dir = "S",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 50,
  y = 131
}, {
  dir = "W",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 53,
  y = 130
}, {
  dir = "W",
  fluid_name = "氨气",
  prototype_name = "管道1-T型",
  x = 50,
  y = 130
}, {
  dir = "E",
  fluid_name = "氨气",
  prototype_name = "地下管1-JI型",
  x = 51,
  y = 130
}, {
  dir = "W",
  fluid_name = "氨气",
  prototype_name = "管道1-L型",
  x = 54,
  y = 130
}, {
  dir = "N",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 133
}, {
  dir = "S",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 134
}, {
  dir = "S",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 52,
  y = 130
}, {
  dir = "E",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 53,
  y = 129
}, {
  dir = "W",
  fluid_name = "硫酸",
  prototype_name = "管道1-L型",
  x = 56,
  y = 129
}, {
  dir = "W",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 55,
  y = 129
}, {
  dir = "N",
  items = { { "混凝土", 15 }, { "橡胶", 15 }, { "化学科技包", 30 }, { "化学科技包", 30 } },
  prototype_name = "仓库I",
  x = 53,
  y = 127
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 77,
  y = 144
}, {
  dir = "E",
  items = { { "demand", "铁矿石", 4 }, { "supply", "铁板", 3 } },
  prototype_name = "物流站",
  x = 106,
  y = 138
}, {
  dir = "N",
  items = { { "铁矿石", 0 }, { "铁板", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 108,
  y = 138
}, {
  dir = "N",
  items = { { "铁矿石", 2 }, { "铁板", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 112,
  y = 138
}, {
  dir = "N",
  items = { { "铁矿石", 1 }, { "铁板", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 108,
  y = 141
}, {
  dir = "N",
  items = { { "铁矿石", 2 }, { "铁板", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 112,
  y = 141
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 107,
  y = 142
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 110,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 110,
  y = 144
}, {
  dir = "N",
  items = { { "铁矿石", 2 } },
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 180,
  y = 193
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 179,
  y = 194
}, {
  dir = "S",
  items = { { "supply", "铁矿石", 2 } },
  prototype_name = "物流站",
  x = 176,
  y = 192
}, {
  dir = "W",
  items = { { "supply", "铁矿石", 2 } },
  prototype_name = "物流站",
  x = 152,
  y = 102
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 151,
  y = 100
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 98,
  y = 127
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 97,
  y = 127
}, {
  dir = "N",
  fluid_name = {
    input = { "氧气" },
    output = { "二氧化碳" }
  },
  items = { { "铁板", 2 }, { "氧气", 60 }, { "钢板", 2 }, { "二氧化碳", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "钢板1",
  x = 101,
  y = 129
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 99,
  y = 128
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 100,
  y = 128
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 99,
  y = 132
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 100,
  y = 132
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 68,
  y = 124
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 132,
  y = 184
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "液罐I",
  x = 111,
  y = 146
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "液罐I",
  x = 133,
  y = 186
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 134,
  y = 185
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-X型",
  x = 134,
  y = 184
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 95,
  y = 178
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 96,
  y = 178
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "纯水", "氧气" }
  },
  items = { { "氢氧化钠", 8 }, { "纯水", 0 }, { "氧气", 0 }, { "钠", 6 } },
  prototype_name = "电解厂I",
  recipe = "氢氧化钠电解",
  x = 98,
  y = 180
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 184
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 87,
  y = 184
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 98,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 184
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 184
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 101,
  y = 184
}, {
  dir = "S",
  fluid_name = {
    input = { "硫酸" },
    output = {}
  },
  items = { { "硫酸", 32 }, { "铝板", 6 }, { "石墨", 4 }, { "钠", 4 }, { "电池I", 2 } },
  prototype_name = "化工厂I",
  recipe = "电池1",
  x = 46,
  y = 126
}, {
  dir = "W",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 51,
  y = 129
}, {
  dir = "N",
  fluid_name = "硫酸",
  prototype_name = "管道1-X型",
  x = 52,
  y = 129
}, {
  dir = "E",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 49,
  y = 129
}, {
  dir = "S",
  items = { { "demand", "钠", 2 }, { "demand", "石墨", 2 }, { "demand", "铝板", 2 }, { "supply", "电池I", 2 } },
  prototype_name = "物流站",
  x = 46,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 50,
  y = 125
}, {
  dir = "N",
  items = { { "电池I", 15 } },
  prototype_name = "仓库I",
  x = 51,
  y = 125
}, {
  dir = "N",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽", "废水" }
  },
  items = { { "地下卤水", 180 }, { "蒸汽", 0 }, { "废水", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 28,
  y = 227
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 27,
  y = 227
}, {
  dir = "N",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽", "废水" }
  },
  items = { { "地下卤水", 180 }, { "蒸汽", 0 }, { "废水", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 34,
  y = 227
}, {
  dir = "N",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽", "废水" }
  },
  items = { { "地下卤水", 132 }, { "蒸汽", 0 }, { "废水", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 40,
  y = 227
}, {
  dir = "N",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽", "废水" }
  },
  items = { { "地下卤水", 160 }, { "蒸汽", 0 }, { "废水", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 46,
  y = 227
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 28,
  y = 226
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 27,
  y = 226
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 34,
  y = 226
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 32,
  y = 226
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 33,
  y = 226
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 33,
  y = 227
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 40,
  y = 226
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 38,
  y = 226
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 39,
  y = 226
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 39,
  y = 227
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 45,
  y = 227
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 44,
  y = 226
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 45,
  y = 226
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 31,
  y = 227
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 31,
  y = 226
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 32,
  y = 225
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 31,
  y = 225
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 37,
  y = 227
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 38,
  y = 225
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 36,
  y = 225
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 37,
  y = 225
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 37,
  y = 226
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 43,
  y = 227
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 44,
  y = 225
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 42,
  y = 225
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 43,
  y = 225
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 43,
  y = 226
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 49,
  y = 227
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 50,
  y = 224
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 49,
  y = 226
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 48,
  y = 225
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 49,
  y = 225
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽", "废水" }
  },
  items = { { "地下卤水", 180 }, { "蒸汽", 0 }, { "废水", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 100,
  y = 166
}, {
  dir = "N",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 101,
  y = 165
}, {
  dir = "W",
  fluid_name = "蒸汽",
  prototype_name = "管道1-T型",
  x = 101,
  y = 164
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "排水口I",
  recipe = "纯水排泄",
  x = 133,
  y = 193
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 74,
  y = 233
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 74,
  y = 236
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 56,
  y = 233
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 56,
  y = 236
}, {
  dir = "S",
  fluid_name = {
    input = { "硫酸" },
    output = { "二氧化碳", "废水" }
  },
  items = { { "硫酸", 24 }, { "沙子", 0 }, { "二氧化碳", 0 }, { "废水", 0 }, { "金红石", 0 } },
  prototype_name = "浮选器I",
  recipe = "金红石1",
  x = 40,
  y = 125
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 147,
  y = 166
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 153,
  y = 166
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 166
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-L型",
  x = 147,
  y = 171
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-I型",
  x = 148,
  y = 171
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 171
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-T型",
  x = 149,
  y = 171
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-L型",
  x = 154,
  y = 171
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 153,
  y = 171
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 125,
  y = 157
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 123,
  y = 157
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 124,
  y = 157
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 119,
  y = 157
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 157
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 117,
  y = 152
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 118,
  y = 152
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 119,
  y = 152
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 123,
  y = 152
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 122,
  y = 152
}, {
  dir = "E",
  fluid_name = "丁二烯",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 171
}, {
  dir = "W",
  fluid_name = "丁二烯",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 171
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 160
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 161
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 154
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 152
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 134,
  y = 153
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 134,
  y = 149
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 150
}, {
  dir = "S",
  fluid_name = "硫酸",
  prototype_name = "管道1-T型",
  x = 48,
  y = 129
}, {
  dir = "W",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 47,
  y = 129
}, {
  dir = "N",
  fluid_name = "硫酸",
  prototype_name = "管道1-L型",
  x = 42,
  y = 129
}, {
  dir = "E",
  fluid_name = "硫酸",
  prototype_name = "地下管1-JI型",
  x = 43,
  y = 129
}, {
  dir = "W",
  items = { { "demand", "沙子", 2 }, { "supply", "金红石", 2 } },
  prototype_name = "物流站",
  x = 42,
  y = 130
}, {
  dir = "W",
  fluid_name = {
    input = { "氯气" },
    output = { "四氯化钛" }
  },
  items = { { "氯气", 160 }, { "石墨", 14 }, { "金红石", 2 }, { "四氯化钛", 0 }, { "废料", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "四氯化钛",
  x = 99,
  y = 133
}, {
  dir = "W",
  fluid_name = {
    input = { "氯气" },
    output = { "四氯化钛" }
  },
  items = { { "氯气", 160 }, { "石墨", 14 }, { "金红石", 0 }, { "四氯化钛", 0 }, { "废料", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "四氯化钛",
  x = 99,
  y = 140
}, {
  dir = "W",
  items = { { "demand", "石墨", 2 }, { "demand", "金红石", 2 }, { "supply", "废料", 2 } },
  prototype_name = "物流站",
  x = 102,
  y = 136
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 101,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 41,
  y = 130
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 143
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 142
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 37,
  y = 125
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "烟囱I",
  recipe = "二氧化碳排泄",
  x = 40,
  y = 123
}, {
  dir = "S",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 135
}, {
  dir = "N",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 140
}, {
  dir = "W",
  fluid_name = "四氯化钛",
  prototype_name = "管道1-L型",
  x = 102,
  y = 141
}, {
  dir = "E",
  fluid_name = "四氯化钛",
  prototype_name = "管道1-T型",
  x = 102,
  y = 134
}, {
  dir = "N",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 133
}, {
  dir = "N",
  fluid_name = "丁二烯",
  prototype_name = "地下管1-JI型",
  x = 95,
  y = 169
}, {
  dir = "E",
  fluid_name = "丁二烯",
  prototype_name = "管道1-L型",
  x = 95,
  y = 158
}, {
  dir = "S",
  fluid_name = "丁二烯",
  prototype_name = "地下管1-JI型",
  x = 95,
  y = 159
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 102,
  y = 132
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 132
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 102,
  y = 128
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 128
}, {
  dir = "N",
  fluid_name = {
    input = { "氦气", "四氯化钛" },
    output = { "废水" }
  },
  items = { { "氦气", 2 }, { "钠", 12 }, { "四氯化钛", 0 }, { "钛板", 2 }, { "废水", 0 } },
  prototype_name = "浮选器I",
  recipe = "钛板",
  x = 103,
  y = 115
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳", "氦气" }
  },
  items = { { "空气", 200 }, { "氮气", 0 }, { "二氧化碳", 0 }, { "氦气", 0 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离2",
  x = 102,
  y = 101
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳", "氦气" }
  },
  items = { { "空气", 200 }, { "氮气", 0 }, { "二氧化碳", 0 }, { "氦气", 0 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离2",
  x = 108,
  y = 101
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳", "氦气" }
  },
  items = { { "空气", 200 }, { "氮气", 14 }, { "二氧化碳", 0 }, { "氦气", 0 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离2",
  x = 114,
  y = 101
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 147 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 101,
  y = 99
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 147 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 102,
  y = 97
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 147 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 108,
  y = 97
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 151 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 114,
  y = 97
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 147 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 107,
  y = 99
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 152 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 113,
  y = 99
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 103,
  y = 99
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 103,
  y = 100
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 109,
  y = 100
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 109,
  y = 99
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 115,
  y = 100
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 115,
  y = 99
}, {
  dir = "W",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 107,
  y = 106
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "管道1-T型",
  x = 108,
  y = 106
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 106
}, {
  dir = "W",
  fluid_name = "氮气",
  prototype_name = "管道1-L型",
  x = 114,
  y = 106
}, {
  dir = "W",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 113,
  y = 106
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "管道1-I型",
  x = 116,
  y = 106
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 112,
  y = 106
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "管道1-I型",
  x = 116,
  y = 107
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "管道1-I型",
  x = 110,
  y = 106
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "管道1-I型",
  x = 110,
  y = 107
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 106,
  y = 106
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "管道1-I型",
  x = 104,
  y = 106
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "管道1-I型",
  x = 104,
  y = 107
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 111,
  y = 107
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 106,
  y = 107
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 107,
  y = 107
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 112,
  y = 107
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 113,
  y = 107
}, {
  dir = "W",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 100,
  y = 106
}, {
  dir = "S",
  fluid_name = "氮气",
  prototype_name = "管道1-T型",
  x = 102,
  y = 106
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "地下管1-JI型",
  x = 103,
  y = 106
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "烟囱I",
  recipe = "二氧化碳排泄",
  x = 119,
  y = 106
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 118,
  y = 107
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 118,
  y = 106
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 117,
  y = 107
}, {
  dir = "E",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 111,
  y = 108
}, {
  dir = "W",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 108
}, {
  dir = "W",
  fluid_name = "氦气",
  prototype_name = "管道1-L型",
  x = 116,
  y = 108
}, {
  dir = "W",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 108
}, {
  dir = "S",
  fluid_name = "氦气",
  prototype_name = "管道1-T型",
  x = 110,
  y = 108
}, {
  dir = "E",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 105,
  y = 108
}, {
  dir = "S",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 104,
  y = 109
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 104,
  y = 113
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 97,
  y = 118
}, {
  dir = "N",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 124
}, {
  dir = "S",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 125
}, {
  dir = "S",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 117
}, {
  dir = "N",
  fluid_name = "四氯化钛",
  prototype_name = "管道1-T型",
  x = 102,
  y = 116
}, {
  dir = "N",
  fluid_name = "四氯化钛",
  prototype_name = "管道1-L型",
  x = 101,
  y = 116
}, {
  dir = "N",
  fluid_name = {
    input = { "氦气", "四氯化钛" },
    output = { "废水" }
  },
  items = { { "氦气", 2 }, { "钠", 12 }, { "四氯化钛", 0 }, { "钛板", 2 }, { "废水", 0 } },
  prototype_name = "浮选器I",
  recipe = "钛板",
  x = 109,
  y = 115
}, {
  dir = "E",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 105,
  y = 114
}, {
  dir = "W",
  fluid_name = "氦气",
  prototype_name = "管道1-T型",
  x = 104,
  y = 114
}, {
  dir = "S",
  fluid_name = "氦气",
  prototype_name = "管道1-L型",
  x = 110,
  y = 114
}, {
  dir = "W",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 114
}, {
  dir = "E",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 115
}, {
  dir = "E",
  fluid_name = "四氯化钛",
  prototype_name = "管道1-L型",
  x = 101,
  y = 115
}, {
  dir = "W",
  fluid_name = "四氯化钛",
  prototype_name = "地下管1-JI型",
  x = 107,
  y = 115
}, {
  dir = "N",
  fluid_name = "四氯化钛",
  prototype_name = "管道1-L型",
  x = 108,
  y = 116
}, {
  dir = "S",
  fluid_name = "四氯化钛",
  prototype_name = "管道1-L型",
  x = 108,
  y = 115
}, {
  dir = "N",
  items = { { "supply", "钛板", 2 }, { "demand", "钠", 2 } },
  prototype_name = "物流站",
  x = 106,
  y = 120
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 107,
  y = 119
}, {
  dir = "N",
  items = { { "钛板", 30 }, { "钛板", 30 }, { "钠", 30 }, { "钠", 30 } },
  prototype_name = "仓库I",
  x = 108,
  y = 119
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 105,
  y = 119
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 119
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 113,
  y = 118
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 119
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 112,
  y = 119
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 111,
  y = 119
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "液罐I",
  x = 94,
  y = 107
}, {
  dir = "N",
  fluid_name = "氦气",
  prototype_name = "管道1-X型",
  x = 104,
  y = 108
}, {
  dir = "W",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 103,
  y = 108
}, {
  dir = "E",
  fluid_name = "氦气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 108
}, {
  dir = "N",
  fluid_name = {
    input = { "盐酸" },
    output = { "废水", "二氧化碳" }
  },
  items = { { "盐酸", 20 }, { "废料", 0 }, { "废水", 0 }, { "二氧化碳", 0 } },
  prototype_name = "浮选器I",
  recipe = "废料中和",
  x = 118,
  y = 178
}, {
  dir = "S",
  items = { { "demand", "废料", 2 } },
  prototype_name = "物流站",
  x = 122,
  y = 176
}, {
  dir = "N",
  items = { { "废料", 0 }, { "废料", 0 } },
  prototype_name = "仓库I",
  x = 123,
  y = 178
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 122,
  y = 178
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "烟囱I",
  recipe = "二氧化碳排泄",
  x = 122,
  y = 179
}, {
  dir = "N",
  items = { { "铝矿石", 14 }, { "碾碎铝矿石", 7 }, { "碾碎铁矿石", 0 }, { "沙子", 0 }, { "碎石", 0 } },
  prototype_name = "粉碎机I",
  recipe = "碾碎铝矿石",
  x = 122,
  y = 149
}, {
  dir = "N",
  items = { { "沙子", 41 }, { "沙子", 40 } },
  prototype_name = "仓库I",
  x = 125,
  y = 149
}, {
  dir = "S",
  items = { { "demand", "铁矿石", 2 } },
  prototype_name = "物流站",
  x = 124,
  y = 128
}, {
  dir = "S",
  items = { { "demand", "铝矿石", 4 }, { "supply", "碾碎铁矿石", 4 } },
  prototype_name = "物流站",
  x = 128,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 129,
  y = 150
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 129,
  y = 149
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 99,
  y = 63
}, {
  dir = "N",
  items = { { "supply", "铝矿石", 4 } },
  prototype_name = "物流站",
  x = 94,
  y = 62
}, {
  dir = "W",
  fluid_name = {
    input = { "地热气" },
    output = {}
  },
  items = { { "地热气", 100 } },
  prototype_name = "蒸汽发电机II",
  recipe = "地热气发电",
  x = 41,
  y = 149
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 14 } },
  prototype_name = "蒸汽发电机II",
  recipe = "蒸汽发电",
  x = 46,
  y = 229
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 14 } },
  prototype_name = "蒸汽发电机II",
  recipe = "蒸汽发电",
  x = 46,
  y = 234
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 20 } },
  prototype_name = "蒸汽发电机II",
  recipe = "蒸汽发电",
  x = 40,
  y = 229
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 9 } },
  prototype_name = "蒸汽发电机II",
  recipe = "蒸汽发电",
  x = 40,
  y = 234
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 123,
  y = 148
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 73,
  y = 155
}, {
  dir = "N",
  items = { { "铝矿石", 1 } },
  prototype_name = "采矿机II",
  recipe = "铝矿挖掘",
  x = 102,
  y = 62
}, {
  dir = "N",
  fluid_name = {
    input = { "废水" },
    output = { "地下卤水" }
  },
  items = { { "废水", 193 }, { "地下卤水", 0 }, { "沙子", 0 } },
  prototype_name = "水电站I",
  recipe = "废水过滤",
  x = 110,
  y = 186
}, {
  dir = "N",
  fluid_name = {
    input = { "废水" },
    output = { "地下卤水" }
  },
  items = { { "废水", 0 }, { "地下卤水", 0 }, { "沙子", 0 } },
  prototype_name = "水电站I",
  recipe = "废水过滤",
  x = 110,
  y = 198
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 155
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 115,
  y = 152
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 115,
  y = 153
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 115,
  y = 154
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 186
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 182
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 186
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 116,
  y = 187
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 119,
  y = 187
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 99,
  y = 167
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 98,
  y = 167
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 98,
  y = 166
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 166
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 166
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 166
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 165
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 114,
  y = 166
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 176
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 177
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 167
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 115,
  y = 166
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 188
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-X型",
  x = 115,
  y = 187
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 115,
  y = 199
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 198
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 112,
  y = 191
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 112,
  y = 197
}, {
  dir = "N",
  fluid_name = {
    input = { "碱性溶液", "盐酸" },
    output = { "废水" }
  },
  items = { { "碱性溶液", 29 }, { "盐酸", 152 }, { "废水", 0 } },
  prototype_name = "水电站I",
  recipe = "酸碱中和",
  x = 122,
  y = 189
}, {
  dir = "W",
  fluid_name = {
    input = { "氯气", "氢气" },
    output = { "盐酸" }
  },
  items = { { "氯气", 28 }, { "氢气", 60 }, { "盐酸", 0 } },
  prototype_name = "化工厂I",
  recipe = "盐酸",
  x = 98,
  y = 154
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 162
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 92,
  y = 162
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 93,
  y = 162
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 95,
  y = 162
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 161
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 94,
  y = 162
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 155
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 154
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 95,
  y = 154
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 94,
  y = 154
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 156
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "管道1-T型",
  x = 110,
  y = 147
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 148
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 155
}, {
  dir = "W",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 156
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "管道1-T型",
  x = 110,
  y = 156
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 157
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 163
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "管道1-L型",
  x = 110,
  y = 171
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 170
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 164
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 171
}, {
  dir = "W",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 126,
  y = 171
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 172
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "管道1-L型",
  x = 127,
  y = 171
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 181
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 180
}, {
  dir = "W",
  fluid_name = "盐酸",
  prototype_name = "管道1-L型",
  x = 127,
  y = 192
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 191
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 125,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-I型",
  x = 126,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-I型",
  x = 127,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 137,
  y = 182
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 136,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 129,
  y = 182
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-T型",
  x = 128,
  y = 182
}, {
  dir = "S",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 183
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-L型",
  x = 128,
  y = 190
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 189
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-I型",
  x = 127,
  y = 190
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 188
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 189
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 121,
  y = 190
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 120,
  y = 190
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 97,
  y = 147
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 148
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 97,
  y = 152
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 153
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 155
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 97,
  y = 156
}, {
  dir = "N",
  items = { { "沙子", 0 }, { "沙子", 0 } },
  prototype_name = "仓库I",
  x = 115,
  y = 193
}, {
  dir = "N",
  items = { { "沙子", 0 }, { "沙子", 0 } },
  prototype_name = "仓库I",
  x = 115,
  y = 197
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "废水" }
  },
  items = { { "地下卤水", 0 }, { "沙子", 8 }, { "废水", 0 } },
  prototype_name = "水电站II",
  recipe = "沙子回收",
  x = 110,
  y = 192
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 194
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 115,
  y = 195
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 115,
  y = 196
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "排水口I",
  recipe = "地下卤水排泄",
  x = 106,
  y = 198
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 71,
  y = 137
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 71,
  y = 136
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 135
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 82,
  y = 135
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 71,
  y = 135
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 135
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 98,
  y = 134
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 136
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 140
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 98,
  y = 141
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 98,
  y = 135
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 93,
  y = 135
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 135
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 92,
  y = 135
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 143,
  y = 188
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 146,
  y = 166
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 145,
  y = 166
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 166
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 142,
  y = 166
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 142,
  y = 167
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-X型",
  x = 120,
  y = 187
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 121,
  y = 187
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 130,
  y = 187
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 129,
  y = 187
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 140,
  y = 187
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 142,
  y = 188
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 141,
  y = 187
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 142,
  y = 186
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 142,
  y = 177
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 142,
  y = 176
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 142,
  y = 187
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 54,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 57,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 60,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 63,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 66,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 69,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 54,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 57,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 60,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 63,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 66,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 69,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 72,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 75,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 72,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 75,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 78,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 81,
  y = 194
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 120 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 78,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "空气", 110 }, { "净化气", 0 } },
  prototype_name = "化工厂II",
  recipe = "净化气1",
  x = 81,
  y = 203
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "烟囱I",
  recipe = "净化气排泄",
  x = 51,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 53,
  y = 198
}, {
  dir = "N",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 53,
  y = 205
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "烟囱I",
  recipe = "氯气排泄",
  x = 100,
  y = 146
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 99,
  y = 147
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 98,
  y = 147
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 240 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 101,
  y = 194
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 109,
  y = 199
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 188
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 109,
  y = 198
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 109,
  y = 187
}, {
  dir = "E",
  items = { { "supply", "沙子", 4 } },
  prototype_name = "物流站",
  x = 108,
  y = 192
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 119,
  y = 177
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "管道1-X型",
  x = 119,
  y = 171
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 119,
  y = 172
}, {
  dir = "N",
  items = { { "石墨", 2 }, { "铁板", 3 }, { "钢齿轮", 4 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器",
  x = 154,
  y = 183
}, {
  dir = "N",
  items = { { "石墨", 2 }, { "铁板", 3 }, { "钢齿轮", 4 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器",
  x = 158,
  y = 183
}, {
  dir = "N",
  items = { { "石墨", 2 }, { "铁板", 4 }, { "钢齿轮", 4 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器",
  x = 162,
  y = 183
}, {
  dir = "N",
  items = { { "石墨", 2 }, { "铁板", 0 }, { "钢齿轮", 4 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器",
  x = 166,
  y = 183
}, {
  dir = "S",
  items = { { "demand", "铁板", 4 }, { "demand", "石墨", 2 }, { "demand", "钢齿轮", 2 } },
  prototype_name = "物流站",
  x = 156,
  y = 180
}, {
  dir = "S",
  items = { { "demand", "铁板", 4 }, { "demand", "石墨", 2 }, { "demand", "钢齿轮", 2 } },
  prototype_name = "物流站",
  x = 164,
  y = 180
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 159,
  y = 182
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 163,
  y = 182
}, {
  dir = "N",
  items = { { "过滤器", 0 }, { "过滤器", 0 } },
  prototype_name = "仓库I",
  x = 161,
  y = 185
}, {
  dir = "N",
  items = { { "过滤器", 0 }, { "过滤器", 0 }, { "过滤器", 0 }, { "过滤器", 0 } },
  prototype_name = "仓库I",
  x = 157,
  y = 185
}, {
  dir = "N",
  items = { { "过滤器", 0 }, { "过滤器", 0 } },
  prototype_name = "仓库I",
  x = 165,
  y = 185
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 161,
  y = 184
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 157,
  y = 184
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 165,
  y = 184
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "过滤器", 0 }, { "空气", 2400 }, { "净化气", 0 }, { "用过的过滤器", 0 } },
  prototype_name = "化工厂I",
  recipe = "净化气2",
  x = 156,
  y = 187
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "过滤器", 0 }, { "空气", 2400 }, { "净化气", 0 }, { "用过的过滤器", 0 } },
  prototype_name = "化工厂I",
  recipe = "净化气2",
  x = 160,
  y = 187
}, {
  dir = "N",
  fluid_name = {
    input = { "空气" },
    output = { "净化气" }
  },
  items = { { "过滤器", 0 }, { "空气", 2400 }, { "净化气", 0 }, { "用过的过滤器", 0 } },
  prototype_name = "化工厂I",
  recipe = "净化气2",
  x = 164,
  y = 187
}, {
  dir = "N",
  fluid_name = {
    input = { "纯水" },
    output = {}
  },
  items = { { "用过的过滤器", 1 }, { "纯水", 80 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器回收",
  x = 154,
  y = 192
}, {
  dir = "N",
  fluid_name = {
    input = { "纯水" },
    output = {}
  },
  items = { { "用过的过滤器", 3 }, { "纯水", 80 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器回收",
  x = 158,
  y = 192
}, {
  dir = "N",
  fluid_name = {
    input = { "纯水" },
    output = {}
  },
  items = { { "用过的过滤器", 2 }, { "纯水", 80 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器回收",
  x = 162,
  y = 192
}, {
  dir = "N",
  fluid_name = {
    input = { "纯水" },
    output = {}
  },
  items = { { "用过的过滤器", 3 }, { "纯水", 80 }, { "过滤器", 0 } },
  prototype_name = "组装机II",
  recipe = "过滤器回收",
  x = 166,
  y = 192
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 191
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 144,
  y = 191
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 135,
  y = 191
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 190
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 134,
  y = 189
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 134,
  y = 191
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "烟囱I",
  recipe = "净化气排泄",
  x = 149,
  y = 190
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 158,
  y = 190
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 165,
  y = 190
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 162,
  y = 190
}, {
  dir = "N",
  items = { { "用过的过滤器", 0 }, { "用过的过滤器", 0 }, { "用过的过滤器", 0 }, { "用过的过滤器", 0 } },
  prototype_name = "仓库I",
  x = 157,
  y = 191
}, {
  dir = "N",
  items = { { "用过的过滤器", 0 }, { "用过的过滤器", 0 }, { "用过的过滤器", 0 }, { "用过的过滤器", 0 } },
  prototype_name = "仓库I",
  x = 161,
  y = 191
}, {
  dir = "N",
  items = { { "用过的过滤器", 0 }, { "用过的过滤器", 0 }, { "用过的过滤器", 0 }, { "用过的过滤器", 0 } },
  prototype_name = "仓库I",
  x = 165,
  y = 191
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 149,
  y = 188
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 149,
  y = 192
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 81,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 78,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 75,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 72,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 73,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 69,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 70,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 65,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 66,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 63,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 64,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 59,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 60,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 193
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 56,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 57,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 58,
  y = 193
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 55,
  y = 193
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 164 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 51,
  y = 191
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 197 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 50,
  y = 193
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 172 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 52,
  y = 194
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 53,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 54,
  y = 193
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-X型",
  x = 52,
  y = 193
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 81,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 78,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 75,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 72,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 73,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 69,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 70,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 65,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 66,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 63,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 64,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 59,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 60,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 202
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 56,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 57,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 58,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 55,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 54,
  y = 202
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 114 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 52,
  y = 203
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 193 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 51,
  y = 200
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 113 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 50,
  y = 202
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-X型",
  x = 52,
  y = 202
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 53,
  y = 202
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 55,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "管道1-L型",
  x = 53,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 54,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "管道1-L型",
  x = 81,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 78,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 75,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 73,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 72,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 70,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 69,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 65,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 66,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 64,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 63,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 59,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 60,
  y = 197
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 58,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 56,
  y = 197
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 57,
  y = 197
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "管道1-L型",
  x = 81,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 78,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 74,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 75,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 73,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 72,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 70,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 68,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 69,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 67,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 65,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 66,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 64,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 62,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 63,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 61,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 59,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 60,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 58,
  y = 206
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 56,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 57,
  y = 206
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 55,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 53,
  y = 206
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 54,
  y = 206
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 156,
  y = 186
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 157,
  y = 186
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 159,
  y = 186
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 160,
  y = 186
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 161,
  y = 186
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 165,
  y = 186
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 163,
  y = 186
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 164,
  y = 186
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 168,
  y = 186
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 186 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 169,
  y = 184
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 196 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 167,
  y = 187
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 168 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 169,
  y = 182
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 108 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 169,
  y = 180
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 171,
  y = 180
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 171,
  y = 181
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 171,
  y = 182
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 171,
  y = 183
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 198 } },
  prototype_name = "空气过滤器II",
  recipe = "空气过滤",
  x = 169,
  y = 188
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 169,
  y = 187
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 169,
  y = 186
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 170,
  y = 186
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 171,
  y = 186
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 171,
  y = 184
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 171,
  y = 185
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 190
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 155,
  y = 190
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 149,
  y = 186
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 149,
  y = 194
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 152,
  y = 188
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 152,
  y = 186
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 152,
  y = 191
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "烟囱II",
  recipe = "净化气排泄",
  x = 152,
  y = 193
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "管道1-L型",
  x = 164,
  y = 190
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 163,
  y = 190
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 161,
  y = 190
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 156,
  y = 190
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 157,
  y = 190
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "地下管1-JI型",
  x = 159,
  y = 190
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 160,
  y = 190
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 167,
  y = 191
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 166,
  y = 191
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 154,
  y = 191
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 155,
  y = 191
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 156,
  y = 191
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 191
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 191
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 159,
  y = 191
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 163,
  y = 191
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 191
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 162,
  y = 191
}, {
  dir = "N",
  fluid_name = "净化气",
  prototype_name = "管道1-I型",
  x = 151,
  y = 191
}, {
  dir = "N",
  fluid_name = "净化气",
  prototype_name = "管道1-X型",
  x = 151,
  y = 192
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 151,
  y = 194
}, {
  dir = "N",
  fluid_name = "净化气",
  prototype_name = "管道1-I型",
  x = 151,
  y = 193
}, {
  dir = "E",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 151,
  y = 188
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 151,
  y = 189
}, {
  dir = "N",
  fluid_name = "净化气",
  prototype_name = "管道1-X型",
  x = 151,
  y = 190
}, {
  dir = "S",
  fluid_name = "净化气",
  prototype_name = "管道1-L型",
  x = 151,
  y = 186
}, {
  dir = "W",
  fluid_name = "净化气",
  prototype_name = "管道1-T型",
  x = 151,
  y = 187
} }
local road = { {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 136,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 146
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 148
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 150
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 142,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 126
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 156,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 136,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 126
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 116,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 94,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 90,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 86,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 84,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 82,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 80,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 78,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 120
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 66,
  y = 116
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 92,
  y = 122
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 136,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 152
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 154
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 156
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 146
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 148
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 114,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 76,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 148
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 146
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 144
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 128
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 114,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 156
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 112,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 154
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 152
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 112,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-X型",
  x = 154,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 116
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 88,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 90,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 94,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 174
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 172
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 170
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 164
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 168
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 166
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 158,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 164,
  y = 162
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 166,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 106,
  y = 174
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 176
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 178
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 180
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 182
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 184
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 186
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 188
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 106,
  y = 190
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 104,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 98,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-X型",
  x = 136,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 164
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 166
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 168
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 170
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 172
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 176
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 136,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 158,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 178
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 176
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 174
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 172
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 170
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 168
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 162,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 166
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 164
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 146,
  y = 178
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 146,
  y = 180
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 162,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 164,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 168,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 178
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 172,
  y = 210
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 208
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 206
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 204
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 202
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 200
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 198
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 196
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 194
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 192
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 188
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 186
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 184
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 172,
  y = 178
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 182
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 180
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 112,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 136,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 174
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 172,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 174,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 176,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 178,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 180,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 184,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 186,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 188,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 190,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 190
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 194,
  y = 190
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 146
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 148
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 152
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 154
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 156
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 154,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 64,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 62,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 60,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 56,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 54,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 52,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 112
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 108
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 106
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 104
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 102
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 154,
  y = 100
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 66,
  y = 122
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 76,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 120
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 76,
  y = 118
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 118
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 72,
  y = 118
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 70,
  y = 118
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 66,
  y = 118
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 68,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 58,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 58,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 50,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 48,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 46,
  y = 122
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 44,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 44,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 44,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 44,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 44,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 44,
  y = 132
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 44,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 44,
  y = 134
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 104,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 104,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 124
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 116,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 208,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 210,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 198,
  y = 188
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 214,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 200,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 202,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 204,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 206,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 212,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 194,
  y = 188
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 196,
  y = 188
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 116
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 92,
  y = 114
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 90,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 88,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 112
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 108
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 106
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 104
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 102
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 100
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 98
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 96
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 94
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 92
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 90
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 88
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 86
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 84
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 82
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 80
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 78
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 76
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 74
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 72
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 70
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 68
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 66
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 88,
  y = 64
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 90,
  y = 64
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 64
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 94,
  y = 64
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 64
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 100,
  y = 64
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 64
} }
local mineral = {
["102,62"] = "铝矿石",
["103,190"] = "铝矿石",
["108,31"] = "碎石",
["114,81"] = "铁矿石",
["115,133"] = "碎石",
["129,70"] = "地热气",
["138,140"] = "铁矿石",
["138,174"] = "铁矿石",
["144,86"] = "碎石",
["145,149"] = "铝矿石",
["150,112"] = "碎石",
["150,95"] = "铁矿石",
["151,33"] = "铝矿石",
["166,159"] = "铝矿石",
["173,76"] = "铁矿石",
["175,208"] = "铝矿石",
["180,193"] = "铁矿石",
["182,234"] = "铁矿石",
["192,132"] = "碎石",
["197,117"] = "铁矿石",
["209,162"] = "铁矿石",
["210,142"] = "地热气",
["216,189"] = "铝矿石",
["220,77"] = "地热气",
["226,241"] = "铁矿石",
["229,223"] = "地热气",
["28,139"] = "铁矿石",
["31,167"] = "铁矿石",
["33,30"] = "铝矿石",
["42,205"] = "铁矿石",
["46,153"] = "地热气",
["58,19"] = "铁矿石",
["61,118"] = "铁矿石",
["62,167"] = "碎石",
["62,185"] = "铁矿石",
["66,147"] = "铁矿石",
["72,132"] = "碎石",
["72,74"] = "碎石",
["75,93"] = "铁矿石",
["91,165"] = "铁矿石",
["93,102"] = "碎石",
["93,203"] = "地热气"
}


return {
    name = "规模测试",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 8,
    guide = guide,
    start_tech = "地质研究",
    login_techs = {
      "登录科技开启",
    },
    init_ui = {
      "/pkg/vaststars.resources/ui/construct.html",
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