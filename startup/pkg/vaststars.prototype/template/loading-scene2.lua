local guide = require "guide.guide5"
local mountain = require "mountain"

local mountain = {
  density = 0.1,
  mountain_coords = {},
  excluded_rects = {
    {0, 0, 255, 255},
  },
}

local items = {}
for _ = 1, 16 do
  items[#items+1] = {"", 0}
end

local entities = { {
  dir = "N",
  items = items,
  prototype_name = "指挥中心",
  x = 130,
  y = 86
}, {
  amount = 30,
  dir = "N",
  prototype_name = "物流中心",
  x = 124,
  y = 124
}, {
  dir = "N",
  items = { { "碎石", 2 } },
  prototype_name = "特殊采矿机",
  recipe = "碎石挖掘",
  x = 115,
  y = 133
}, {
  dir = "N",
  items = { { "铁矿石", 0 } },
  prototype_name = "特殊采矿机",
  recipe = "铁矿石挖掘",
  x = 138,
  y = 140
}, {
  dir = "N",
  items = { { "铝矿石", 2 } },
  prototype_name = "特殊采矿机",
  recipe = "铝矿挖掘",
  x = 145,
  y = 149
}, {
  dir = "N",
  items = { { "碎石", 2 } },
  prototype_name = "特殊采矿机",
  recipe = "碎石挖掘",
  x = 150,
  y = 112
}, {
  dir = "N",
  items = { { "铁矿石", 2 } },
  prototype_name = "特殊采矿机",
  recipe = "铁矿石挖掘",
  x = 150,
  y = 95
}, {
  dir = "N",
  items = { { "碎石", 2 } },
  prototype_name = "特殊采矿机",
  recipe = "碎石挖掘",
  x = 93,
  y = 102
}, {
  dir = "E",
  fluid_name = {
    input = { "空气" },
    output = { "地下卤水" }
  },
  items = { { "空气", 379 }, { "地下卤水", 0 } },
  prototype_name = "特殊蒸馏厂",
  recipe = "特殊蒸馏",
  x = 130,
  y = 119
}, {
  dir = "W",
  fluid_name = {
    input = { "空气" },
    output = { "地下卤水" }
  },
  items = { { "空气", 40 }, { "地下卤水", 0 } },
  prototype_name = "特殊蒸馏厂",
  recipe = "特殊蒸馏",
  x = 136,
  y = 119
}, {
  dir = "N",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = { "氧气" }
  },
  items = { { "空气", 500 }, { "地下卤水", 500 }, { "氧气", 233 } },
  prototype_name = "特殊蒸馏厂",
  recipe = "特殊化工",
  x = 122,
  y = 131
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "铁板", 2 }, { "地下卤水", 111 } },
  prototype_name = "特殊电解厂",
  recipe = "特殊电解2",
  x = 128,
  y = 131
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "铁板", 2 }, { "空气", 0 } },
  prototype_name = "特殊电解厂",
  recipe = "特殊电解3",
  x = 137,
  y = 112
}, {
  dir = "N",
  items = { { "铁板", 0 } },
  prototype_name = "特殊电解厂",
  recipe = "特殊电解",
  x = 139,
  y = 130
}, {
  dir = "N",
  items = { { "铁板", 5 } },
  prototype_name = "特殊电解厂",
  recipe = "特殊电解",
  x = 149,
  y = 125
}, {
  dir = "N",
  fluid_name = {
    input = { "氧气" },
    output = { "空气", "地下卤水" }
  },
  items = { { "氧气", 500 }, { "空气", 0 }, { "地下卤水", 0 } },
  prototype_name = "特殊化工厂",
  recipe = "特殊化工2",
  x = 129,
  y = 137
}, {
  dir = "S",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = { "氧气" }
  },
  items = { { "空气", 14 }, { "地下卤水", 500 }, { "氧气", 259 } },
  prototype_name = "特殊化工厂",
  recipe = "特殊化工",
  x = 145,
  y = 131
}, {
  dir = "S",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = { "氧气" }
  },
  items = { { "空气", 0 }, { "地下卤水", 202 }, { "氧气", 0 } },
  prototype_name = "特殊化工厂",
  recipe = "特殊化工",
  x = 124,
  y = 115
}, {
  dir = "S",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = { "氧气" }
  },
  items = { { "空气", 322 }, { "地下卤水", 397 }, { "氧气", 400 } },
  prototype_name = "特殊化工厂",
  recipe = "特殊化工",
  x = 128,
  y = 115
}, {
  dir = "N",
  fluid_name = {
    input = { "氧气" },
    output = { "空气", "地下卤水" }
  },
  items = { { "氧气", 500 }, { "空气", 0 }, { "地下卤水", 0 } },
  prototype_name = "特殊化工厂",
  recipe = "特殊化工2",
  x = 125,
  y = 137
}, {
  dir = "S",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = { "氧气" }
  },
  items = { { "空气", 184 }, { "地下卤水", 500 }, { "氧气", 0 } },
  prototype_name = "特殊化工厂",
  recipe = "特殊化工",
  x = 150,
  y = 131
}, {
  dir = "N",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  items = { { "空气", 3000 }, { "地下卤水", 3000 }, { "气候科技包", 15 } },
  prototype_name = "特殊水电站",
  recipe = "特殊水电",
  x = 146,
  y = 115
}, {
  dir = "N",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  items = { { "空气", 2191 }, { "地下卤水", 2149 }, { "气候科技包", 15 } },
  prototype_name = "特殊水电站",
  recipe = "特殊水电",
  x = 120,
  y = 141
}, {
  dir = "N",
  items = { { "铁矿石", 1 }, { "铁板", 3 } },
  prototype_name = "特殊熔炼炉",
  recipe = "特殊铁板",
  x = 115,
  y = 136
}, {
  dir = "N",
  items = { { "铁矿石", 1 }, { "铁板", 3 } },
  prototype_name = "特殊熔炼炉",
  recipe = "特殊铁板",
  x = 109,
  y = 139
}, {
  dir = "N",
  items = { { "铁矿石", 1 }, { "铁板", 4 } },
  prototype_name = "特殊熔炼炉",
  recipe = "特殊铁板",
  x = 109,
  y = 136
}, {
  dir = "N",
  items = { { "铁矿石", 1 }, { "铁板", 4 } },
  prototype_name = "特殊熔炼炉",
  recipe = "特殊铁板",
  x = 120,
  y = 123
}, {
  dir = "N",
  items = { { "铁矿石", 1 }, { "铁板", 4 } },
  prototype_name = "特殊熔炼炉",
  recipe = "特殊铁板",
  x = 120,
  y = 120
}, {
  dir = "E",
  items = { { "supply", "铁矿石", 4 } },
  prototype_name = "物流站",
  x = 136,
  y = 142
}, {
  dir = "W",
  items = { { "supply", "气候科技包", 8 } },
  prototype_name = "物流站",
  x = 132,
  y = 142
}, {
  dir = "N",
  items = { { "demand", "铁板", 4 } },
  prototype_name = "物流站",
  x = 136,
  y = 134
}, {
  dir = "N",
  items = { { "demand", "铁板", 4 } },
  prototype_name = "物流站",
  x = 140,
  y = 134
}, {
  dir = "W",
  items = {},
  prototype_name = "物流站",
  x = 158,
  y = 124
}, {
  dir = "S",
  items = { { "demand", "铁板", 4 } },
  prototype_name = "物流站",
  x = 146,
  y = 122
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 130,
  y = 124
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 120,
  y = 112
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 120,
  y = 108
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 132,
  y = 112
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 132,
  y = 108
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 148,
  y = 108
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 148,
  y = 104
}, {
  dir = "S",
  items = {},
  prototype_name = "物流站",
  x = 100,
  y = 128
}, {
  dir = "N",
  items = {},
  prototype_name = "物流站",
  x = 100,
  y = 124
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 193 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 110,
  y = 113
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 185 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 113,
  y = 111
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 170 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 110,
  y = 109
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 203 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 113,
  y = 107
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 104,
  y = 121
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 104,
  y = 117
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 100,
  y = 119
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 100,
  y = 115
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 104,
  y = 113
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 104,
  y = 109
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 100,
  y = 111
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 96,
  y = 113
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 96,
  y = 117
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 96,
  y = 121
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "烟囱I",
  recipe = "空气排泄",
  x = 101,
  y = 139
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "烟囱I",
  recipe = "空气排泄",
  x = 101,
  y = 137
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "烟囱I",
  recipe = "空气排泄",
  x = 101,
  y = 135
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "烟囱I",
  recipe = "空气排泄",
  x = 101,
  y = 133
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 125,
  y = 107
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 162 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 127,
  y = 107
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 173 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 129,
  y = 107
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 171 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 137,
  y = 107
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 166 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 139,
  y = 107
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 159 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 141,
  y = 107
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 161 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 127,
  y = 104
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 191 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 129,
  y = 104
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 163 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 135,
  y = 104
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 182 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 137,
  y = 104
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 103 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 139,
  y = 104
}, {
  dir = "N",
  items = { { "碎石", 2 }, { "地质科技包", 6 } },
  prototype_name = "特殊组装机",
  recipe = "特殊地质科技包",
  x = 115,
  y = 129
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "铁矿石", 12 } },
  prototype_name = "特殊组装机",
  recipe = "特殊铁矿石",
  x = 111,
  y = 133
}, {
  dir = "N",
  items = { { "碎石", 1 }, { "地质科技包", 3 } },
  prototype_name = "特殊组装机",
  recipe = "特殊地质科技包",
  x = 107,
  y = 129
}, {
  dir = "S",
  items = { { "碎石", 2 } },
  prototype_name = "特殊采矿机",
  recipe = "碎石挖掘",
  x = 107,
  y = 133
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 144,
  y = 138
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 150,
  y = 141
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 144,
  y = 141
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 147,
  y = 141
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 162,
  y = 121
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 167,
  y = 121
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 167,
  y = 118
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 162,
  y = 118
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  items = { { "地下卤水", 0 }, { "蒸汽", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 94,
  y = 141
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  items = { { "地下卤水", 1 }, { "蒸汽", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 94,
  y = 137
}, {
  dir = "E",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  items = { { "地下卤水", 51 }, { "蒸汽", 0 } },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 94,
  y = 133
}, {
  dir = "E",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  items = { { "蒸汽", 0 } },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 89,
  y = 141
}, {
  dir = "E",
  fluid_name = "",
  items = {},
  prototype_name = "蒸汽发电机I",
  x = 87,
  y = 137
}, {
  dir = "E",
  fluid_name = "",
  items = {},
  prototype_name = "蒸汽发电机I",
  x = 85,
  y = 133
}, {
  dir = "N",
  prototype_name = "轻型风力发电机",
  x = 156,
  y = 117
}, {
  dir = "N",
  prototype_name = "轻型风力发电机",
  x = 156,
  y = 114
}, {
  dir = "N",
  prototype_name = "轻型风力发电机",
  x = 159,
  y = 116
}, {
  dir = "N",
  prototype_name = "轻型风力发电机",
  x = 159,
  y = 113
}, {
  dir = "N",
  prototype_name = "轻型风力发电机",
  x = 110,
  y = 104
}, {
  dir = "N",
  prototype_name = "轻型风力发电机",
  x = 115,
  y = 104
}, {
  dir = "N",
  prototype_name = "轻型风力发电机",
  x = 136,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 176,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 179,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 182,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 185,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 188,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 175,
  y = 131
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 178,
  y = 131
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 181,
  y = 131
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 184,
  y = 131
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 187,
  y = 131
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 174,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 177,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 180,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 183,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 186,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 183,
  y = 134
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 180,
  y = 134
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 177,
  y = 134
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 174,
  y = 134
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 171,
  y = 134
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 173,
  y = 122
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 176,
  y = 122
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 179,
  y = 122
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 182,
  y = 122
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-U型",
  x = 90,
  y = 134
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 91,
  y = 134
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 103,
  y = 139
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 103,
  y = 137
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 104,
  y = 137
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 105,
  y = 137
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 106,
  y = 136
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 106,
  y = 135
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 106,
  y = 134
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 106,
  y = 133
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 106,
  y = 132
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 104,
  y = 134
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 104,
  y = 132
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 103,
  y = 133
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 104,
  y = 133
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 99,
  y = 122
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 100,
  y = 122
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 101,
  y = 122
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 103,
  y = 122
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 102,
  y = 122
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 103,
  y = 120
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 105,
  y = 120
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 104,
  y = 120
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 97,
  y = 120
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 99,
  y = 120
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 98,
  y = 120
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 99,
  y = 118
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 100,
  y = 118
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-X型",
  x = 101,
  y = 118
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 103,
  y = 118
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 102,
  y = 118
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 103,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 104,
  y = 116
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 97,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 99,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 98,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 99,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 100,
  y = 114
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-X型",
  x = 101,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 103,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 102,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 103,
  y = 112
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 105,
  y = 112
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 104,
  y = 112
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 99,
  y = 112
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 97,
  y = 112
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 98,
  y = 112
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 95,
  y = 114
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 95,
  y = 115
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 95,
  y = 116
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 95,
  y = 117
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 95,
  y = 118
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 95,
  y = 119
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 95,
  y = 120
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 95,
  y = 122
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 95,
  y = 121
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 124
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 125
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 126
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 127
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 128
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 129
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 130
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 131
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 133
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 113,
  y = 110
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 114,
  y = 110
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 115,
  y = 110
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 113,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 114,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 115,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 108
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 117,
  y = 108
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 117,
  y = 109
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 110
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 117,
  y = 110
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 117,
  y = 111
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 112
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 117,
  y = 112
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 117,
  y = 113
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 114
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 117,
  y = 114
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 117,
  y = 115
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 117,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 127,
  y = 130
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 128,
  y = 130
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 149,
  y = 130
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 133,
  y = 118
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 134,
  y = 118
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 135,
  y = 118
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 136,
  y = 118
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 137,
  y = 118
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 132,
  y = 107
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 133,
  y = 107
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 135,
  y = 107
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 134,
  y = 107
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 128,
  y = 106
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-U型",
  x = 127,
  y = 106
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 140,
  y = 106
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 141,
  y = 106
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 142,
  y = 106
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 143,
  y = 107
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 143,
  y = 108
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-U型",
  x = 137,
  y = 109
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 138,
  y = 109
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 126,
  y = 109
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 130,
  y = 109
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 131,
  y = 109
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 131,
  y = 107
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 131,
  y = 108
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 123,
  y = 107
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 124,
  y = 107
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 125,
  y = 109
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 124,
  y = 108
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 124,
  y = 109
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 102,
  y = 131
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 100,
  y = 131
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 106,
  y = 124
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 103,
  y = 140
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 103,
  y = 144
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 105,
  y = 144
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 101,
  y = 144
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 120,
  y = 133
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 120,
  y = 131
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 132,
  y = 140
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 136,
  y = 140
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 136,
  y = 138
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 140,
  y = 138
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 136,
  y = 131
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 139,
  y = 128
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 143,
  y = 128
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 134,
  y = 124
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 138,
  y = 124
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 120,
  y = 114
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 122,
  y = 116
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 122,
  y = 118
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 122,
  y = 114
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 133,
  y = 116
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 135,
  y = 116
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 138,
  y = 117
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 140,
  y = 117
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 124,
  y = 112
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 126,
  y = 112
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 130,
  y = 112
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 128,
  y = 112
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 152,
  y = 108
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 146,
  y = 108
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 147,
  y = 126
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 145,
  y = 128
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 147,
  y = 128
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 148,
  y = 131
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 143,
  y = 130
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 158,
  y = 122
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 156,
  y = 122
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 154,
  y = 122
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 165,
  y = 122
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 165,
  y = 120
}, {
  dir = "S",
  items = { { "demand", "铁板", 4 } },
  prototype_name = "物流站",
  x = 150,
  y = 122
}, {
  dir = "E",
  items = { { "supply", "气候科技包", 4 } },
  prototype_name = "物流站",
  x = 146,
  y = 110
}, {
  dir = "W",
  items = { { "demand", "铁板", 1 } },
  prototype_name = "物流站",
  x = 142,
  y = 112
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 133,
  y = 139
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 132,
  y = 138
}, {
  dir = "N",
  items = { { "地质科技包", 30 }, { "地质科技包", 30 }, { "地质科技包", 30 }, { "地质科技包", 30 } },
  prototype_name = "仓库I",
  x = 114,
  y = 132
}, {
  dir = "N",
  items = { { "地质科技包", 30 }, { "地质科技包", 30 }, { "铁矿石", 60 }, { "铁矿石", 60 } },
  prototype_name = "仓库I",
  x = 114,
  y = 134
}, {
  dir = "N",
  items = { { "地质科技包", 30 }, { "地质科技包", 30 }, { "地质科技包", 30 }, { "地质科技包", 30 } },
  prototype_name = "仓库I",
  x = 114,
  y = 130
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 116,
  y = 128
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 108,
  y = 128
}, {
  dir = "N",
  items = { { "地质科技包", 27 }, { "地质科技包", 27 }, { "地质科技包", 27 }, { "地质科技包", 27 } },
  prototype_name = "仓库I",
  x = 110,
  y = 130
}, {
  dir = "N",
  items = { { "地质科技包", 27 }, { "地质科技包", 27 }, { "地质科技包", 27 }, { "地质科技包", 27 } },
  prototype_name = "仓库I",
  x = 110,
  y = 132
}, {
  dir = "N",
  items = { { "铁矿石", 60 }, { "铁矿石", 60 }, { "地质科技包", 27 }, { "地质科技包", 28 } },
  prototype_name = "仓库I",
  x = 110,
  y = 134
}, {
  dir = "N",
  items = { { "机械科技包", 12 }, { "机械科技包", 12 }, { "机械科技包", 12 }, { "机械科技包", 13 } },
  prototype_name = "仓库I",
  x = 111,
  y = 125
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 107,
  y = 123
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 104,
  y = 125
}, {
  dir = "N",
  items = { { "机械科技包", 12 }, { "机械科技包", 14 }, { "机械科技包", 12 }, { "机械科技包", 12 } },
  prototype_name = "仓库I",
  x = 111,
  y = 124
}, {
  dir = "N",
  items = { { "机械科技包", 11 }, { "机械科技包", 10 }, { "机械科技包", 10 }, { "机械科技包", 10 } },
  prototype_name = "仓库I",
  x = 116,
  y = 124
}, {
  dir = "N",
  items = { { "铁矿石", 33 }, { "铁板", 30 } },
  prototype_name = "仓库I",
  x = 123,
  y = 123
}, {
  dir = "N",
  items = { { "铁矿石", 33 }, { "铁板", 30 } },
  prototype_name = "仓库I",
  x = 123,
  y = 122
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 105,
  y = 124
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JU型",
  x = 105,
  y = 128
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 105,
  y = 125
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 110,
  y = 135
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 110,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 110,
  y = 131
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 109,
  y = 128
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 115,
  y = 128
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 114,
  y = 131
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 115,
  y = 132
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 114,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 104,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 102,
  y = 123
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 101,
  y = 123
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 107,
  y = 122
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 113,
  y = 123
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 114,
  y = 123
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 132,
  y = 139
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 133,
  y = 138
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 125
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 121
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 148,
  y = 112
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 148,
  y = 111
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 149,
  y = 110
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 150,
  y = 110
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 132,
  y = 106
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 134,
  y = 106
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 138,
  y = 143
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 138,
  y = 144
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 137,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 138,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 143,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 144,
  y = 134
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 144,
  y = 133
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 124,
  y = 120
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 127,
  y = 121
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 91,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 87,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 83,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 79,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 75,
  y = 125
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 89,
  y = 122
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 85,
  y = 122
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 81,
  y = 122
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 77,
  y = 122
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 89,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 85,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 81,
  y = 128
}, {
  dir = "N",
  prototype_name = "太阳能板I",
  x = 77,
  y = 128
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 115,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 114,
  y = 116
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 113,
  y = 116
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 104,
  y = 129
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-U型",
  x = 92,
  y = 138
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 93,
  y = 138
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 93,
  y = 134
}, {
  dir = "E",
  fluid_name = "蒸汽",
  prototype_name = "管道1-I型",
  x = 92,
  y = 134
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 134
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 135
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 137
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 138
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 97,
  y = 139
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 97,
  y = 140
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 95,
  y = 140
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 96,
  y = 140
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 97,
  y = 136
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 95,
  y = 136
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 96,
  y = 136
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 97,
  y = 132
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 95,
  y = 132
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 96,
  y = 132
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "烟囱I",
  recipe = "空气排泄",
  x = 121,
  y = 103
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "烟囱I",
  recipe = "空气排泄",
  x = 142,
  y = 103
}, {
  dir = "S",
  items = { { "demand", "地质科技包", 3 }, { "demand", "气候科技包", 3 }, { "demand", "机械科技包", 2 } },
  prototype_name = "物流站",
  x = 148,
  y = 138
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 153,
  y = 138
}, {
  dir = "N",
  items = { { "地质科技包", 2 }, { "气候科技包", 2 }, { "机械科技包", 2 }, { "电子科技包", 0 }, { "化学科技包", 0 }, { "物理科技包", 0 } },
  prototype_name = "科研中心I",
  x = 153,
  y = 141
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 147,
  y = 138
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 147,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 149,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 150,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 152,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 152,
  y = 138
}, {
  dir = "N",
  items = { { "地质科技包", 30 }, { "地质科技包", 30 }, { "气候科技包", 30 }, { "气候科技包", 30 } },
  prototype_name = "仓库I",
  x = 147,
  y = 139
}, {
  dir = "N",
  items = { { "地质科技包", 30 }, { "地质科技包", 30 }, { "机械科技包", 30 }, { "机械科技包", 30 } },
  prototype_name = "仓库I",
  x = 148,
  y = 140
}, {
  dir = "N",
  items = { { "机械科技包", 30 }, { "机械科技包", 30 }, { "气候科技包", 30 }, { "气候科技包", 30 } },
  prototype_name = "仓库I",
  x = 151,
  y = 140
}, {
  dir = "N",
  items = { { "气候科技包", 30 }, { "气候科技包", 30 }, { "地质科技包", 30 }, { "地质科技包", 30 } },
  prototype_name = "仓库I",
  x = 152,
  y = 139
}, {
  dir = "S",
  items = { { "supply", "地质科技包", 4 } },
  prototype_name = "物流站",
  x = 110,
  y = 128
}, {
  dir = "N",
  items = { { "碎石", 2 }, { "地质科技包", 0 } },
  prototype_name = "特殊组装机",
  recipe = "特殊地质科技包",
  x = 111,
  y = 130
}, {
  dir = "N",
  items = { { "supply", "铁板", 8 } },
  prototype_name = "物流站",
  x = 112,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 112,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 114,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 112,
  y = 138
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 114,
  y = 138
}, {
  dir = "N",
  items = { { "铁矿石", 60 }, { "铁矿石", 59 }, { "铁板", 30 }, { "铁板", 30 } },
  prototype_name = "仓库I",
  x = 113,
  y = 138
}, {
  dir = "N",
  items = { { "铁矿石", 60 }, { "铁矿石", 60 }, { "铁板", 30 }, { "铁板", 30 } },
  prototype_name = "仓库I",
  x = 113,
  y = 137
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 149,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 152,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 155,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 141,
  y = 114
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 141,
  y = 115
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 106,
  y = 137
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 107,
  y = 138
}, {
  dir = "W",
  items = { { "demand", "地质科技包", 3 }, { "demand", "气候科技包", 3 }, { "demand", "机械科技包", 2 } },
  prototype_name = "物流站",
  x = 168,
  y = 114
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 167,
  y = 117
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 164,
  y = 117
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 165,
  y = 119
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 166,
  y = 119
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 165,
  y = 117
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 166,
  y = 117
}, {
  dir = "N",
  items = { { "机械科技包", 30 }, { "机械科技包", 30 }, { "地质科技包", 30 }, { "地质科技包", 30 } },
  prototype_name = "仓库I",
  x = 165,
  y = 118
}, {
  dir = "N",
  items = { { "气候科技包", 28 }, { "气候科技包", 29 }, { "机械科技包", 30 }, { "机械科技包", 30 } },
  prototype_name = "仓库I",
  x = 166,
  y = 118
}, {
  dir = "N",
  items = { { "铁板", 0 } },
  prototype_name = "特殊电解厂",
  recipe = "特殊电解",
  x = 154,
  y = 125
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 150,
  y = 130
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "液罐I",
  x = 155,
  y = 129
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 154,
  y = 130
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 125,
  y = 140
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 125,
  y = 141
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 129,
  y = 140
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 129,
  y = 141
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 129,
  y = 142
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 142
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 126,
  y = 142
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 125,
  y = 142
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 140
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 131,
  y = 140
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 131,
  y = 143
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 130,
  y = 144
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 131,
  y = 144
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 125,
  y = 144
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 143
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 127,
  y = 144
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 128,
  y = 144
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 126,
  y = 144
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 125,
  y = 136
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 124,
  y = 136
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 126,
  y = 136
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 127,
  y = 136
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 123,
  y = 136
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 122,
  y = 136
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 129,
  y = 130
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 130,
  y = 130
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 131,
  y = 130
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 125,
  y = 130
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 126,
  y = 130
}, {
  dir = "N",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 200 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 122,
  y = 129
}, {
  dir = "W",
  items = { { "demand", "铁板", 4 } },
  prototype_name = "物流站",
  x = 132,
  y = 134
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 130,
  y = 135
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 128,
  y = 135
}, {
  dir = "N",
  items = { { "铁板", 14 }, { "铁板", 15 } },
  prototype_name = "仓库I",
  x = 129,
  y = 135
}, {
  dir = "S",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 129,
  y = 136
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 128,
  y = 136
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 125,
  y = 145
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 129,
  y = 145
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 131,
  y = 145
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 128,
  y = 145
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 126,
  y = 145
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 158,
  y = 129
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 129 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 157,
  y = 133
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 156,
  y = 134
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 145,
  y = 134
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 134
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 151,
  y = 134
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 149,
  y = 134
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 150,
  y = 134
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 147,
  y = 135
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 148,
  y = 135
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 147,
  y = 134
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 153,
  y = 134
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 152,
  y = 134
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 152,
  y = 135
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 151,
  y = 135
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-L型",
  x = 147,
  y = 130
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 148,
  y = 130
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
  x = 152,
  y = 130
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 153,
  y = 130
}, {
  dir = "E",
  fluid_name = "氧气",
  prototype_name = "管道1-I型",
  x = 151,
  y = 130
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 137,
  y = 116
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 137,
  y = 117
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 135,
  y = 120
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 135,
  y = 119
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 135,
  y = 121
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 135,
  y = 122
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "排水口I",
  recipe = "地下卤水排泄",
  x = 141,
  y = 122
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 132,
  y = 118
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 126,
  y = 118
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 118
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 128,
  y = 118
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 129,
  y = 119
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 127,
  y = 119
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 128,
  y = 119
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
  x = 124,
  y = 119
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 125,
  y = 119
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 124,
  y = 118
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 131,
  y = 118
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "地下管1-JI型",
  x = 129,
  y = 118
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 130,
  y = 118
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 143,
  y = 105
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 143,
  y = 106
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 143,
  y = 109
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 142,
  y = 109
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 140,
  y = 109
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 141,
  y = 109
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 139,
  y = 109
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 138,
  y = 106
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 139,
  y = 106
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 137,
  y = 106
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 135,
  y = 106
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 136,
  y = 106
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 128,
  y = 109
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 129,
  y = 109
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 127,
  y = 109
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 131,
  y = 106
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 129,
  y = 106
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 130,
  y = 106
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 122,
  y = 106
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 122,
  y = 107
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 122,
  y = 105
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 106,
  y = 131
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 104,
  y = 131
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 105,
  y = 131
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 106,
  y = 138
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 0 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 105,
  y = 140
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 104,
  y = 139
}, {
  dir = "N",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 105,
  y = 139
}, {
  dir = "S",
  fluid_name = "空气",
  prototype_name = "管道1-T型",
  x = 106,
  y = 139
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 162,
  y = 112
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 165,
  y = 112
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 130,
  y = 128
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 132,
  y = 128
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 132,
  y = 130
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 132,
  y = 132
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 162,
  y = 115
}, {
  dir = "N",
  prototype_name = "蓄电池I",
  x = 165,
  y = 115
}, {
  dir = "E",
  items = { { "demand", "铁矿石", 4 }, { "supply", "铁板", 4 } },
  prototype_name = "物流站",
  x = 120,
  y = 116
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 123,
  y = 120
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 109,
  y = 132
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 103,
  y = 135
}, {
  dir = "W",
  fluid_name = "空气",
  prototype_name = "管道1-L型",
  x = 104,
  y = 135
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  items = { { "地下卤水", 240 } },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 151,
  y = 117
}, {
  dir = "E",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  items = { { "空气", 200 } },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 152,
  y = 115
}, {
  dir = "E",
  fluid_name = "空气",
  prototype_name = "管道1-I型",
  x = 151,
  y = 116
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 148,
  y = 113
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 112,
  y = 139
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 113,
  y = 139
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 114,
  y = 139
}, {
  dir = "N",
  fluid_name = {
    input = { "地下卤水" },
    output = { "废水" }
  },
  items = { { "地下卤水", 3000 }, { "机械科技包", 4 }, { "废水", 0 } },
  prototype_name = "特殊浮选器",
  recipe = "特殊化工3",
  x = 111,
  y = 117
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 110,
  y = 121
}, {
  dir = "N",
  items = { { "supply", "机械科技包", 4 } },
  prototype_name = "物流站",
  x = 112,
  y = 124
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "排水口I",
  recipe = "废水排泄",
  x = 115,
  y = 117
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 113,
  y = 122
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 106,
  y = 116
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-X型",
  x = 105,
  y = 116
}, {
  dir = "N",
  items = { { "机械科技包", 10 }, { "机械科技包", 10 }, { "机械科技包", 10 }, { "机械科技包", 10 } },
  prototype_name = "仓库I",
  x = 116,
  y = 125
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 117,
  y = 124
}, {
  dir = "N",
  prototype_name = "无人机平台III",
  x = 110,
  y = 124
}, {
  dir = "N",
  items = { { "机械科技包", 10 }, { "机械科技包", 10 }, { "机械科技包", 10 }, { "机械科技包", 11 } },
  prototype_name = "仓库I",
  x = 117,
  y = 125
}, {
  dir = "N",
  items = { { "机械科技包", 15 }, { "机械科技包", 16 }, { "机械科技包", 14 }, { "机械科技包", 12 } },
  prototype_name = "仓库I",
  x = 110,
  y = 125
}, {
  dir = "E",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 115,
  y = 122
}, {
  dir = "W",
  fluid_name = "废水",
  prototype_name = "管道1-L型",
  x = 116,
  y = 122
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 120
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 116,
  y = 121
}, {
  dir = "N",
  fluid_name = "废水",
  prototype_name = "管道1-I型",
  x = 114,
  y = 121
}, {
  dir = "S",
  fluid_name = "废水",
  prototype_name = "管道1-T型",
  x = 114,
  y = 122
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 112,
  y = 116
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 110,
  y = 116
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 111,
  y = 116
}, {
  dir = "E",
  items = { { "supply", "气候科技包", 8 } },
  prototype_name = "物流站",
  x = 120,
  y = 136
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 120,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 121,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 122,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 123,
  y = 140
}, {
  dir = "N",
  prototype_name = "无人机平台II",
  x = 124,
  y = 140
}, {
  dir = "N",
  items = { { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 } },
  prototype_name = "仓库I",
  x = 122,
  y = 137
}, {
  dir = "N",
  items = { { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 } },
  prototype_name = "仓库I",
  x = 124,
  y = 137
}, {
  dir = "N",
  items = { { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 } },
  prototype_name = "仓库I",
  x = 123,
  y = 138
}, {
  dir = "N",
  items = { { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 } },
  prototype_name = "仓库I",
  x = 122,
  y = 139
}, {
  dir = "N",
  items = { { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 }, { "气候科技包", 15 } },
  prototype_name = "仓库I",
  x = 124,
  y = 139
} }

local road = { {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 118
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 112
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 116
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 112
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 116
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
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
  x = 136,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 126
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 144,
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
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 144
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 118,
  y = 146
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 120,
  y = 146
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 122,
  y = 146
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 124,
  y = 146
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 128,
  y = 146
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 130,
  y = 146
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 132,
  y = 146
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 134,
  y = 146
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 144
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 134,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 134,
  y = 128
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 134,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 136,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 138,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 140,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 158,
  y = 136
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 160,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 122
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 160,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 158,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 120
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 144,
  y = 120
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 120
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
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
  y = 108
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 154,
  y = 106
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 106
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 106
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 106
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 106
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 144,
  y = 106
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 144,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 108
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 160,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 164,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 124
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 168,
  y = 124
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 170,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 122
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 116
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 170,
  y = 112
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 170,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 168,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 166,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 164,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 162,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 160,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 158,
  y = 110
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 154,
  y = 110
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-X型",
  x = 118,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 126
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
  x = 106,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 126
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 98,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 128
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 130
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 132
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 134
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 98,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 98,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 100,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 102,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 104,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 106,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-T型",
  x = 118,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 142
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 142
}, {
  dir = "W",
  prototype_name = "砖石公路-T型",
  x = 118,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 108
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 106
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 118,
  y = 104
}, {
  dir = "S",
  prototype_name = "砖石公路-L型",
  x = 118,
  y = 102
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 116,
  y = 102
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 114,
  y = 102
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 112,
  y = 102
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 110,
  y = 102
}, {
  dir = "E",
  prototype_name = "砖石公路-L型",
  x = 108,
  y = 102
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 104
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 106
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 108
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 110
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 112
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 114
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 116
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 118
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 120
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 122
}, {
  dir = "S",
  prototype_name = "砖石公路-T型",
  x = 108,
  y = 126
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 108,
  y = 124
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 142,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 142,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-L型",
  x = 142,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 144,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 146,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 148,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 136
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 150,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 152,
  y = 144
}, {
  dir = "E",
  prototype_name = "砖石公路-I型",
  x = 154,
  y = 144
}, {
  dir = "W",
  prototype_name = "砖石公路-L型",
  x = 156,
  y = 144
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 142
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 156,
  y = 136
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 140
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 156,
  y = 138
}, {
  dir = "N",
  prototype_name = "砖石公路-T型",
  x = 126,
  y = 146
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 148
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 150
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 152
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 154
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 156
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 158
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 160
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 162
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 164
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 166
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 168
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 170
}, {
  dir = "N",
  prototype_name = "砖石公路-I型",
  x = 126,
  y = 172
}, {
  dir = "N",
  prototype_name = "砖石公路-U型",
  x = 126,
  y = 174
} }
local mineral = {
["102,62"] = "铝矿石",
["103,190"] = "铝矿石",
["107,133"] = "碎石",
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
    name = "登录场景",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 4,
    guide = guide,
    show = true,
    start_tech = "登录科技",
    canvas_icon = false,
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