local guide = require "guide"
local mountain = require "mountain"

local entities = {}
local road = {}

local mineral = {
  ["115,129"] = "碎石",
  ["120,129"] = "铁矿石",
  ["125,129"] = "地热气",
  ["130,129"] = "铝矿石",
  ["135,129"] = "砂岩",
}

return {
  name = "矿区测试",
  entities = entities,
  road = road,
  mineral = mineral,
  mountain = mountain,
  order = 2,
  guide = guide,
  start_tech = "登录科技开启",
  init_ui = {
    "/pkg/vaststars.resources/ui/construct.html",
    "/pkg/vaststars.resources/ui/message_pop.html"
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