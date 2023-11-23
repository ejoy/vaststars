local guide = require "guide.guide1"
local mountain = require "mountain"

local items = {}
for _ = 1, 16 do
  items[#items+1] = {"", 0}
end

local entities = {{
    dir = "N",
    items = items,
    prototype_name = "指挥中心",
    x = 130,
    y = 112
  }, {
    dir = "N",
    items = {{ "仓库I", 1 }, { "采矿机I", 3 }},
    prototype_name = "机身残骸",
    x = 121,
    y = 129
  }, {
    dir = "N",
    prototype_name = "风力发电机I",
    x = 122,
    y = 115
  }, {
    dir = "N",
    prototype_name = "组装机I",
    x = 122,
    y = 121
  }, {
    dir = "N",
    prototype_name = "无人机平台I",
    x = 120,
    y = 123
  },}
local road = {}

local mineral = {
  ["131,123"] = "铝矿石",
  ["126,135"] = "铁矿石",
  ["115,129"] = "碎石",
}

return {
    name = "矿物挖掘",
    entities = entities,
    road = road,
    mineral = mineral,
    mountain = mountain,
    order = 1,
    guide = guide,
    show = true,
    start_tech = "采矿教学",
    init_ui = {
      "/pkg/vaststars.resources/ui/construct.rml",
      "/pkg/vaststars.resources/ui/message_pop.rml"
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
}