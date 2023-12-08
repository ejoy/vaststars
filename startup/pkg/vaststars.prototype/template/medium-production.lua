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
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 138,
  y = 140
}, {
  dir = "N",
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
  items = { { "铁矿石", 1 }, { "铝矿石", 58 }, { "铁板", 1 }, { "碎石", 60 } },
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
  prototype_name = "组装机I",
  recipe = "铁棒1",
  x = 118,
  y = 130
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "地质科技包1",
  x = 122,
  y = 130
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "石砖",
  x = 118,
  y = 135
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "机械科技包T1",
  x = 122,
  y = 135
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板T1",
  x = 115,
  y = 130
}, {
  dir = "N",
  prototype_name = "科研中心I",
  x = 125,
  y = 133
}, {
  dir = "N",
  items = { { "石砖", 30 }, { "铁棒", 30 }, { "机械科技包", 0 }, { "地质科技包", 27 } },
  prototype_name = "仓库I",
  x = 121,
  y = 134
}, {
  dir = "N",
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
  items = { { "demand", "铝矿石", 2 }, { "demand", "铁板", 1 }, { "supply", "碎石", 2 }, { "demand", "铁矿石", 1 } },
  prototype_name = "物流站",
  x = 120,
  y = 128
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 131
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板T1",
  x = 107,
  y = 130
}, {
  dir = "N",
  items = { { "管道1-X型", 27 }, { "气候科技包", 29 }, { "地下管1-JI型", 0 }, { "液罐I", 0 } },
  prototype_name = "仓库I",
  x = 125,
  y = 136
}, {
  dir = "N",
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
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 132,
  y = 141
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 78,
  y = 177
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 81,
  y = 177
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 84,
  y = 177
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 87,
  y = 177
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 81,
  y = 174
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 78,
  y = 174
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 84,
  y = 174
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 87,
  y = 174
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 78,
  y = 180
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 80,
  y = 180
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 82,
  y = 180
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 84,
  y = 180
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 86,
  y = 180
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 88,
  y = 180
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 78,
  y = 182
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 80,
  y = 182
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 82,
  y = 182
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 84,
  y = 182
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
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
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 89,
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
  prototype_name = "液罐I",
  x = 83,
  y = 161
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
  prototype_name = "化工厂I",
  recipe = "二氧化碳转甲烷",
  x = 85,
  y = 152
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 151
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 153
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 160
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 84,
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
  dir = "W",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 154
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
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 80,
  y = 154
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 79,
  y = 153
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 79,
  y = 154
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
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
  prototype_name = "化工厂I",
  recipe = "甲烷转乙烯",
  x = 85,
  y = 156
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "排水口I",
  recipe = "纯水排泄",
  x = 73,
  y = 150
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 84,
  y = 142
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 84,
  y = 141
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 85,
  y = 141
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 156
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 98,
  y = 156
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 99,
  y = 156
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 99,
  y = 155
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
  y = 148
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
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 93,
  y = 141
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 92,
  y = 141
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 88,
  y = 158
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 157
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
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 88,
  y = 152
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
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 84,
  y = 158
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 76,
  y = 158
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 158
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 157
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 77,
  y = 151
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 76,
  y = 151
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 76,
  y = 152
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 84,
  y = 156
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 84,
  y = 155
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 85,
  y = 155
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "液罐I",
  x = 105,
  y = 154
}, {
  dir = "W",
  fluid_name = {
    input = { "乙烯", "氯气" },
    output = { "盐酸" }
  },
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
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 153
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
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "排水口I",
  recipe = "盐酸排泄",
  x = 110,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 111,
  y = 143
}, {
  dir = "N",
  items = { { "塑料", 15 }, { "塑料", 15 } },
  prototype_name = "仓库I",
  x = 113,
  y = 141
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 115,
  y = 139
}, {
  dir = "N",
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
  items = { { "铁齿轮", 0 }, { "铁齿轮", 0 }, { "电动机I", 15 }, { "采矿机I", 0 } },
  prototype_name = "仓库I",
  x = 121,
  y = 137
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 122,
  y = 139
}, {
  dir = "E",
  fluid_name = {
    input = { "乙烯", "蒸汽" },
    output = { "丁二烯", "氢气" }
  },
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
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 90,
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
  items = { { "demand", "铁板", 2 }, { "supply", "钢板", 2 } },
  prototype_name = "物流站",
  x = 96,
  y = 124
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板T1",
  x = 111,
  y = 130
}, {
  dir = "S",
  items = { { "demand", "铁矿石", 2 }, { "supply", "碎石", 2 }, { "supply", "铁板", 2 } },
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
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 83,
  y = 193
}, {
  dir = "N",
  prototype_name = "粉碎机I",
  recipe = "沙子1",
  x = 117,
  y = 149
}, {
  dir = "N",
  prototype_name = "粉碎机I",
  recipe = "沙子1",
  x = 120,
  y = 149
}, {
  dir = "N",
  prototype_name = "粉碎机I",
  recipe = "沙子1",
  x = 123,
  y = 149
}, {
  dir = "S",
  items = { { "demand", "碎石", 2 } },
  prototype_name = "物流站",
  x = 120,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 122,
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
  items = { { "demand", "钢板", 2 } },
  prototype_name = "物流站",
  x = 96,
  y = 120
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "钢齿轮",
  x = 94,
  y = 116
}, {
  dir = "N",
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
  items = { { "钢齿轮", 29 }, { "钢齿轮", 29 } },
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
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 115,
  y = 133
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 125,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 135
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 136
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 134,
  y = 128
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 91,
  y = 165
}, {
  dir = "N",
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
  prototype_name = "浮选器I",
  recipe = "硅1",
  x = 122,
  y = 153
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 126,
  y = 156
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
  prototype_name = "无人机平台I",
  x = 121,
  y = 158
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "熔炼炉I",
  x = 107,
  y = 133
}, {
  dir = "N",
  items = { { "硅", 0 }, { "硅", 0 }, { "坩埚", 14 }, { "坩埚", 14 } },
  prototype_name = "仓库I",
  x = 122,
  y = 158
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "坩埚",
  x = 118,
  y = 158
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 121,
  y = 156
}, {
  dir = "N",
  prototype_name = "物流站",
  x = 122,
  y = 160
}, {
  dir = "W",
  amount = 15,
  prototype_name = "物流中心",
  x = 152,
  y = 130
}, {
  dir = "N",
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
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 86,
  y = 165
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
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 125,
  y = 157
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
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 159
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 158
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 89,
  y = 166
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 89,
  y = 165
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
  y = 146
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 89,
  y = 147
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "烟囱I",
  x = 80,
  y = 161
}, {
  dir = "N",
  fluid_name = "蒸汽",
  prototype_name = "液罐I",
  x = 105,
  y = 163
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 95,
  y = 162
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 86,
  y = 162
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
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-L型",
  x = 87,
  y = 164
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "地下管1-JI型",
  x = 88,
  y = 164
}, {
  dir = "W",
  fluid_name = "蒸汽",
  prototype_name = "地下管1-JI型",
  x = 96,
  y = 164
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "地下管1-JI型",
  x = 97,
  y = 164
}, {
  dir = "N",
  fluid_name = "蒸汽",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 163
}, {
  dir = "W",
  fluid_name = "蒸汽",
  prototype_name = "地下管1-JI型",
  x = 100,
  y = 164
}, {
  dir = "S",
  fluid_name = "蒸汽",
  prototype_name = "管道1-T型",
  x = 101,
  y = 164
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
  prototype_name = "地下管1-JI型",
  x = 93,
  y = 155
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 94,
  y = 155
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 100,
  y = 155
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 156
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "管道1-T型",
  x = 101,
  y = 155
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 102,
  y = 155
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 104,
  y = 155
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 101,
  y = 159
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 101,
  y = 158
}, {
  dir = "N",
  fluid_name = "丁二烯",
  prototype_name = "液罐I",
  x = 94,
  y = 171
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
  prototype_name = "砖石公路-T型",
  x = 154,
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
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 154,
  y = 138
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
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 136,
  y = 162
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
  prototype_name = "砖石公路-L型",
  x = 104,
  y = 150
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
  prototype_name = "砖石公路-L型",
  x = 112,
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