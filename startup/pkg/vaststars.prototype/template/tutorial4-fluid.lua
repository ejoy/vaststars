local guide = require "guide.guide4"
local mountain = require "mountain"

local items = {}
for _ = 1, 16 do
  items[#items+1] = {"", 0}
end

local entities = { {
  dir = "N",
  items = items,
  prototype_name = "指挥中心",
  x = 122,
  y = 122
},{
  dir = "N",
  items = { { "地下水挖掘机I", 2 },{ "空气过滤器I", 2 }},
  prototype_name = "机身残骸",
  x = 126,
  y = 147
},{
  dir = "N",
  items = {{ "烟囱I", 1} },
  prototype_name = "机头残骸",
  x = 103,
  y = 156
},{
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
  fluid_name = "纯水",
  prototype_name = "排水口I",
  x = 102,
  y = 144
}, {
  dir = "N",
  prototype_name = "轻型采矿机",
  recipe = "碎石挖掘",
  x = 115,
  y = 131
}, {
  dir = "N",
  prototype_name = "轻型采矿机",
  recipe = "碎石挖掘",
  x = 115,
  y = 135
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
  items = { { "管道1-X型", 30 } },
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
  fluid_name = "",
  prototype_name = "组装机I",
  x = 123,
  y = 135
}, {
  dir = "N",
  items = { { "碎石", 60 } },
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
  y = 122
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 98,
  y = 127
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 103,
  y = 127
}, {
  dir = "N",
  prototype_name = "风力发电机I",
  x = 103,
  y = 122
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
  items = { { "铁矿石", 60 }, { "铁棒", 30 } },
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
}, {
  dir = "S",
  fluid_name = {
    input = { "空气", "地下卤水" },
    output = {}
  },
  prototype_name = "水电站I",
  recipe = "气候科技包1",
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
  items = { { "气候科技包", 11 } },
  prototype_name = "仓库I",
  x = 139,
  y = 146
}, {
  dir = "N",
  fluid_name = "",
  prototype_name = "电解厂I",
  x = 97,
  y = 155
}, {
  dir = "S",
  fluid_name = "",
  prototype_name = "蒸馏厂I",
  x = 108,
  y = 155
}, {
  dir = "S",
  fluid_name = "",
  prototype_name = "化工厂I",
  x = 103,
  y = 147
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
  recipe = "气候科技包1",
  x = 134,
  y = 146
}, {
  dir = "S",
  fluid_name = "",
  prototype_name = "烟囱I",
  x = 97,
  y = 167
}, {
  dir = "N",
  fluid_name = "氧气",
  prototype_name = "烟囱I",
  recipe = "氧气排泄",
  x = 99,
  y = 153
}, {
  dir = "N",
  fluid_name = "氢气",
  prototype_name = "液罐I",
  x = 91,
  y = 149
}, {
  dir = "E",
  fluid_name = "",
  prototype_name = "管道1-U型",
  x = 101,
  y = 150
}, {
  dir = "W",
  fluid_name = "",
  prototype_name = "管道1-U型",
  x = 102,
  y = 150
}, {
  dir = "W",
  fluid_name = "",
  prototype_name = "管道1-U型",
  x = 107,
  y = 150
}, {
  dir = "E",
  fluid_name = "",
  prototype_name = "管道1-U型",
  x = 106,
  y = 150
} }

local road = {}
local mineral = {
["110,92"] = "铝矿石",
["115,131"] = "碎石",
["115,135"] = "碎石",
["128,141"] = "铁矿石",
["131,100"] = "铝矿石",
["135,131"] = "铁矿石",
["135,135"] = "铁矿石",
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
["93,102"] = "铝矿石",
["93,203"] = "地热气",
["97,162"] = "铝矿石"
}

return {
  name = "液网搭建",
  entities = entities,
  road = road,
  mineral = mineral,
  mountain = mountain,
  order = 4,
  guide = guide,
  show = true,
  start_tech = "管道接收",
  login_techs = {
    "登录科技4",
  },
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
  tutorial_desc = "学会铺设液网满足建筑流体获取或排放",
  tutorial_details = {
    "铺设{/g 管道}或{/g 地下管}连接建筑液口",
    "放置{/g 液罐}存储更多流体",
    "使用{/g 烟囱}或{/g 排水口}排放多余流体",
  },
  tutorial_background = "/pkg/vaststars.resources/ui/textures/tutorial-list/4.texture",
}