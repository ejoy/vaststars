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
  amount = 20,
  prototype_name = "物流中心",
  x = 152,
  y = 142
}, {
  dir = "N",
  items = { { "铁矿石", 2 } },
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 138,
  y = 140
}, {
  dir = "N",
  items = { { "铝矿石", 1 } },
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
  items = { { "铁矿石", 60 }, { "铝矿石", 60 }, { "铁板", 30 }, { "碎石", 60 } },
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
  x = 119,
  y = 134
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
  prototype_name = "无人机平台I",
  x = 142,
  y = 144
}, {
  dir = "N",
  items = { { "铁矿石", 60 }, { "铝矿石", 60 } },
  prototype_name = "仓库I",
  x = 144,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 143,
  y = 148
}, {
  dir = "N",
  items = { { "铁板", 8 }, { "铁棒", 6 }, { "铝矿石", 0 }, { "碎石", 0 }, { "地质科技包", 0 }, { "铁矿石", 0 } },
  prototype_name = "组装机I",
  recipe = "铁棒1",
  x = 118,
  y = 130
}, {
  dir = "N",
  items = { { "碎石", 4 }, { "铁矿石", 4 }, { "铝矿石", 4 }, { "地质科技包", 0 } },
  prototype_name = "组装机I",
  recipe = "地质科技包1",
  x = 122,
  y = 130
}, {
  dir = "N",
  items = { { "碎石", 4 }, { "石砖", 2 }, { "铁板", 0 }, { "铁棒", 0 } },
  prototype_name = "组装机I",
  recipe = "石砖",
  x = 118,
  y = 135
}, {
  dir = "N",
  items = { { "石砖", 16 }, { "管道1-X型", 10 }, { "碎石", 0 }, { "铁齿轮", 1 }, { "电动机I", 2 }, { "机械科技包", 0 } },
  prototype_name = "组装机I",
  recipe = "机械科技包T1",
  x = 122,
  y = 135
}, {
  dir = "N",
  items = { { "铁矿石", 10 }, { "铁板", 4 }, { "碎石", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板T1",
  x = 115,
  y = 130
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 2 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 125,
  y = 133
}, {
  dir = "N",
  items = { { "石砖", 30 }, { "铁棒", 30 }, { "机械科技包", 15 }, { "地质科技包", 27 } },
  prototype_name = "仓库I",
  x = 121,
  y = 134
}, {
  dir = "N",
  items = { { "地质科技包", 3 }, { "气候科技包", 2 }, { "机械科技包", 3 }, { "电子科技包", 2 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
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
  items = { { "demand", "铝矿石", 2 }, { "demand", "铁板", 1 }, { "supply", "碎石", 2 }, { "demand", "铁矿石", 1 }, { "demand", "电子科技包", 1 } },
  prototype_name = "物流站",
  x = 120,
  y = 128
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 16 }, { "石墨", 2 }, { "铁板", 11 }, { "碎石", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板2",
  x = 107,
  y = 130
}, {
  dir = "N",
  items = { { "管道1-X型", 60 }, { "气候科技包", 18 }, { "地下管1-JI型", 1 }, { "液罐I", 1 } },
  prototype_name = "仓库I",
  x = 125,
  y = 136
}, {
  dir = "N",
  items = { { "铁矿石", 2 } },
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
  items = { { "空气", 2599 }, { "地下卤水", 3000 }, { "气候科技包", 0 } },
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
  items = { { "地下卤水", 240 } },
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
  items = { { "空气", 0 } },
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
  items = { { "空气", 2599 }, { "地下卤水", 3000 }, { "气候科技包", 0 } },
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
  items = { { "地下卤水", 240 } },
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
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 132,
  y = 141
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 65,
  y = 206
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 68,
  y = 206
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 71,
  y = 206
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 74,
  y = 206
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 68,
  y = 203
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 65,
  y = 203
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 71,
  y = 203
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 74,
  y = 203
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 209
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 209
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 73,
  y = 209
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 75,
  y = 209
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 209
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 209
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 211
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 211
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 211
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 211
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  items = { { "地下卤水", 500 }, { "氧气", 0 }, { "氢气", 0 }, { "氯气", 0 } },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 85,
  y = 142
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 213 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 88,
  y = 139
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "液罐I",
  x = 96,
  y = 144
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "液罐I",
  x = 68,
  y = 155
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "液罐I",
  x = 100,
  y = 140
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  items = { { "空气", 149 }, { "氮气", 0 }, { "二氧化碳", 0 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 85,
  y = 134
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 83,
  y = 137
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 90,
  y = 137
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "液罐I",
  x = 78,
  y = 132
}, {
  dir = "W",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "甲烷", "纯水" }
  },
  items = { { "二氧化碳", 26 }, { "氢气", 500 }, { "甲烷", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转甲烷",
  x = 85,
  y = 152
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 90,
  y = 134
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 133
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 133
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 135
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 145
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 146
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 153
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  items = { { "地下卤水", 500 }, { "氧气", 0 }, { "氢气", 0 }, { "氯气", 0 } },
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
  items = { { "氧气", 19 }, { "甲烷", 46 }, { "乙烯", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "甲烷转乙烯",
  x = 85,
  y = 161
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "排水口I",
  recipe = "纯水排泄",
  x = 69,
  y = 150
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 142
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 141
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 99,
  y = 141
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "液罐I",
  x = 108,
  y = 154
}, {
  dir = "W",
  fluid_name = {
    input = { "乙烯", "氯气" },
    output = { "盐酸" }
  },
  items = { { "乙烯", 0 }, { "氯气", 175 }, { "塑料", 0 }, { "盐酸", 0 } },
  prototype_name = "化工厂I",
  recipe = "塑料1",
  x = 107,
  y = 145
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 145
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 145
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "排水口I",
  recipe = "盐酸排泄",
  x = 108,
  y = 141
}, {
  dir = "N",
  items = { { "塑料", 0 }, { "塑料", 0 }, { "塑料", 0 }, { "塑料", 0 } },
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
  fluid_name = "",
  items = {},
  prototype_name = "组装机I",
  x = 122,
  y = 139
}, {
  dir = "E",
  fluid_name = {
    input = { "乙烯", "蒸汽" },
    output = { "丁二烯", "氢气" }
  },
  items = { { "乙烯", 11 }, { "蒸汽", 500 }, { "丁二烯", 0 }, { "氢气", 0 } },
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
  items = { { "铁板", 4 }, { "氧气", 0 }, { "钢板", 2 }, { "二氧化碳", 0 } },
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
  items = { { "铁板", 4 }, { "氧气", 132 }, { "钢板", 2 }, { "二氧化碳", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "钢板1",
  x = 98,
  y = 129
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 133
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 95,
  y = 133
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 96,
  y = 133
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 95,
  y = 132
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 133
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 133
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-I型",
  x = 99,
  y = 132
}, {
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 99,
  y = 133
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 95,
  y = 128
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 96,
  y = 128
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 128
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 99,
  y = 128
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 100,
  y = 128
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 101,
  y = 128
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 139
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 129
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 97,
  y = 127
}, {
  dir = "S",
  items = { { "supply", "钢板", 2 }, { "demand", "铁板", 2 } },
  prototype_name = "物流站",
  x = 96,
  y = 124
}, {
  dir = "N",
  items = { { "铁矿石", 10 }, { "铁板", 4 }, { "碎石", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "铁板T1",
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
  prototype_name = "无人机平台I",
  x = 110,
  y = 130
}, {
  dir = "N",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  items = { { "地下卤水", 500 }, { "蒸汽", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 78,
  y = 186
}, {
  dir = "N",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  items = { { "地下卤水", 500 }, { "蒸汽", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 83,
  y = 186
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 29 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 78,
  y = 188
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 29 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 78,
  y = 193
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 216 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 74,
  y = 184
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 77,
  y = 186
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 77,
  y = 185
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 78,
  y = 185
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 81,
  y = 185
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 82,
  y = 186
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 82,
  y = 185
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 29 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 83,
  y = 188
}, {
  dir = "N",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 29 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 83,
  y = 193
}, {
  dir = "N",
  items = { { "碎石", 10 }, { "沙子", 6 } },
  prototype_name = "粉碎机I",
  recipe = "沙子1",
  x = 117,
  y = 149
}, {
  dir = "N",
  items = { { "碎石", 10 }, { "沙子", 5 } },
  prototype_name = "粉碎机I",
  recipe = "沙子1",
  x = 120,
  y = 149
}, {
  dir = "N",
  items = { { "铝矿石", 14 }, { "碾碎铝矿石", 0 }, { "碾碎铁矿石", 2 }, { "沙子", 0 } },
  prototype_name = "粉碎机I",
  recipe = "碾碎铝矿石",
  x = 124,
  y = 147
}, {
  dir = "S",
  items = { { "demand", "碎石", 1 }, { "demand", "铝矿石", 3 }, { "supply", "碾碎铝矿石", 2 }, { "supply", "碾碎铁矿石", 1 } },
  prototype_name = "物流站",
  x = 120,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 148
}, {
  dir = "N",
  items = { { "沙子", 60 }, { "沙子", 60 } },
  prototype_name = "仓库I",
  x = 121,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 120,
  y = 148
}, {
  dir = "N",
  items = { { "demand", "钢板", 2 }, { "supply", "钢齿轮", 1 } },
  prototype_name = "物流站",
  x = 96,
  y = 120
}, {
  dir = "N",
  items = { { "钢板", 6 }, { "钢齿轮", 4 } },
  prototype_name = "组装机I",
  recipe = "钢齿轮",
  x = 94,
  y = 116
}, {
  dir = "N",
  items = { { "钢板", 6 }, { "钢齿轮", 3 } },
  prototype_name = "组装机I",
  recipe = "钢齿轮",
  x = 99,
  y = 116
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 98,
  y = 118
}, {
  dir = "N",
  items = { { "钢齿轮", 30 }, { "钢齿轮", 30 } },
  prototype_name = "仓库I",
  x = 98,
  y = 116
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 97,
  y = 118
}, {
  dir = "N",
  items = { { "铁板", 4 }, { "铁棒", 2 }, { "铁齿轮", 4 }, { "塑料", 0 } },
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
  items = { { "碎石", 2 } },
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
  items = { { "地下卤水", 3000 }, { "沙子", 16 }, { "废水", 0 }, { "硅", 11 } },
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
  items = { { "地下卤水", 3000 }, { "沙子", 16 }, { "废水", 0 }, { "硅", 12 } },
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
  items = { { "地下卤水", 140 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 126,
  y = 153
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 114,
  y = 153
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 153
}, {
  dir = "N",
  items = { { "坩埚", 15 }, { "坩埚", 15 }, { "硅", 30 }, { "硅", 30 } },
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
  prototype_name = "管道1-L型",
  x = 115,
  y = 152
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 152
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  items = { { "地下卤水", 500 }, { "蒸汽", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 100,
  y = 166
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 121,
  y = 152
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 117,
  y = 152
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 118,
  y = 152
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 122,
  y = 152
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 121,
  y = 157
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 124,
  y = 157
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 120,
  y = 157
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 89,
  y = 142
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
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
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JU型",
  x = 104,
  y = 155
}, {
  dir = "N",
  fluid_name = "丁二烯",
  prototype_name = "液罐I",
  x = 94,
  y = 171
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
  items = { { "一氧化碳", 0 }, { "氢气", 39 }, { "石墨", 0 }, { "纯水", 0 } },
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
  items = { { "demand", "石墨", 2 }, { "demand", "硅", 2 }, { "demand", "电容I", 1 }, { "demand", "绝缘线", 1 }, { "supply", "电子科技包", 1 } },
  prototype_name = "物流站",
  x = 122,
  y = 164
}, {
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "一氧化碳", "纯水" }
  },
  items = { { "二氧化碳", 4 }, { "氢气", 173 }, { "一氧化碳", 0 }, { "纯水", 0 } },
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
  items = { { "二氧化碳", 0 }, { "氢气", 60 }, { "一氧化碳", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转一氧化碳",
  x = 76,
  y = 169
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 166
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 79,
  y = 165
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
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 79,
  y = 167
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 79,
  y = 171
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
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 80,
  y = 171
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
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 143
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 83,
  y = 147
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 83,
  y = 142
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 146
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 141
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 92,
  y = 141
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 83,
  y = 141
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 93,
  y = 141
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
  x = 95,
  y = 145
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
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 88,
  y = 172
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
  items = { { "空气", 49 }, { "氮气", 0 }, { "二氧化碳", 0 } },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 85,
  y = 127
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-X型",
  x = 90,
  y = 133
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 132
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 90,
  y = 127
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 128
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 83,
  y = 130
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 90,
  y = 130
}, {
  dir = "N",
  items = { { "supply", "铁矿石", 1 }, { "supply", "石墨", 2 } },
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
  items = { { "铁矿石", 60 }, { "铁矿石", 60 }, { "石墨", 20 }, { "石墨", 21 } },
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
  items = { { "硅", 10 }, { "石墨", 4 }, { "硅板", 6 } },
  prototype_name = "熔炼炉I",
  recipe = "硅板1",
  x = 124,
  y = 167
}, {
  dir = "N",
  items = { { "铝矿石", 14 }, { "碾碎铝矿石", 0 }, { "碾碎铁矿石", 2 }, { "沙子", 0 } },
  prototype_name = "粉碎机I",
  recipe = "碾碎铝矿石",
  x = 124,
  y = 150
}, {
  dir = "N",
  items = { { "硅板", 30 }, { "硅板", 30 }, { "石墨", 30 } },
  prototype_name = "仓库I",
  x = 123,
  y = 166
}, {
  dir = "N",
  items = { { "铝矿石", 2 } },
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
  items = { { "铝矿石", 2 } },
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
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 101,
  y = 144
}, {
  dir = "S",
  items = { { "demand", "碾碎铝矿石", 4 } },
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
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 125,
  y = 157
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
  items = { { "demand", "玻璃", 1 }, { "demand", "钢板", 1 }, { "supply", "塑料", 1 } },
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
  items = { { "地下卤水", 500 }, { "氯气", 0 }, { "氢氧化钠", 2 } },
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
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-X型",
  x = 89,
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
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 147
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 97,
  y = 152
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 97,
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
  fluid_name = "氯气",
  prototype_name = "烟囱I",
  recipe = "氯气排泄",
  x = 96,
  y = 142
}, {
  dir = "N",
  items = { { "沙子", 60 }, { "沙子", 60 }, { "沙子", 60 }, { "沙子", 60 } },
  prototype_name = "仓库I",
  x = 123,
  y = 151
}, {
  dir = "S",
  fluid_name = {
    input = { "纯水" },
    output = { "碱性溶液" }
  },
  items = { { "纯水", 14 }, { "氢氧化钠", 6 }, { "碱性溶液", 0 } },
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
  items = { { "demand", "氢氧化钠", 2 } },
  prototype_name = "物流站",
  x = 90,
  y = 176
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 91,
  y = 178
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
  x = 125,
  y = 182
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 126,
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
  x = 136,
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
  x = 147,
  y = 182
}, {
  dir = "N",
  items = { { "氢氧化钠", 3 }, { "氢氧化钠", 2 }, { "氢氧化钠", 2 }, { "氢氧化钠", 2 } },
  prototype_name = "仓库I",
  x = 92,
  y = 178
}, {
  dir = "S",
  fluid_name = {
    input = { "碱性溶液" },
    output = { "废水" }
  },
  items = { { "碾碎铝矿石", 0 }, { "碱性溶液", 0 }, { "氢氧化铝", 0 }, { "废水", 0 } },
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
  items = { { "碾碎铝矿石", 0 }, { "碱性溶液", 0 }, { "氢氧化铝", 0 }, { "废水", 0 } },
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
  dir = "W",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 142,
  y = 165
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 149,
  y = 180
}, {
  dir = "E",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 171
}, {
  dir = "S",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 149,
  y = 172
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-L型",
  x = 155,
  y = 171
}, {
  dir = "W",
  fluid_name = "碱性溶液",
  prototype_name = "地下管1-JI型",
  x = 154,
  y = 171
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-L型",
  x = 148,
  y = 171
}, {
  dir = "N",
  fluid_name = "碱性溶液",
  prototype_name = "管道1-T型",
  x = 149,
  y = 171
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 152,
  y = 166
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 151,
  y = 166
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 145,
  y = 166
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 166
}, {
  dir = "N",
  items = { { "氢氧化铝", 2 }, { "氧化铝", 0 } },
  prototype_name = "熔炼炉I",
  recipe = "氧化铝",
  x = 145,
  y = 172
}, {
  dir = "N",
  items = { { "氢氧化铝", 3 }, { "氧化铝", 4 } },
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
  items = { { "氧化铝", 8 }, { "石墨", 10 }, { "铝板", 3 }, { "碳化铝", 2 } },
  prototype_name = "熔炼炉I",
  recipe = "铝板1",
  x = 148,
  y = 173
}, {
  dir = "N",
  items = { { "氧化铝", 13 }, { "石墨", 5 }, { "铝板", 5 }, { "碳化铝", 1 } },
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
  items = { { "碳化铝", 5 }, { "纯水", 0 }, { "氢氧化铝", 0 }, { "甲烷", 0 } },
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
  items = { { "碳化铝", 10 }, { "纯水", 0 }, { "氢氧化铝", 0 }, { "甲烷", 0 } },
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
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 87,
  y = 183
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 131,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 184
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 184
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 87,
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
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 132,
  y = 184
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 121,
  y = 184
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 142,
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
  prototype_name = "无人机平台I",
  x = 123,
  y = 149
}, {
  dir = "N",
  items = { { "supply", "铝板", 2 }, { "demand", "石墨", 2 }, { "supply", "氧化铝", 2 } },
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
  items = { { "demand", "铝板", 2 }, { "demand", "钢齿轮", 1 }, { "demand", "氧化铝", 1 }, { "demand", "石墨", 1 }, { "demand", "塑料", 1 } },
  prototype_name = "物流站",
  x = 164,
  y = 168
}, {
  dir = "N",
  items = { { "铝棒", 10 }, { "铝丝", 10 } },
  prototype_name = "组装机I",
  recipe = "铝丝1",
  x = 166,
  y = 173
}, {
  dir = "N",
  items = { { "铝板", 8 }, { "铝棒", 7 } },
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
  dir = "W",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 141,
  y = 187
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 143,
  y = 184
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
  fluid_name = "",
  items = {},
  prototype_name = "化工厂I",
  x = 152,
  y = 185
}, {
  dir = "N",
  items = { { "石墨", 2 }, { "氧化铝", 2 }, { "塑料", 1 }, { "铝板", 4 }, { "电容I", 0 }, { "铝棒", 0 }, { "钢齿轮", 8 } },
  prototype_name = "组装机I",
  recipe = "电容1",
  x = 169,
  y = 166
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 146,
  y = 124
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
  items = { { "氧化铝", 30 }, { "石墨", 30 }, { "塑料", 0 } },
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
  items = { { "二氧化碳", 8 }, { "氢气", 500 }, { "甲烷", 0 }, { "纯水", 0 } },
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
  items = { { "丁二烯", 0 }, { "橡胶", 2 } },
  prototype_name = "浮选器I",
  recipe = "橡胶",
  x = 100,
  y = 169
}, {
  dir = "E",
  fluid_name = "丁二烯",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 172
}, {
  dir = "W",
  fluid_name = "丁二烯",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 172
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
  items = { { "demand", "橡胶", 2 }, { "supply", "电容I", 1 }, { "supply", "绝缘线", 1 } },
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
  items = { { "硅板", 2 }, { "盐酸", 0 }, { "甲烷", 0 }, { "润滑油", 0 } },
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
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 159
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "管道1-L型",
  x = 110,
  y = 147
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 158
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 148
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
  dir = "W",
  fluid_name = "盐酸",
  prototype_name = "管道1-L型",
  x = 119,
  y = 171
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 169
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 111,
  y = 171
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "管道1-I型",
  x = 110,
  y = 170
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "管道1-L型",
  x = 110,
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
  items = { { "电容I", 1 }, { "绝缘线", 4 }, { "润滑油", 0 }, { "电子科技包", 0 } },
  prototype_name = "组装机I",
  recipe = "电子科技包1",
  x = 128,
  y = 164
}, {
  dir = "N",
  fluid_name = "润滑油",
  prototype_name = "管道1-I型",
  x = 119,
  y = 166
}, {
  dir = "E",
  fluid_name = "润滑油",
  prototype_name = "地下管1-JI型",
  x = 120,
  y = 165
}, {
  dir = "W",
  fluid_name = "润滑油",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 165
}, {
  dir = "E",
  fluid_name = "润滑油",
  prototype_name = "管道1-L型",
  x = 119,
  y = 165
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
  items = { { "电子科技包", 17 } },
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
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 79,
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
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 75,
  y = 151
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
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 91,
  y = 162
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 92,
  y = 162
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 95,
  y = 162
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 94,
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
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 156
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 71,
  y = 156
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 80,
  y = 156
}, {
  dir = "N",
  fluid_name = "丁二烯",
  prototype_name = "管道1-I型",
  x = 95,
  y = 170
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
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 148
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 106,
  y = 147
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
  items = { { "地下卤水", 190 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 103,
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
  dir = "E",
  fluid_name = {
    input = { "氧气", "甲烷" },
    output = { "乙烯", "纯水" }
  },
  items = { { "氧气", 101 }, { "甲烷", 0 }, { "乙烯", 0 }, { "纯水", 0 } },
  prototype_name = "化工厂I",
  recipe = "甲烷转乙烯",
  x = 85,
  y = 165
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 69,
  y = 158
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 69,
  y = 168
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 73,
  y = 169
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 83,
  y = 169
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 70,
  y = 169
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 72,
  y = 169
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 69,
  y = 169
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 84,
  y = 169
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
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 88,
  y = 161
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 89,
  y = 161
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
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 90,
  y = 165
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 89,
  y = 165
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 165
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 164
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 99,
  y = 165
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 154
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 149
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 153
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 148
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
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 88,
  y = 167
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
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 179
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-L型",
  x = 84,
  y = 180
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
}}
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
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 116,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 102,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 124
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 102,
  y = 122
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
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 72,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 70,
  y = 122
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 68,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 66,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 118
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
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 92,
  y = 120
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
  prototype_name = "砖石公路-T型",
  x = 76,
  y = 122
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
  prototype_name = "砖石公路-T型",
  x = 104,
  y = 126
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
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 154,
  y = 114
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
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 154,
  y = 146
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
  y = 190
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
    name = "中规模测试",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 8,
    guide = guide,
    start_tech = "地质研究",
    research_queue = {
      "登录科技开启",
    },
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