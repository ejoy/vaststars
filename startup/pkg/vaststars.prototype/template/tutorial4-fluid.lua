local entities = {{
  amount = 0,
  dir = "N",
  prototype_name = "指挥中心",
  x = 124,
  y = 118
}, {
  dir = "N",
  items = { { "空气过滤器I", 5 }, { "地下水挖掘机I", 5 } },
  prototype_name = "机身残骸",
  x = 128,
  y = 147
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
  dir = "E",
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "一氧化碳", "纯水" }
  },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转一氧化碳",
  x = 147,
  y = 180
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
  fluid_name = {
    input = { "二氧化碳", "氢气" },
    output = { "甲烷", "纯水" }
  },
  prototype_name = "化工厂I",
  recipe = "二氧化碳转甲烷",
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
  fluid_name = {
    input = { "乙烯", "氯气" },
    output = { "盐酸" }
  },
  prototype_name = "化工厂I",
  recipe = "塑料1",
  x = 175,
  y = 165
}, {
  dir = "W",
  fluid_name = {
    input = { "乙烯", "氯气" },
    output = { "盐酸" }
  },
  prototype_name = "化工厂I",
  recipe = "塑料1",
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
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 143,
  y = 172
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 150,
  y = 166
}, {
  dir = "E",
  fluid_name = "氮气",
  prototype_name = "烟囱I",
  recipe = "氮气排泄",
  x = 150,
  y = 172
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
  dir = "N",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 179
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 150,
  y = 180
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 181
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
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 166,
  y = 170
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 165,
  y = 170
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
  x = 160,
  y = 173
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 159,
  y = 173
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
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JU型",
  x = 152,
  y = 156
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
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
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
  dir = "W",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
  x = 146,
  y = 190
}, {
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 191
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "液罐I",
  x = 145,
  y = 198
}, {
  dir = "N",
  fluid_name = "纯水",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 197
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
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 171
}, {
  dir = "E",
  fluid_name = "乙烯",
  prototype_name = "地下管1-JI型",
  x = 172,
  y = 167
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
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 176
}, {
  dir = "W",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 146,
  y = 180
}, {
  dir = "E",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 144,
  y = 180
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "地下管1-JI型",
  x = 143,
  y = 179
}, {
  dir = "N",
  fluid_name = "一氧化碳",
  prototype_name = "管道1-L型",
  x = 143,
  y = 180
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
  items = { { "石墨", 50 } },
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
  items = { { "石墨", 50 } },
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
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
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
  prototype_name = "地下管1-JI型",
  x = 157,
  y = 194
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 146,
  y = 194
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 147,
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
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "排水口I",
  recipe = "盐酸排泄",
  x = 177,
  y = 181
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
  dir = "E",
  fluid_name = "纯水",
  prototype_name = "管道1-T型",
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
  fluid_name = {
    input = { "氧气", "甲烷" },
    output = { "乙烯", "纯水" }
  },
  prototype_name = "化工厂I",
  recipe = "甲烷转乙烯",
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
  dir = "W",
  fluid_name = "氧气",
  prototype_name = "管道1-T型",
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
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-I型",
  x = 160,
  y = 184
}, {
  dir = "E",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
  x = 158,
  y = 194
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 193
}, {
  dir = "S",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 185
}, {
  dir = "N",
  fluid_name = "甲烷",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 183
}, {
  dir = "W",
  fluid_name = "甲烷",
  prototype_name = "管道1-T型",
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
  prototype_name = "地下管1-JI型",
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
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 159,
  y = 178
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 160,
  y = 178
}, {
  dir = "S",
  fluid_name = "氢气",
  prototype_name = "地下管1-JI型",
  x = 158,
  y = 174
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-T型",
  x = 158,
  y = 173
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "管道1-L型",
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
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 165,
  y = 175
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-I型",
  x = 166,
  y = 175
}, {
  dir = "S",
  fluid_name = "地下卤水",
  prototype_name = "地下管1-JI型",
  x = 167,
  y = 171
}, {
  dir = "E",
  fluid_name = "地下卤水",
  prototype_name = "管道1-T型",
  x = 167,
  y = 170
}, {
  dir = "W",
  fluid_name = "地下卤水",
  prototype_name = "管道1-L型",
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
  dir = "S",
  fluid_name = "纯水",
  prototype_name = "地下管1-JU型",
  x = 128,
  y = 160
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
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "烟囱I",
  recipe = "二氧化碳排泄",
  x = 150,
  y = 201
}, {
  dir = "N",
  fluid_name = "氯气",
  prototype_name = "地下管1-JI型",
  x = 174,
  y = 168
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
  x = 174,
  y = 169
}, {
  dir = "W",
  fluid_name = "氯气",
  prototype_name = "管道1-T型",
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
  prototype_name = "管道1-L型",
  x = 178,
  y = 163
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 178,
  y = 164
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 178,
  y = 166
}, {
  dir = "S",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 178,
  y = 168
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "管道1-T型",
  x = 178,
  y = 167
}, {
  dir = "N",
  fluid_name = "盐酸",
  prototype_name = "地下管1-JI型",
  x = 178,
  y = 170
}, {
  dir = "E",
  fluid_name = "盐酸",
  prototype_name = "管道1-T型",
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
  prototype_name = "无人机平台I",
  x = 207,
  y = 162
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 136,
  y = 174
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
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 197
}, {
  dir = "S",
  fluid_name = "二氧化碳",
  prototype_name = "地下管1-JI型",
  x = 150,
  y = 189
}, {
  dir = "E",
  fluid_name = "二氧化碳",
  prototype_name = "管道1-T型",
  x = 150,
  y = 188
}, {
  dir = "W",
  fluid_name = "氢气",
  prototype_name = "管道1-U型",
  x = 150,
  y = 182
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
  x = 150,
  y = 186
}, {
  dir = "E",
  fluid_name = "氢气",
  prototype_name = "管道1-I型",
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
  dir = "S",
  fluid_name = {
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 31,
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
    input = { "地下卤水" },
    output = { "蒸汽" }
  },
  prototype_name = "锅炉I",
  recipe = "卤水沸腾",
  x = 43,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 40,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 34,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 46,
  y = 173
}, {
  dir = "S",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 43,
  y = 168
}, {
  dir = "S",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 43,
  y = 163
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
    input = { "蒸汽" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 31,
  y = 168
}, {
  dir = "S",
  fluid_name = {
    input = { "蒸汽" },
    output = {}
  },
  prototype_name = "蒸汽发电机I",
  recipe = "蒸汽发电",
  x = 31,
  y = 163
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
  fluid_name = {
    input = {},
    output = { "地下卤水" }
  },
  prototype_name = "地下水挖掘机I",
  recipe = "离岸抽水",
  x = 115,
  y = 141
}, {
  dir = "N",
  fluid_name = "地下卤水",
  prototype_name = "液罐I",
  x = 123,
  y = 141
}, {
  dir = "N",
  prototype_name = "轻型采矿机",
  recipe = "碎石挖掘",
  x = 115,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 118,
  y = 135
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "石砖",
  x = 119,
  y = 131
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "石砖",
  x = 119,
  y = 135
}, {
  dir = "N",
  items = {{"管道1-X型","10"}},
  prototype_name = "仓库I",
  x = 124,
  y = 134
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 118,
  y = 133
}, {
  dir = "N",
  prototype_name = "组装机I",
  x = 123,
  y = 135
}, {
  dir = "N",
  items = {{"石砖", 0},{"碎石", 0}},
  prototype_name = "仓库I",
  x = 120,
  y = 134
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 122,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 122,
  y = 135
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "管道1",
  x = 123,
  y = 131
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 98,
  y = 132
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 98,
  y = 137
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 103,
  y = 137
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 103,
  y = 132
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "组装机I",
  x = 127,
  y = 135
}, {
  dir = "N",
  prototype_name = "组装机I",
  recipe = "铁棒1",
  x = 127,
  y = 131
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 131,
  y = 131
}, {
  dir = "N",
  prototype_name = "熔炼炉I",
  recipe = "铁板1",
  x = 131,
  y = 135
}, {
  dir = "N",
  items = {},
  prototype_name = "仓库I",
  x = 128,
  y = 134
}, {
  dir = "N",
  items = { { "铁矿石", 46 }, { "铁棒", 30 } },
  prototype_name = "仓库I",
  x = 132,
  y = 134
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 130,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 130,
  y = 135
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 134,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 134,
  y = 135
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 135,
  y = 131
}, {
  dir = "N",
  prototype_name = "采矿机I",
  recipe = "铁矿石挖掘",
  x = 135,
  y = 135
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 126,
  y = 133
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 126,
  y = 135
},
-- {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 100,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 102,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 104,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 106,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 106,
--   y = 132
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 106,
--   y = 134
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 106,
--   y = 136
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 106,
--   y = 138
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 98,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 96,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 96,
--   y = 132
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 96,
--   y = 134
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 96,
--   y = 136
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 96,
--   y = 138
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 96,
--   y = 140
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 98,
--   y = 140
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 100,
--   y = 140
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 102,
--   y = 140
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 104,
--   y = 140
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 106,
--   y = 140
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 96,
--   y = 127
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 99,
--   y = 127
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 102,
--   y = 127
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 105,
--   y = 127
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 108,
--   y = 127
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 108,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 108,
--   y = 133
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 108,
--   y = 136
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 108,
--   y = 139
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 108,
--   y = 142
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 105,
--   y = 142
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 102,
--   y = 142
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 99,
--   y = 142
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 96,
--   y = 142
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 93,
--   y = 142
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 93,
--   y = 139
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 93,
--   y = 136
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 93,
--   y = 133
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 93,
--   y = 130
-- }, {
--   dir = "N",
--   prototype_name = "太阳能板I",
--   x = 93,
--   y = 127
-- -- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 98,
--   y = 135
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 100,
--   y = 135
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 102,
--   y = 135
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 104,
--   y = 135
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 101,
--   y = 138
-- }, {
--   dir = "N",
--   prototype_name = "蓄电池I",
--   x = 101,
--   y = 132
-- }, 
{
  dir = "S",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  prototype_name = "水电站I",
  recipe = "气候科技包T1",
  x = 134,
  y = 141
}, {
  dir = "W",
  fluid_name = {
    input = {},
    output = { "空气" }
  },
  prototype_name = "空气过滤器I",
  recipe = "空气过滤",
  x = 132,
  y = 144
}, {
  dir = "N",
  items = { { "气候科技包", 19 } },
  prototype_name = "仓库I",
  x = 139,
  y = 146
}, {
  dir = "N",
  prototype_name = "无人机平台I",
  x = 140,
  y = 146
}, {
  dir = "N",
  prototype_name = "科研中心I",
  x = 141,
  y = 145
}, {
  dir = "S",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  prototype_name = "水电站I",
  recipe = "气候科技包T1",
  x = 134,
  y = 146
}}
  local road = {  }
local mineral = {
  ["135,131"] = "铁矿石",
  ["135,135"] = "铁矿石",
  ["129,141"] = "铁矿石",
  ["115,133"] = "碎石",
  ["144,86"] = "碎石",
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
  ["93,203"] = "地热气",
  ["131,100"] = "铝矿石",
  ["110,92"] = "铝矿石",
}

return {
  name = "教学:液网搭建",
  entities = entities,
  road = road,
  mineral = mineral,
  order = 7,
  guide = "guide.guide4",
  show = true,
  mode = "adventure",
  start_tech = "流体教学",
}