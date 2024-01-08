local guide = require "guide.guide5"
local mountain = require "mountain"

local items = {}
for _ = 1, 16 do
  items[#items+1] = {"", 0}
end

local entities = { {
  dir = "N",
  items = items,
  prototype_name = "指挥中心",
  x = 108,
  y = 120
},{
  amount = 0,
  dir = "N",
  prototype_name = "物流中心",
  x = 124,
  y = 128
}, {
  dir = "N",
  items = { { "物流站", 15 }, { "运输车辆I", 30 }, { "无人机平台I", 20 },{ "砖石公路-X型", 100 }},
  prototype_name = "机头残骸",
  x = 120,
  y = 121
}, {
  dir = "W",
  items = { { "烟囱I", 3 }, { "水电站I", 2 }, { "空气过滤器I", 5 }, { "地下水挖掘机I", 7 } },
  prototype_name = "机翼残骸",
  x = 146,
  y = 118
}, {
  dir = "W",
  items = { { "仓库I", 20 }, { "蓄电池I", 15 }, { "太阳能板I", 5 }, { "蒸汽发电机I", 4 } },
  prototype_name = "机身残骸",
  x = 43,
  y = 169
}, {
  dir = "E",
  items = { { "管道1-X型", 30 }, { "地下管1-JI型", 30 }, { "烟囱I", 4 }, { "排水口I", 2 } },
  prototype_name = "机身残骸",
  x = 152,
  y = 170
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 115,
  y = 133
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 72,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 75,
  y = 130
}, {
  dir = "N",
  items = { { "碎石", 60 } },
  prototype_name = "仓库I",
  x = 75,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 94,
  y = 129
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 100,
  y = 129
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 97,
  y = 134
}, {
  dir = "N",
  items = { { "石砖", 18 } },
  prototype_name = "仓库I",
  x = 98,
  y = 134
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 145,
  y = 149
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 93,
  y = 131
}, {
  dir = "E",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 96,
  y = 131
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "石砖",
  x = 99,
  y = 131
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 100,
  y = 134
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 192,
  y = 132
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "碎石挖掘",
  x = 170,
  y = 112
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 164,
  y = 127
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 197,
  y = 117
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 172,
  y = 76
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 75,
  y = 93
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 61,
  y = 118
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 91,
  y = 165
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 138,
  y = 174
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 180,
  y = 193
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 209,
  y = 162
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 102,
  y = 62
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 97,
  y = 60
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 150,
  y = 95
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 62,
  y = 185
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 95,
  y = 164
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 96,
  y = 158
}, {
  dir = "N",
  items = { { "铁矿石", 0 }, { "碎石", 0 } },
  prototype_name = "仓库I",
  x = 96,
  y = 159
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 107,
  y = 158
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "粉碎机I",
  x = 94,
  y = 154
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "粉碎机I",
  x = 97,
  y = 154
}, {
  dir = "N",
  prototype_name = "粉碎机I",
  recipe = "碾碎铁矿石",
  x = 104,
  y = 154
}, {
  dir = "N",
  prototype_name = "粉碎机I",
  recipe = "碾碎铁矿石",
  x = 107,
  y = 154
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 97,
  y = 158
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 98,
  y = 152
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 0 } },
  prototype_name = "仓库I",
  x = 97,
  y = 152
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 105,
  y = 152
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 0 } },
  prototype_name = "仓库I",
  x = 106,
  y = 152
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 108,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 109,
  y = 148
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 0 }, { "碎石", 0 } },
  prototype_name = "仓库I",
  x = 108,
  y = 149
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 95,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 94,
  y = 148
}, {
  dir = "N",
  items = { { "碾碎铁矿石", 0 }, { "碎石", 0 }, { "碎石", 0 } },
  prototype_name = "仓库I",
  x = 95,
  y = 149
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 93,
  y = 148
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 94,
  y = 145
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "熔炼炉I",
  x = 97,
  y = 145
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板2",
  x = 104,
  y = 145
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 107,
  y = 145
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板2",
  x = 110,
  y = 145
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板2",
  x = 91,
  y = 145
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 92,
  y = 143
}, {
  dir = "N",
  items = { { "铁板", 0 }, { "铁板", 0 } },
  prototype_name = "仓库I",
  x = 93,
  y = 143
}, {
  dir = "N",
  items = { { "石墨", 24 } },
  prototype_name = "仓库I",
  x = 95,
  y = 143
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 108,
  y = 143
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 94,
  y = 143
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 96,
  y = 143
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 106,
  y = 143
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 110,
  y = 143
}, {
  dir = "N",
  items = { { "铁板", 0 }, { "铁板", 0 } },
  prototype_name = "仓库I",
  x = 109,
  y = 143
}, {
  dir = "N",
  items = { { "石墨", 18 } },
  prototype_name = "仓库I",
  x = 107,
  y = 143
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 70,
  y = 92
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 73,
  y = 92
}, {
  dir = "N",
  items = { { "铁矿石", 60 } },
  prototype_name = "仓库I",
  x = 72,
  y = 92
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "化工厂I",
  x = 128,
  y = 156
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "化工厂I",
  x = 124,
  y = 156
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 145,
  y = 163
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "氮气", "二氧化碳" }
  },
  prototype_name = "蒸馏厂I",
  recipe = "空气分离1",
  x = 145,
  y = 169
}, {
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "一氧化碳", "纯水" }
  },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转一氧化碳",
  x = 147,
  y = 176
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 161,
  y = 163
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 161,
  y = 170
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "液罐I",
  x = 157,
  y = 154
}, {
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "甲烷", "纯水" }
  },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转甲烷",
  x = 147,
  y = 184
}, {
  dir = "E",
  fluid_name = "",
  prototype_name = "化工厂I",
  x = 147,
  y = 188
}, {
  dir = "W",
  fluid_name = {
    input = { "氧气", "甲烷" },
    output = { "乙烯", "纯水" }
  },
  prototype_name = "化工厂I",
  recipe = "甲烷转乙烯",
  x = 161,
  y = 180
}, {
  dir = "W",
  fluid_name = "",
  prototype_name = "化工厂I",
  x = 175,
  y = 165
}, {
  dir = "W",
  fluid_name = "",
  prototype_name = "化工厂I",
  x = 175,
  y = 169
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 143,
  y = 166
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-L型",
  x = 150,
  y = 163
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 164
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 168
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 170
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 150,
  y = 169
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 175
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 150,
  y = 176
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 177
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "液罐I",
  x = 149,
  y = 198
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 166,
  y = 154
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 167,
  y = 157
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 165,
  y = 163
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 166,
  y = 163
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 167,
  y = 162
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 167,
  y = 164
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 167,
  y = 163
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 167,
  y = 169
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "液罐I",
  x = 166,
  y = 189
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 159,
  y = 166
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 160,
  y = 166
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 157
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 165
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 158,
  y = 166
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 167
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 172
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 160,
  y = 163
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 164
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 169
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "液罐I",
  x = 159,
  y = 189
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 165,
  y = 167
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 165,
  y = 166
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 165,
  y = 172
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 150,
  y = 178
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 151,
  y = 178
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 151,
  y = 186
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 151,
  y = 190
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 166
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 167
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 177
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 152,
  y = 178
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 179
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 181
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 183
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 152,
  y = 182
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 185
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 152,
  y = 186
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 187
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 189
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 152,
  y = 190
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 156,
  y = 155
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 152,
  y = 156
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 153,
  y = 155
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 146,
  y = 178
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 179
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 181
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 183
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 146,
  y = 182
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 185
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 146,
  y = 186
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 187
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 189
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-U型",
  x = 146,
  y = 190
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "液罐I",
  x = 145,
  y = 198
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "液罐I",
  x = 145,
  y = 201
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 148,
  y = 202
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 201
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 164,
  y = 202
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 163,
  y = 202
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 179
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 159,
  y = 202
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 202
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "液罐I",
  x = 173,
  y = 154
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 166
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 180
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 181
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 169,
  y = 190
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 189
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 174,
  y = 190
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 173,
  y = 190
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 170
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "液罐I",
  x = 170,
  y = 193
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JU型",
  x = 174,
  y = 171
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 168
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 170
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 172,
  y = 171
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "液罐I",
  x = 142,
  y = 151
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 176
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 144,
  y = 176
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 177
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-T型",
  x = 143,
  y = 176
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 175
}, {
  dir = "N",
  fluid_name = {
    input = { "一氧化碳", "氢气" },
    output = { "纯水" }
  },
  prototype_name = "化工厂I",
  recipe = "一氧化碳转石墨",
  x = 120,
  y = 156
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 140,
  y = 155
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 141,
  y = 155
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 152,
  y = 155
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 151,
  y = 155
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 142,
  y = 154
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-T型",
  x = 143,
  y = 154
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 155
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 165
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 164
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 129,
  y = 160
}, {
  dir = "N",
  items = { { "石墨", 0 } },
  prototype_name = "仓库I",
  x = 129,
  y = 161
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 122,
  y = 160
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 122,
  y = 161
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 146,
  y = 184
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-U型",
  x = 146,
  y = 188
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "液罐I",
  x = 157,
  y = 195
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-U型",
  x = 146,
  y = 194
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 145,
  y = 193
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 145,
  y = 194
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 145,
  y = 189
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 145,
  y = 187
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
  x = 145,
  y = 188
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 145,
  y = 185
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 145,
  y = 184
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 159,
  y = 180
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 179,
  y = 167
}, {
  dir = "N",
  items = { { "塑料", 0 } },
  prototype_name = "仓库I",
  x = 179,
  y = 165
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "铁齿轮",
  x = 109,
  y = 140
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 92,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 105,
  y = 134
}, {
  dir = "N",
  items = { { "铁齿轮", 0 } },
  prototype_name = "仓库I",
  x = 107,
  y = 134
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 102,
  y = 133
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "电动机1",
  x = 102,
  y = 130
}, {
  dir = "N",
  items = { { "电动机I", 0 } },
  prototype_name = "仓库I",
  x = 105,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 105,
  y = 130
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 186,
  y = 163
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 186,
  y = 169
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 186,
  y = 160
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "机械科技包1",
  x = 186,
  y = 172
}, {
  dir = "W",
  fluid_name = {
    input = { "乙烯", "氯气" },
    output = { "盐酸" }
  },
  prototype_name = "化工厂I",
  recipe = "塑料1",
  x = 175,
  y = 161
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 189,
  y = 171
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 189,
  y = 160
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 189,
  y = 173
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 189,
  y = 175
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 164,
  y = 180
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 181
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 183
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 164,
  y = 184
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 185
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 192
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 191
}, {
  dir = "W",
  fluid_name = "",
  prototype_name = "化工厂I",
  x = 161,
  y = 184
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 183
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 185
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 160,
  y = 187
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 160,
  y = 186
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 160,
  y = 188
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 159,
  y = 184
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-U型",
  x = 160,
  y = 184
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "管道1-U型",
  x = 158,
  y = 194
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 183
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 158,
  y = 184
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 181
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 172
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "管道1-T型",
  x = 171,
  y = 171
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 164,
  y = 182
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JU型",
  x = 164,
  y = 186
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 192
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 183
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 181
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-T型",
  x = 171,
  y = 182
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 170,
  y = 182
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 185
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 187
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 170,
  y = 186
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-T型",
  x = 171,
  y = 186
}, {
  dir = "W",
  fluid_name = {
    input = { "地下卤水" },
    output = { "氧气", "氢气", "氯气" }
  },
  prototype_name = "电解厂I",
  recipe = "地下卤水电解1",
  x = 161,
  y = 175
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 160,
  y = 182
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 181
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 176
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 174
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 160,
  y = 175
}, {
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 160,
  y = 170
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "地下管1-JI型",
  x = 160,
  y = 171
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 174
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 158,
  y = 173
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-U型",
  x = 158,
  y = 178
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 177
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 165,
  y = 174
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 165,
  y = 173
}, {
  dir = "E",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 165,
  y = 178
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 165,
  y = 177
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 165,
  y = 179
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "管道1-L型",
  x = 165,
  y = 190
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 165,
  y = 189
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 167,
  y = 171
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 167,
  y = 170
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-U型",
  x = 167,
  y = 175
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 167,
  y = 174
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 144,
  y = 202
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 137,
  y = 202
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 138,
  y = 202
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 193
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 192
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 171
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 182
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 170
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 181
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 120,
  y = 159
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 121,
  y = 159
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 123,
  y = 159
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-I型",
  x = 124,
  y = 159
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 125,
  y = 159
}, {
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 159
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 160
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 128,
  y = 159
}, {
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 129,
  y = 202
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "管道1-L型",
  x = 128,
  y = 202
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 201
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 168
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 174,
  y = 169
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "管道1-I型",
  x = 174,
  y = 165
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 164
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 157
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 160
}, {
  dir = "S",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 162
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 174,
  y = 161
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 163
}, {
  dir = "W",
  fluid_name = "乙烯",
  prototype_name = "管道1-T型",
  x = 171,
  y = 167
}, {
  dir = "N",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 166
}, {
  dir = "S",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 171,
  y = 164
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "管道1-L型",
  x = 171,
  y = 163
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 172,
  y = 163
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "管道1-U型",
  x = 178,
  y = 171
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 178,
  y = 172
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 160,
  y = 180
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
  x = 122,
  y = 155
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 123,
  y = 155
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 155
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 125,
  y = 155
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 126,
  y = 155
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 131,
  y = 155
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 130,
  y = 155
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 129,
  y = 155
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-U型",
  x = 128,
  y = 155
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-U型",
  x = 124,
  y = 155
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-I型",
  x = 120,
  y = 155
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-L型",
  x = 120,
  y = 154
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 121,
  y = 154
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 123,
  y = 154
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-T型",
  x = 124,
  y = 154
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 125,
  y = 154
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 154
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-T型",
  x = 128,
  y = 154
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 129,
  y = 154
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 136,
  y = 154
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 137,
  y = 154
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "烟囱I",
  recipe = "氢气排泄",
  x = 157,
  y = 151
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-L型",
  x = 158,
  y = 180
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 183
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 185
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 150,
  y = 184
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 187
}, {
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-U型",
  x = 150,
  y = 188
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 150,
  y = 186
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-U型",
  x = 150,
  y = 190
}, {
  dir = "S",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 170
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 169
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 63,
  y = 159
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 60,
  y = 159
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 57,
  y = 159
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 66,
  y = 163
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 63,
  y = 163
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 57,
  y = 163
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 54,
  y = 163
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 51,
  y = 159
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 61,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 57,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 55,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 51,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 49,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 167
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 63,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 61,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 57,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 53,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 51,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 49,
  y = 170
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 69,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 63,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 61,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 59,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 57,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 55,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 53,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 37,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 37,
  y = 168
}, {
  dir = "S",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 37,
  y = 163
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 30,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 23,
  y = 173
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 71,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 67,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 65,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 63,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 59,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 57,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 55,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 51,
  y = 176
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 49,
  y = 176
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 167,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 168,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 169,
  y = 137
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 167,
  y = 136
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 168,
  y = 136
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 169,
  y = 136
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 174,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 175,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 176,
  y = 137
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 174,
  y = 136
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 175,
  y = 136
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 176,
  y = 136
}, {
  dir = "N",
  prototype_name = "科研中心I",
  x = 165,
  y = 138
}, {
  dir = "N",
  prototype_name = "科研中心I",
  x = 168,
  y = 138
}, {
  dir = "N",
  prototype_name = "科研中心I",
  x = 173,
  y = 138
}, {
  dir = "N",
  prototype_name = "科研中心I",
  x = 176,
  y = 138
}, {
  dir = "S",
  items = { { "supply", "铁矿石", 2 } },
  prototype_name = "物流站",
  x = 90,
  y = 162
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 106,
  y = 158
}, {
  dir = "N",
  items = { { "铁矿石", 0 }, { "碎石", 0 } },
  prototype_name = "仓库I",
  x = 106,
  y = 159
}, {
  dir = "S",
  items = { { "supply", "碾碎铁矿石", 4 } },
  prototype_name = "物流站",
  x = 100,
  y = 152
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "机械科技包1",
  x = 186,
  y = 157
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 186,
  y = 175
}, {
  dir = "S",
  fluid_name = {
    input = { "地热" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "地热气发电",
  x = 210,
  y = 131
}, {
  dir = "S",
  fluid_name = {
    input = { "地热" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "地热气发电",
  x = 210,
  y = 126
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 189,
  y = 158
}, {
  dir = "W",
  items = { { "supply", "塑料", 2 } },
  prototype_name = "物流站",
  x = 180,
  y = 164
}, {
  dir = "W",
  items = {},
  prototype_name = "物流站",
  x = 190,
  y = 168
}, {
  dir = "W",
  items = { { "demand", "电动机I", 2 }, { "supply", "机械科技包", 2 }, { "demand", "塑料", 2 } },
  prototype_name = "物流站",
  x = 190,
  y = 162
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 124,
  y = 160
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 148,
  y = 122
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 178,
  y = 134
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 174,
  y = 134
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 170,
  y = 134
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 166,
  y = 134
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 162,
  y = 134
}, {
  dir = "S",
  items = { { "supply", "碎石", 2 } },
  prototype_name = "物流站",
  x = 74,
  y = 128
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 160,
  y = 192
}, {
  dir = "S",
  items = { { "demand", "石墨", 1 } },
  prototype_name = "物流站",
  x = 96,
  y = 140
}, {
  dir = "S",
  items = { { "demand", "石墨", 1 } },
  prototype_name = "物流站",
  x = 104,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 90,
  y = 142
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 112,
  y = 142
}, {
  dir = "S",
  items = { { "supply", "铁齿轮", 2 } },
  prototype_name = "物流站",
  x = 88,
  y = 140
}, {
  dir = "S",
  items = { { "supply", "铁齿轮", 2 } },
  prototype_name = "物流站",
  x = 112,
  y = 140
}, {
  dir = "N",
  items = { { "demand", "铁齿轮", 1 } },
  prototype_name = "物流站",
  x = 104,
  y = 136
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 96,
  y = 148
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 104,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 110,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 189,
  y = 162
}, {
  dir = "N",
  items = { { "机械科技包", 0 } },
  prototype_name = "仓库I",
  x = 190,
  y = 160
}, {
  dir = "N",
  items = { { "机械科技包", 0 } },
  prototype_name = "仓库I",
  x = 190,
  y = 173
}, {
  dir = "S",
  items = { { "supply", "电动机I", 1 } },
  prototype_name = "物流站",
  x = 102,
  y = 128
}, {
  dir = "S",
  items = { { "demand", "碎石", 2 } },
  prototype_name = "物流站",
  x = 96,
  y = 128
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 179,
  y = 163
}, {
  dir = "N",
  items = { { "气候科技包", 5 } },
  prototype_name = "仓库I",
  x = 150,
  y = 119
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 150,
  y = 121
}, {
  dir = "N",
  items = { { "铁齿轮", 0 } },
  prototype_name = "仓库I",
  x = 88,
  y = 142
}, {
  dir = "N",
  items = { { "铁齿轮", 0 } },
  prototype_name = "仓库I",
  x = 114,
  y = 142
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 92,
  y = 158
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 108,
  y = 158
}, {
  dir = "E",
  items = { { "supply", "铁矿石", 1 } },
  prototype_name = "物流站",
  x = 68,
  y = 92
}, {
  dir = "N",
  items = { { "demand", "碎石", 1 }, { "demand", "铁矿石", 1 }, { "supply", "地质科技包", 1 } },
  prototype_name = "物流站",
  x = 124,
  y = 150
}, {
  dir = "N",
  items = { { "碎石", 1 }, { "铁矿石", 1 }, { "铝矿石", 0 } },
  prototype_name = "仓库I",
  x = 123,
  y = 148
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "地质科技包1",
  x = 124,
  y = 145
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 127,
  y = 145
}, {
  dir = "N",
  items = { { "地质科技包", 0 } },
  prototype_name = "仓库I",
  x = 130,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 125,
  y = 148
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 128,
  y = 148
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "液罐I",
  x = 177,
  y = 178
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 178,
  y = 177
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 110,
  y = 92
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 131,
  y = 100
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 126,
  y = 98
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 92,
  y = 100
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 130,
  y = 100
}, {
  dir = "N",
  items = { { "铝矿石", 60 } },
  prototype_name = "仓库I",
  x = 93,
  y = 100
}, {
  dir = "N",
  items = { { "铝矿石", 60 } },
  prototype_name = "仓库I",
  x = 130,
  y = 99
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铝矿挖掘",
  x = 93,
  y = 102
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 125,
  y = 149
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 128,
  y = 149
},{
  dir = "N",
  prototype_name = "无人机平台I",
  x = 149,
  y = 99
}, {
  dir = "W",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  prototype_name = "水电站I",
  recipe = "气候科技包1",
  x = 140,
  y = 117
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 146,
  y = 122
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 152,
  y = 122
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地热" }
  },
  prototype_name = "地热井I",
  recipe = "地热采集",
  x = 209,
  y = 141
}, {
  dir = "S",
  fluid_name = {
    input = { "地热" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "地热气发电",
  x = 210,
  y = 136
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "水电站I",
  x = 151,
  y = 117
} }

local road = { {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 92
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 96
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 100
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 104
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 108
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 112
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 116
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 74,
  y = 156
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 84,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 86,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 90,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 94,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 156
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 156
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 164,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 174,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 180,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 184,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 188,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 190,
  y = 124
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 192,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 176
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 168
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 176
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 154
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 152
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 118,
  y = 152
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 144
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 148
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 164
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 168
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 186,
  y = 124
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 76,
  y = 156
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 178,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 178,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 176,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 174,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 168,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 140,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 114,
  y = 124
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 140,
  y = 152
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 140,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 164
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 172
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 168,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 172
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 176,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 160
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 66,
  y = 90
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 94
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 98
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 102
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 106
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 66,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 74,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 146
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 74,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 94,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 154
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 118,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 154
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 132,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 132,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 166
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 170
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 132,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 164,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 168,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 172,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 158
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 192,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 194,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 196,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 198,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 200,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 202,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 204,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 206,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 174
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 170
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 176,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 76,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 78,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 80,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 158,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 164,
  y = 124
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 166,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 152
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 132,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 118,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 82,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 152
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 144
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 148
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 140
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 178,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 74,
  y = 152
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 184,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 140,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 146
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 186,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 174,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 208,
  y = 158
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 210,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 164
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 168
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 170
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 172
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 174
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 182,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 162
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 78,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 80,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 82,
  y = 126
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 114,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 86,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 90,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 126
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 106,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 154
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 156
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 154
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 156
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 178
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 190,
  y = 180
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 184,
  y = 180
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 192,
  y = 180
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 186,
  y = 180
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 188,
  y = 180
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 192,
  y = 178
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 192,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 190,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 184,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 186,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 188,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 70,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 72,
  y = 126
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 66,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 68,
  y = 126
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 166,
  y = 112
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 116
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 114
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 78,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 80,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 82,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 86,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 88,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 90,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 92,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 94,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 76,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 178,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 180,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 124
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 106,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 66,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 68,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 72,
  y = 138
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 70,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 102
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 100
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 96,
  y = 98
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 96
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 96,
  y = 96
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 96,
  y = 94
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 182,
  y = 166
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 184,
  y = 166
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 186,
  y = 166
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 192,
  y = 166
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 188,
  y = 166
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 190,
  y = 166
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 134
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 136,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 132
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 136,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 130
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 118,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 120,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 120,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 84,
  y = 134
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 84,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 84,
  y = 136
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 182,
  y = 180
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 182
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 184
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 186
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 188
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 182,
  y = 190
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 96
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 136,
  y = 96
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 136,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 96
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 148,
  y = 96
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 192,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 142,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 142,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 162,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 162,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 148
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 146
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 144
}, {
  dir = "N",
  prototype_name = "砖石公路-X型",
  x = 118,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 140
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 94,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 182,
  y = 134
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 182,
  y = 152
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 160,
  y = 158
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 144,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 66,
  y = 128
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 66,
  y = 136
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 76,
  y = 150
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 90,
  y = 150
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 108,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 150
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 96,
  y = 160
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 106,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 96,
  y = 104
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 96,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 96,
  y = 112
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 104,
  y = 118
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 84,
  y = 126
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 84,
  y = 132
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 136,
  y = 108
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 136,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 136,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 136,
  y = 98
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 182,
  y = 124
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 182,
  y = 132
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 180,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 180,
  y = 130
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 180,
  y = 128
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 158,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 132
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 188,
  y = 134
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 190,
  y = 134
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 154,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 150,
  y = 158
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 82,
  y = 150
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 84,
  y = 150
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 98,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 96,
  y = 118
}, {
  dir = "S",
  prototype_name = "砖石公路-U型",
  x = 96,
  y = 116
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 120,
  y = 96
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 114,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 96
}, {
  dir = "W",
  prototype_name = "砖石公路-U型",
  x = 100,
  y = 96
}, {
  dir = "E",
  prototype_name = "砖石公路-U型",
  x = 110,
  y = 96
} }
local mineral = {
["102,62"] = "铁矿石",
["110,92"] = "铝矿石",
["115,133"] = "碎石",
["131,100"] = "铝矿石",
["138,174"] = "铁矿石",
["144,86"] = "碎石",
["145,149"] = "碎石",
["150,95"] = "铁矿石",
["164,127"] = "铁矿石",
["170,112"] = "碎石",
["173,76"] = "铁矿石",
["180,193"] = "铁矿石",
["192,132"] = "碎石",
["197,117"] = "铁矿石",
["209,162"] = "铁矿石",
["210,142"] = "地热气",
["61,118"] = "铁矿石",
["62,185"] = "铁矿石",
["72,132"] = "碎石",
["75,93"] = "铁矿石",
["91,165"] = "铁矿石",
["93,102"] = "铝矿石",
["93,203"] = "地热气"
}




return {
  name = "自动化搭建",
  entities = entities,
  road = road,
  mineral = mineral,
  mountain = mountain,
  order = 5,
  guide = guide,
  show = true,
  start_tech = "拾取物资1",
  init_ui = {
    "/pkg/vaststars.resources/ui/construct.html",
  },
  init_instances = {
  },
  game_settings = {
    skip_guide = false,
    recipe_unlocked = false,
    item_unlocked = false,
    infinite_item = false,
  },
  camera = "/pkg/vaststars.resources/camera_default.prefab",
  tutorial_desc = "学会自动化生产和持续研究科技",
  tutorial_details = {
    "铺设{/g 物流网络}实现原料定点运输",
    "铺设{/g 液网}向需求建筑供应流体原料",
    "制造{/g 发电设施}满足基地供电需求",
  },
}