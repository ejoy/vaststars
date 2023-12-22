require "tech.tech1"
require "tech.tech2"
require "tech.tech3"
require "tech.tech4"
require "tech.tech5"
require "tech.logintech"

local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

  --task = {"stat_production", 0, "铁矿石"},            生产XX个物品
  --task = {"stat_consumption", 0, "铁矿石"},           消耗XX个物品
  --task = {"select_entity", 0, "组装机"},              拥有XX台机器
  --task = {"select_chest", 0, "指挥中心", "铁丝"},     向指挥中心转移X个物品
  --task = {"power_generator", 0},                      电力发电到达X瓦
  --task = {"unknown", 0},                              自定义任务
  
  -- task = {"unknown", 0, 1},
  -- task_params = {
  --     path = {
  --         {{117, 125}, {135, 125}},
  --         ...
  --     }
  -- },
  -- count = 1,                                         连接A点到B点的路网

  --task = {"unknown", 0, 2},                           派遣运输车

  --task = {"unknown", 0, 3},                           自定义任务，组装机指定选择配方
  --task_params = {recipe = "地质科技包1"},
  --count = 1,
  --time是指1个count所需的时间

  -- task = {"unknown", 0, 5},                          自定义任务，无人机平台I指定选择物品
  -- task_params = {item = "采矿机框架"},

  -- task = {"unknown", 0, 6},
  -- task_params = {ui = "set_transfer_source", building = "xxx"},    收取物品

  -- task = {"unknown", 0, 6},
  -- task_params = {ui = "transfer",  building = "xxx"},  放置物品

  -- task = {"unknown", 0, 7},
  -- task_params = {building = "xx", item = "xx", count = xx,}  放置物品到指定建筑
  
  -- task = {"unknown", 0, 8},
  -- task_params = {items = {"demand|xx", "supply|xx", ...}}     车站设置多个收货/发货物品
  
  -- task = {"unknown", 0, 8},
  -- task_params = {items = {"transit|碎石", "transit|铁矿石","transit|铝矿石"}}, 仓库任务

  -- task = {"unknown", 0, 9},                 从指定建筑提出指定物品指定数量
  -- task_params = {building = xx, item = xx, }
  -- count = xx

  -- task = {"unknown", 0, 10},           X个建筑处于通电状态
  -- task_params = {building = xx, }
  -- count = xx

  -- task = {"unknown", 0, 11},               X建筑的指定水口连接液体
  -- task_params = {building = xx, fluids = {xx, xx}}
  -- count = 1

  prototype "登录科技开启" {
    desc = "登录科技开启",
    type = { "tech" },
    prerequisites = {},
    ingredients = {},
    effects = {
      unlock_item = {"碎石","铁矿石","铝矿石"},
    },
    count = 1,
    time = "1s"
  }

  -- prototype "搜索废墟" {
  --   desc = "从废墟中搜索物资",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = {"task" },
  --   task = {"unknown", 0, 6},
  --   task_params = {ui = "set_transfer_source", building = "机身残骸"},
  --   prerequisites = {"登录科技开启"},
  --   count = 1,
  --   effects = {
  --     unlock_item = {"碎石"},
  --   },
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   guide_focus = {
  --     {
  --       prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --       x = 109,
  --       y = 136,
  --       w = 3.5,
  --       h = 3.5,
  --       color = {0.3, 1, 0, 1},
  --       show_arrow = true,
  --     },
  --     {
  --       camera_x = 109,
  --       camera_y = 136,
  --       w = 3.5,
  --       h = 3.5,
  --     },
  --   },
  --   sign_desc = {
  --     { desc = "搜索机身残骸获取有用物资", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置采矿机1" {
  --   desc = "放置1台采矿机",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = {"task" },
  --   task = {"select_entity", 0, "采矿机I"},
  --   prerequisites = {"搜索废墟"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   guide_focus = {
  --     -- {
  --     --   prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --     --   x = 139,
  --     --   y = 141,
  --     --   w = 3.2,
  --     --   h = 3.2,
  --     -- color = {0.3, 1, 0, 1},
  --     --   show_arrow = true,
  --     -- },
  --     {
  --       prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --       x = 116,
  --       y = 134,
  --       w = 3.2,
  --       h = 3.2,
  --       color = {0.3, 1, 0, 1},
  --     },
  --     {
  --       camera_x = 116,
  --       camera_y = 134,
  --       w = 3.2,
  --       h = 3.2,
  --     },
  --   },
  --   sign_desc = {
  --     { desc = "在石矿上放置1台采矿机", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }


  -- prototype "放置仓库" {
  --   desc = "放置1座仓库",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "仓库I"},
  --   prerequisites = {"放置采矿机1"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_pole1.texture",
  --   },
  --   effects = {
  --     unlock_item = {"碎石"},
  --   },
  --   sign_desc = {
  --     { desc = "放置1座仓库I", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "仓库设置1" {
  --   desc = "仓库选择碎石",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"unknown", 0, 5},                          
  --   task_params = {item = "碎石"},
  --   count = 1,
  --   prerequisites = {"放置仓库"},
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "仓库设置收货选择“碎石”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置无人机平台" {
  --   desc = "放置1座无人机平台",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "无人机平台I"},
  --   prerequisites = {"仓库设置1"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_pole1.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_pole2.texture",
  --   },
  --   effects = {
  --   },
  --   sign_desc = {
  --     { desc = "放置1座无人机平台I", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "收集碎石" {
  --   desc = "挖掘足够的碎石可以开始进行锻造",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "碎石"},
  --   prerequisites = {"搜索废墟"},
  --   count = 12,
  --   effects = {
  --     unlock_item = {"铁矿石","铝矿石"},
  --   },
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ore3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用无人机平台收集12个碎石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置采矿机2" {
  --   desc = "放置1台采矿机",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = {"task" },
  --   task = {"select_entity", 0, "采矿机I"},
  --   prerequisites = {"收集碎石"},
  --   count = 2,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   guide_focus = {
  --     {
  --       prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --       x = 139,
  --       y = 141,
  --       w = 3.2,
  --       h = 3.2,
  --       color = {0.3, 1, 0, 1},
  --       show_arrow = false,
  --     },
  --     {
  --       camera_x = 139,
  --       camera_y = 139,
  --       w = 3.2,
  --       h = 3.2,
  --     },
  --   },
  --   sign_desc = {
  --     { desc = "寻找铁矿并放置1台采矿机", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置风力发电机" {
  --   desc = "放置2台风力发电机",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "风力发电机I"},
  --   prerequisites = {"放置采矿机2"},
  --   effects = {
  --     unlock_item = {"铁矿石","铝矿石"},
  --   },
  --   count = 2,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "在铁矿采矿机的附近放置1座风力发电机对其供电", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "收集铁矿石" {
  --   desc = "挖掘足够的铁矿石",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "铁矿石"},
  --   prerequisites = {"收集碎石"},
  --   count = 6,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ore3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "收集6个铁矿石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "收集铝矿石" {
  --   desc = "挖掘足够的铝矿石",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "铝矿石"},
  --   prerequisites = {"收集碎石"},
  --   count = 6,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ore3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "收集6个铝矿石", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置科研中心" {
  --   desc = "放置可以研究火星科技的建筑",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "科研中心I"},
  --   prerequisites = {"收集铝矿石","收集铁矿石"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_click_build.texture",
  --   },
  --   sign_desc = {
  --     { desc = "放置1座科研中心", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "地质研究" {
    desc = "对火星地质结构进行标本采集和研究",
    type = { "tech" },
    effects = {
      unlock_recipe = {"地质科技包1"},
      unlock_item = {"地质科技包"},
    },
    ingredients = {
    },
    count = 8,
    time = "2s",
    prerequisites = {},
    sign_desc = {
      { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture"},
    },
    sign_icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture",
}
  
  -- prototype "仓库设置2" {
  --   desc = "仓库收货地质科技包",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"unknown", 0, 5},                          
  --   task_params = {item = "地质科技包"},
  --   count = 1,
  --   prerequisites = {"地质研究"},
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "仓库设置收货选择“地质科技包”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置组装机" {
  --   desc = "放置组装机",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "组装机I"},
  --   effects = {
  --   },
  --   prerequisites = {"仓库设置2"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_click_build.texture",
  --   },
  --   -- guide_focus = {
  --   --   {
  --   --     prefab = "glbs/selected-box-no-animation.glb|mesh.prefab",
  --   --     x = 130,
  --   --     y = 127.8,
  --   --     w = 1.8,
  --   --     h = 1.8,
  --   --     color = {0.3, 1, 0, 1},
  --   --     show_arrow = true,
  --   --   },
  --   --   {
  --   --     camera_x = 128,
  --   --     camera_y = 125,
  --   --     w = 1.8,
  --   --     h = 1.8,
  --   --   },
  --   -- },
  --   sign_desc = {
  --     { desc = "放置1台组装机", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "组装机设置" {
  --   desc = "组装机生产地质科技包1",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"unknown", 0, 3},                          
  --   task_params = {recipe = "地质科技包1"},
  --   count = 1,
  --   prerequisites = {"放置组装机"},
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "组装机生产配方设置为“地质科技包1”", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "组装机生产" {
  --   desc = "组装机自动化生产科技包",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "地质科技包"},
  --   prerequisites = {"地质研究"},
  --   count = 3,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack3.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack4.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack5.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack6.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用组装机生产3个地质科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "石头处理1" {
    desc = "获得火星岩石加工成石砖的工艺",
    type = { "tech" },
    effects = {
      unlock_recipe = {"石砖"},
      unlock_item = {"石砖"},
    },
    prerequisites = {"地质研究"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 4,
    time = "3s"
  }

  -- prototype "生产石砖" {
  --   desc = "将碎石打造成其他材料",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "石砖"},
  --   prerequisites = {"石头处理1"},
  --   count = 8,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ore3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用组装机生产8个石砖", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "铁矿熔炼" {
    desc = "掌握熔炼铁矿石冶炼成铁板的工艺",
    type = { "tech" },
    effects = {
      unlock_recipe = {"铁板T1"},
      unlock_item = {"铁板"},
    },
    prerequisites = {"石头处理1"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 5,
    time = "4s"
  }
  
  -- prototype "放置熔炼炉" {
  --   desc = "放置熔炼炉",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "熔炼炉I"},
  --   prerequisites = {"铁矿熔炼"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_click_build.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack1.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_geopack2.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/start_construct.texture",
  --   },
  --   sign_desc = {
  --     { desc = "放置1台熔炼炉", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }
  
  -- prototype "生产铁板" {
  --   desc = "熔炼炉生产铁板",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "铁板"},
  --   prerequisites = {"铁矿熔炼"},
  --   count = 4,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate1.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate2.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate3.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate4.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate5.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用熔炼炉生产4块铁板", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "铁加工1" {
    desc = "获得更多铁成品的加工工艺",
    type = { "tech" },
    effects = {
      unlock_recipe = {"铁齿轮","铁棒1"},
      unlock_item = {"铁齿轮","铁棒"},
    },
    prerequisites = {"铁矿熔炼"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 8,
    time = "3s"
  }

  prototype "建筑维修1" {
    desc = "获得维修机械的技术",
    type = { "tech" },
    effects = {
      unlock_recipe = {"维修无人机平台"},
      unlock_item = {"无人机平台I"},
    },
    prerequisites = {"铁加工1"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 6,
    time = "4s"
  }

  -- prototype "生产铁棒" {
  --   desc = "铁棒可打造长形组件也可加工成其他铁制品",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "铁棒"},
  --   prerequisites = {"铁加工1"},
  --   count = 10,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate1.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate2.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate3.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate4.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate5.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用组装机生产10个铁棒", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "公路研究" {
    desc = "掌握使用石砖制造公路的技术",
    type = { "tech" },
    prerequisites = {"建筑维修1"},
    effects = {
      unlock_recipe = {"砖石公路打印"},
      unlock_item = {"砖石公路-X型"},
    },
    ingredients = {
        {"地质科技包", 1},
    },
    count = 5,
    time = "3s"
  }

  -- prototype "建造公路" {
  --   desc = "建造物流所需的公路",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "砖石公路-X型"},
  --   prerequisites = {"公路研究"},
  --   count = 30,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ore3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用组装机生产30段公路", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }
  
  -- prototype "通向铁矿" {
  --   desc = "铺设20段公路",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"unknown", 0, 1},
  --   task_params = {},
  --   prerequisites = {"建造公路"},
  --   count = 20,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_road1.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_road2.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_road3.texture",
  --   },
  --   sign_desc = {
  --     { desc = "铺设道路从指挥中心到东南方向的铁矿", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }


  prototype "物流学1" {
    desc = "研究维修物流站的方法",
    type = { "tech" },
    effects = {
      unlock_recipe = {"维修物流站","维修物流中心"},
      unlock_item = {"物流站框架","物流站","物流中心框架","物流中心"},
    },
    prerequisites = {"公路研究"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 8,
    time = "4s"
  }

  -- prototype "恢复物流" {
  --   desc = "维修物流站",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "物流站"},
  --   prerequisites = {"物流学1"},
  --   count = 2,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用组装机维修2座物流站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置发货物流站" {
  --   desc = "放置1座物流站作为送货站",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "物流站"},
  --   prerequisites = {"恢复物流"},
  --   count = 1,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "铁矿和铝矿区的公路边放置1座物流站并设置发货类型", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "放置收货物流站" {
  --   desc = "放置1座物流站作为收货站",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"select_entity", 0, "物流站"},
  --   prerequisites = {"放置发货物流站"},
  --   count = 2,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  --   },
  --   sign_desc = {
  --     { desc = "在生产地质科技包组装机的公路边放置1座物流站并设置收货类型", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  prototype "汽修技术" {
    desc = "研究修理运输车辆工艺",
    type = { "tech" },
    effects = {
      unlock_recipe = {"维修运输汽车"},
      unlock_item = {"运输车辆I","破损运输车辆"},
    },
    prerequisites = {"物流学1"},
    ingredients = {
        {"地质科技包", 1},
    },
    count = 8,
    time = "4s"
  }

  -- prototype "维修运输车辆" {
  --   desc = "维修4辆运输车",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "运输车辆I"},
  --   prerequisites = {"汽修技术"},
  --   count = 4,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate1.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate2.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate3.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate4.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate5.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用组装机生产4辆运输车", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

  -- prototype "物流网络" {
  --   desc = "派遣2辆运输车",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"unknown", 0, 2},                          
  --   prerequisites = {"汽修技术"},
  --   count = 2,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate1.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate2.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate3.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate4.texture",
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ironplate5.texture",
  --   },
  --   sign_desc = {
  --     { desc = "指挥中心派遣2辆运输车", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }



prototype "气候研究1" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  effects = {
    unlock_recipe = {"气候科技包1"},
    unlock_item = {"气候科技包"},
  },
  prerequisites = {"汽修技术"},
  ingredients = {
      {"地质科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture"},
  },
  sign_icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture",
  count = 8,
  time = "5s"
}

prototype "建筑维修2" {
  desc = "获得维修流体处理机械的技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"维修水电站","维修空气过滤器","维修地下水挖掘机"},
    unlock_item = {"水电站框架","空气过滤器框架","地下水挖掘机框架"},
  },
  prerequisites = {"气候研究1"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 10,
  time = "4s"
}

prototype "管道系统1" {
  desc = "研究装载和运输流体的管道",
  type = { "tech" },
  effects = {
    unlock_recipe = {"管道1","管道2","液罐1"},
    unlock_item = {"液罐I","管道1-X型"},
  },
  prerequisites = {"气候研究1"},
  ingredients = {
      {"地质科技包", 1},
  },
  count = 10,
  time = "4s"
}

-- prototype "生产管道" {
--   desc = "生产可以传输流体原料的管道",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "管道1-X型"},
--   prerequisites = {"管道系统1"},
--   count = 10,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_pipe1.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机生产10个管道", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "建造空气过滤器" {
--   desc = "建造可以过滤空气的装置",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "空气过滤器I"},
--   prerequisites = {"建筑维修2","生产管道"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack2.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack3.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack4.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack5.texture",
--   },
--   sign_desc = {
--     { desc = "生产1个空气过滤器", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "重修水电站" {
--   desc = "维修水电站用于处理液体",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "水电站I"},
--   prerequisites = {"建筑维修2","生产管道"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack2.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack3.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack4.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack5.texture",
--   },
--   sign_desc = {
--     { desc = "使用组装机维修1座水电站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "放置水电站" {
--   desc = "水电站建造",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"select_entity", 0, "水电站I"},
--   prerequisites = {"重修水电站"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
--   },
--   sign_desc = {
--     { desc = "放置1座水电站", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "采集地下水" {
--   desc = "放置1座地下水挖掘机",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"select_entity", 0,  "地下水挖掘机I"},
--   prerequisites = {"放置水电站"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h21.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h22.texture",
--   },
--   sign_desc = {
--     { desc = "放置1座地下水挖掘机与水电站对应水口相连", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产气候科技包" {
--   desc = "生产科技包用于科技研究",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "气候科技包"},
--   prerequisites = {"生产管道"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack2.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack3.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack4.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_climatepack5.texture",
--   },
--   sign_desc = {
--     { desc = "使用水电站生产1个气候科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "收集空气" {
--   desc = "采集火星上的空气",
--   type = { "task" },
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   task = {"stat_production", 0, "空气"},
--   prerequisites = {"生产气候科技包"},
--   count = 20000,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_air1.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_air2.texture",
--   },
--   sign_desc = {
--     { desc = "用空气过滤器生产20000单位空气", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",},
--   },
-- }

prototype "排放1" {
  desc = "研究气体和液体的排放工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"烟囱1","排水口1","地下管1"},
    unlock_item = {"烟囱I","排水口I","地下管1-JI型"},
  },
  prerequisites = {"管道系统1"},
  ingredients = {
    {"气候科技包", 1},
  },
  count = 3,
  time = "2s"
}

  -- prototype "生产液罐" {
  --   desc = "生产可以存储流体的容器",
  --   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  --   type = { "task" },
  --   task = {"stat_production", 0, "液罐I"},
  --   prerequisites = {"生产管道","生产气候科技包"},
  --   count = 2,
  --   tips_pic = {
  --     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_pipe1.texture",
  --   },
  --   sign_desc = {
  --     { desc = "使用组装机生产2座液罐", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  --   },
  -- }

prototype "电解水" {
  desc = "对水通电产生电化学反应生成气体",
  type = { "tech" },
  effects = {
    unlock_recipe = {"地下卤水电解1"},
  },
  prerequisites = {"排放1"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 4,
  time = "4s"
}

prototype "建筑维修3" {
  desc = "获得维修机械的技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"维修太阳能板","维修蒸馏厂","维修电解厂"},
    unlock_item = {"太阳能板框架","蒸馏厂框架","电解厂框架"},
  },
  prerequisites = {"电解水"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 6,
  time = "4s"
}

prototype "空气分离工艺1" {
  desc = "获得火星大气分离出纯净气体的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"空气分离1"},
  },
  prerequisites = {"建筑维修3","电解水"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 4,
  time = "5s"
}

prototype "碳处理1" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"二氧化碳转甲烷"},
  },
  prerequisites = {"电解水"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 5,
  time = "4s"
}

-- prototype "放置太阳能板" {
--   desc = "放置2块太阳能板",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"select_entity", 0, "太阳能板I"},
--   prerequisites = {"碳处理1"},
--   count = 2,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
--   },
--   sign_desc = {
--     { desc = "放置2块太阳能板进行发电", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "放置电解厂" {
--   desc = "放置1座电解厂",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"select_entity", 0, "电解厂I"},
--   prerequisites = {"放置太阳能板"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h21.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h22.texture",
--   },
--   sign_desc = {
--     { desc = "放置1座电解厂进行电解", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "放置地下水挖掘机" {
--   desc = "放置1座地下水挖掘机",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"select_entity", 0,  "地下水挖掘机I"},
--   prerequisites = {"放置电解厂"},
--   count = 2,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h21.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h22.texture",
--   },
--   sign_desc = {
--     { desc = "放置1座地下水挖掘机与电解厂对应水口相连", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }


-- prototype "生产氢气" {
--   desc = "生产工业气体氢气",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "氢气"},
--   prerequisites = {"碳处理1"},
--   count = 500,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h21.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_h22.texture",
--   },
--   sign_desc = {
--     { desc = "电解厂电解卤水生产500个单位氢气,并使用液罐储存生产氢气", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "放置蒸馏厂" {
--   desc = "放置可以蒸馏并分离流体的工厂",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"select_entity", 0, "蒸馏厂I"},
--   prerequisites = {"生产氢气","放置太阳能板"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_click_build.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_chemicalplant.texture",
--   },
--   sign_desc = {
--     { desc = "放置1座蒸馏厂", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产二氧化碳" {
--   desc = "生产工业气体二氧化碳",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "二氧化碳"},
--   prerequisites = {"碳处理1"},
--   count = 500,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_co21.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_co22.texture",
--   },
--   sign_desc = {
--     { desc = "蒸馏厂分离空气生产500个单位二氧化碳", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

prototype "加热卤水发电" {
  desc = "研究通过加热卤水获得蒸汽驱动发电机",
  type = { "tech" },
  effects = {
    unlock_recipe = {"卤水沸腾"},
  },
  prerequisites = {"碳处理1"},
  ingredients = {
      {"气候科技包", 1},
  },
  count = 10,
  time = "3s"
}


prototype "建筑维修4" {
  desc = "获得维修机械的技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"维修化工厂","维修蒸汽发电机","维修组装机"},
    unlock_item = {"化工厂框架","蒸汽发电机框架","组装机框架"},
  },
  prerequisites = {"空气分离工艺1","加热卤水发电"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
  },
  count = 8,
  time = "4s"
}

prototype "碳处理2" {
  desc = "含碳气体化合成其他物质的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"甲烷转乙烯","二氧化碳转一氧化碳","一氧化碳转石墨"},
    unlock_item = {"石墨"},
  },
  prerequisites = {"建筑维修4"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},

  },
  count = 8,
  time = "2s"
}


prototype "冶金学1" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"熔炼炉1"},
    unlock_item = {"熔炼炉I"},
  },
  prerequisites = {"碳处理2"},
  ingredients = {
    {"地质科技包", 1},
  },
  count = 12,
  time = "4s"
}

-- prototype "放置化工厂" {
--   desc = "放置可以生产化工产品的工厂",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"select_entity", 0, "化工厂I"},
--   prerequisites = {"建筑维修3","生产氢气","生产二氧化碳"},
--   count = 1,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_click_build.texture",
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_chemicalplant.texture",
--   },
--   sign_desc = {
--     { desc = "放置1座化工厂", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产甲烷" {
--   desc = "生产工业气体甲烷",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "甲烷"},
--   prerequisites = {"建筑维修3"},
--   count = 1000,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ch4.texture",
--   },
--   sign_desc = {
--     { desc = "用化工厂生产1000个单位甲烷", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

prototype "有机化学1" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  effects = {
    unlock_recipe = {"塑料1"},
    unlock_item = {"塑料"},
  },
  prerequisites = {"冶金学1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 6,
  time = "10s"
}

-- prototype "生产乙烯" {
--   desc = "生产工业气体乙烯",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "乙烯"},
--   prerequisites = {"有机化学1"},
--   count = 1000,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_ch4.texture",
--   },
--   sign_desc = {
--     { desc = "用化工厂生产1000个单位乙烯", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

-- prototype "生产塑料" {
--   desc = "用有机化学的原理生产质量轻、耐腐蚀的化工材料塑料",
--   icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
--   type = { "task" },
--   task = {"stat_production", 0, "塑料"},
--   prerequisites = {"生产乙烯"},
--   count = 30,
--   tips_pic = {
--     "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
--   },
--   sign_desc = {
--     { desc = "用化工厂生产30个塑料", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
--   },
-- }

prototype "电磁学1" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电动机T1"},
    unlock_item = {"电动机I"},
  },
  prerequisites = {"有机化学1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 6,
  time = "5s"
}

--研究机械科技瓶
prototype "机械研究" {
  desc = "对可在火星表面作业的机械装置进行改进和开发",
  type = { "tech" },
  effects = {
    unlock_recipe = {"机械科技包T1"},
    unlock_item = {"机械科技包"},
  },
  prerequisites = {"电磁学1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 8,
  time = "5s",
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture"},
  },
  sign_icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture",
}

prototype "生产机械科技包" {
  desc = "生产机械科技包用于科技研究",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "机械科技包"},
  prerequisites = {"机械研究"},
  count = 3,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产3个机械科技包", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}


prototype "挖掘1" {
  desc = "研究对火星岩石的开采技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"采矿机1"},
    unlock_item = {"采矿机I"},
  },
  prerequisites = {"生产机械科技包"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
  },
  count = 8,
  time = "5s"
}


prototype "仓库存储" {
  desc = "使用仓库存储物品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"仓库1"},
  },
  prerequisites = {"生产机械科技包"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 5,
  time = "12s"
}

prototype "无人机运输1" {
  desc = "使用无人机快速运送物品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"无人机平台1"},
  },
  prerequisites = {"仓库存储"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 4,
  time = "15s"
}

prototype "蒸馏1" {
  desc = "将液体混合物汽化并分离的技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蒸馏厂1"},
    unlock_item = {"蒸馏厂I"},
  },
  prerequisites = {"挖掘1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 6,
  time = "5s"
}

prototype "泵系统1" {
  desc = "使用机械方式加快流体流动",
  type = { "tech" },
  effects = {
    unlock_recipe = {"压力泵1"},
    unlock_item = {"压力泵I"},
  },
  prerequisites = {"蒸馏1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "6s"
}

prototype "自动化1" {
  desc = "使用3D打印技术复制物品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"组装机1"},
    unlock_item = {"组装机I"},
  },
  prerequisites = {"蒸馏1","泵系统1","无人机运输1"},
  ingredients = {
    {"机械科技包", 1},
  },
  count = 6,
  time = "8s"
}

prototype "物流车站1" {
  desc = "研究供运输车辆装卸货物的物流点",
  type = { "tech" },
  effects = {
    unlock_recipe = {"物流站打印"},
  },
  prerequisites = {"自动化1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 6,
  time = "10s"
}

prototype "物流中心研究" {
  desc = "研究供运输车辆装卸货物的物流点",
  type = { "tech" },
  effects = {
    unlock_recipe = {"物流中心打印"},
  },
  prerequisites = {"自动化1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 10,
  time = "10s"
}

prototype "地下水净化1" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"地下卤水净化","地下水挖掘机1","水电站1"},
    unlock_item = {"地下水挖掘机I","水电站I"},
  },
  prerequisites = {"蒸馏1","泵系统1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "8s"
}

prototype "过滤1" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"空气过滤器1"},
    unlock_item = {"空气过滤器I"},
  },
  prerequisites = {"地下水净化1"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "10s"
}

prototype "炼钢" {
  desc = "将铁冶炼成更坚硬金属的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"钢板1"},
    unlock_item = {"钢板"},
  },
  prerequisites = {"挖掘1","物流车站1","物流中心研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "10s"
}

prototype "大炼钢铁" {
  desc = "生产更多的钢板",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "钢板"},
  prerequisites = {"炼钢"},
  count = 20,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用熔炼炉生产20个钢板", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "矿物处理1" {
  desc = "将矿物进行碾碎并再加工的机械工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"粉碎机1","沙子1"},
    unlock_item = {"粉碎机I","沙子"},
  },
  prerequisites = {"挖掘1","自动化1","大炼钢铁"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "10s"
}

prototype "矿石粉碎" {
  desc = "将碎石粉碎获得沙子",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "沙子"},
  prerequisites = {"矿物处理1"},
  count = 20,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用粉碎机生产20个沙子", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "地质研究2" {
  desc = "对火星地质结构进行标本采集和研究",
  type = { "tech" },
  effects = {
    unlock_recipe = {"地质科技包2"},
  },
  ingredients = {
      {"地质科技包", 1},
  },
  count = 20,
  time = "5s",
  prerequisites = {"矿物处理1"},
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture"},
  },
  sign_icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture",
}

prototype "钢加工" {
  desc = "对钢板进行再加工获得钢齿轮",
  type = { "tech" },
  effects = {
    unlock_recipe = {"钢齿轮"},
    unlock_item = {"钢齿轮"},
  },
  prerequisites = {"大炼钢铁"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "8s"
}

prototype "发电机1" {
  desc = "使用蒸汽作为工质将热能转为机械能的发电装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蒸汽发电机1"},
    unlock_item = {"蒸汽发电机I"},
  },
  prerequisites = {"钢加工"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 4,
  time = "15s"
}

prototype "打造钢齿轮" {
  desc = "生产更多的钢齿轮",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "钢齿轮"},
  prerequisites = {"钢加工"},
  count = 20,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产30个钢齿轮", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "浮选1" {
  desc = "使用浮选设备对矿石实行筛选",
  type = { "tech" },
  effects = {
    unlock_recipe = {"浮选器1"},
    unlock_item = {"浮选器I"},
  },
  prerequisites = {"矿石粉碎","发电机1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 5,
  time = "8s"
}

prototype "硅处理" {
  desc = "从沙子中提炼硅的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"硅1","玻璃1"},
    unlock_item = {"硅","玻璃"},
  },
  prerequisites = {"浮选1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 5,
  time = "8s"
}

prototype "铁矿熔炼2" {
  desc = "将铁矿石冶炼成铁板的更高效工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"铁板2"},
  },
  prerequisites = {"打造钢齿轮"},
  ingredients = {
      {"地质科技包", 1},
      {"机械科技包", 1},
  },
  count = 4,
  time = "8s"
}

prototype "电解1" {
  desc = "使用电化学手段制取工业气体",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电解厂1","地下卤水电解2"},
    unlock_item = {"电解厂I","氢氧化钠"},
  },
  prerequisites = {"铁矿熔炼2"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 5,
  time = "12s"
}

prototype "有机化学2" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  effects = {
    unlock_recipe = {"乙烯转丁二烯","纯水转蒸汽"},
  },
  prerequisites = {"硅处理","电解1"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 8,
  time = "8s"
}

prototype "管道系统2" {
  desc = "研究可储藏流体原料的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"液罐2"},
    unlock_item = {"液罐II"},

  },
  prerequisites = {"硅处理","有机化学2"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 6,
  time = "10s"
}

prototype "化学工程1" {
  desc = "使用特殊设施生产化工产品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"化工厂1","纯水电解"},
    unlock_item = {"化工厂I"},
  },
  prerequisites = {"有机化学2","管道系统2"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 6,
  time = "10s"
}

prototype "无机化学" {
  desc = "使用无机化合物合成物质的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"酸碱中和","碱性溶液","盐酸"},
    unlock_item = {"碱性溶液","盐酸"},
  },
  prerequisites = {"化学工程1"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 10,
  time = "5s"
}

prototype "废料回收1" {
  desc = "将工业废料、矿石进行回收处理的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"铁矿石回收","碎石回收","沙子回收","废料中和"},
  },
  prerequisites = {"无机化学"},
  ingredients = {
      {"地质科技包", 1},
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 10,
  time = "6s"
}

prototype "石头处理3" {
  desc = "研究可进行高温加工的特殊器皿",
  type = { "tech" },
  effects = {
    unlock_recipe = {"坩埚"},
    unlock_item = {"坩埚"},
  },
  prerequisites = {"硅处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 8,
  time = "8s"
}

prototype "坩埚制造" {
  desc = "生产可高温加工的坩埚",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "坩埚"},
  prerequisites = {"石头处理3"},
  count = 10,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产10个坩埚", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "锅炉制造" {
  desc = "研究可进行高温加工的特殊器皿",
  type = { "tech" },
  effects = {
    unlock_recipe = {"锅炉"},
    unlock_item = {"锅炉I"},
  },
  prerequisites = {"坩埚制造"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 10,
  time = "6s"
}

prototype "有机化学3" {
  desc = "研究碳化合物组成、结构和制备方法",
  type = { "tech" },
  effects = {
    unlock_recipe = {"橡胶"},
    unlock_item = {"橡胶"},
  },
  prerequisites = {"化学工程1","锅炉制造"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 12,
  time = "8s"
}

prototype "物流学2" {
  desc = "研究物流相关的建筑和机械",
  type = { "tech" },
  effects = {
    unlock_recipe = {"车辆装配"},
  },
  prerequisites = {"有机化学3"},
  ingredients = {
      {"地质科技包", 1},
      {"机械科技包", 1},
  },
  count = 20,
  time = "5s"
}

prototype "无人机运输2" {
  desc = "使用无人机快速运送物品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"无人机平台2"},
    unlock_item = {"无人机平台II"},
  },
  prerequisites = {"坩埚制造","物流学2"},
  ingredients = {
      {"气候科技包", 1},
      {"机械科技包", 1},
  },
  count = 20,
  time = "8s"
}

prototype "冶金学2" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"熔炼炉2"},
    unlock_item = {"熔炼炉II"},
  },
  prerequisites = {"石头处理3","铁矿熔炼2"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 20,
  time = "6s"
}

prototype "铝生产" {
  desc = "加工铝矿的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"碾碎铝矿石","铝矿石浮选","氧化铝","铝板1","氢氧化铝"},
    unlock_item = {"铝板","碾碎铝矿石","碾碎铁矿石","氧化铝","碳化铝"},
  },
  prerequisites = {"无机化学","冶金学2"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 20,
  time = "8s"
}

prototype "硅生产" {
  desc = "将硅加工成硅板的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"硅板1"},
    unlock_item = {"硅板"},
  },
  prerequisites = {"无机化学","冶金学2"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
  },
  count = 20,
  time = "6s"
}

prototype "硅板制造" {
  desc = "生产大量的硅板",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "硅板"},
  prerequisites = {"硅生产"},
  count = 30,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用熔炼炉生产30个硅板", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "润滑" {
  desc = "研究工业润滑油制作工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"润滑油"},
    unlock_item = {"润滑油"},
  },
  prerequisites = {"硅生产"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 20,
  time = "5s"
}

prototype "铝加工" {
  desc = "使用铝加工其他零器件的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"铝丝1","铝棒1"},
    unlock_item = {"铝丝","铝棒"},
  },
  prerequisites = {"铝生产","冶金学2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 25,
  time = "8s"
}

prototype "铝丝制造" {
  desc = "生产铝制的金属丝",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "铝丝"},
  prerequisites = {"铝加工"},
  count = 40,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产40个铝丝", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "沸腾实验" {
  desc = "通过加热液体获取蒸汽的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"纯水沸腾"},
    -- unlock_item = {"换热器I","热管1-X型"},
  },
  prerequisites = {"铝丝制造"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 15,
  time = "5s"
}

prototype "电子器件1" {
  desc = "生产精密的电子元器件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电容1","绝缘线1","逻辑电路1"},
    unlock_item = {"电容I","绝缘线","逻辑电路"},
  },
  prerequisites = {"铝加工","硅生产"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 30,
  time = "5s"
}

prototype "太阳能存储1" {
  desc = "研究将太阳能板转化的电能进行储存的电池",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蓄电池1"},
    unlock_item = {"蓄电池I"},
  },
  prerequisites = {"电子器件1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 20,
  time = "15s"
}

prototype "电子研究" {
  desc = "研究由电能作用的材料或设备",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电子科技包1"},
    unlock_item = {"电子科技包"},
  },
  prerequisites = {"电子器件1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture"},
  },
  sign_icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture",
  count = 50,
  time = "4s"
}

---------------------------化学研究---------------------------
prototype "电磁学2" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电动机2"},
    unlock_item = {"电动机II"},

  },
  prerequisites = {"电子研究"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 30,
  time = "10s"
}

prototype "研究设施1" {
  desc = "研究可以开展大规模研发的设施",
  type = { "tech" },
  effects = {
    unlock_recipe = {"科研中心1"},
    unlock_item = {"科研中心I"},
  },
  prerequisites = {"电子研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 15,
  time = "10s"
}


prototype "科技大跃进" {
  desc = "生产更多的科研中心I",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "科研中心I"},
  prerequisites = {"研究设施1"},
  count = 3,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产3个科研中心", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}


prototype "信号处理" {
  desc = "研究电子信号传输介质",
  type = { "tech" },
  effects = {
    unlock_recipe = {"数据线1"},
    unlock_item = {"数据线"},
  },
  prerequisites = {"研究设施1"},
  ingredients = {
    {"气候科技包", 1},
    {"电子科技包", 1},
  },
  count = 30,
  time = "15s"
}
  

prototype "计算元件" {
  desc = "研究可进行复杂计算的电路集群",
  type = { "tech" },
  effects = {
    unlock_recipe = {"运算电路1"},
    unlock_item = {"运算电路"},
  },
  prerequisites = {"信号处理"},
  ingredients = {
    {"气候科技包", 1},
    {"电子科技包", 1},
  },
  count = 70,
  time = "10s"
}

prototype "电解2" {
  desc = "使用电化学手段制取工业气体",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电解厂2"},
    unlock_item = {"电解厂II"},
  },
  prerequisites = {"计算元件"},
  ingredients = {
    {"气候科技包", 1},
    {"电子科技包", 1},
  },
  count = 80,
  time = "15s"
}

prototype "挖掘2" {
  desc = "研究对火星岩石的开采技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"采矿机2"},
    unlock_item = {"采矿机II"},
  },
  prerequisites = {"计算元件"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 50,
  time = "15s"
}

prototype "水能利用" {
  desc = "研究淡水处理的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"淡水沸腾","淡水过滤"},
  },
  prerequisites = {"计算元件"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 40,
  time = "15s"
}

prototype "自动化2" {
  desc = "使用3D打印技术复制物品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"组装机2"},
    unlock_item = {"组装机II"},
  },
  prerequisites = {"水能利用"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 60,
  time = "15s"
}

prototype "发电机2" {
  desc = "使用蒸汽作为工质将热能转为机械能的发电装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蒸汽发电机2"},
    unlock_item = {"蒸汽发电机II"},
  },
  prerequisites = {"自动化2"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 70,
  time = "25s"
}

prototype "优化1" {
  desc = "研究提高生产效率的插件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"效能插件1","速度插件1","产能插件1"},
    unlock_item = {"效能插件I","速度插件I","产能插件I"},
  },
  prerequisites = {"发电机2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 60,
  time = "20s"
}

-- prototype "广播1" {
--   desc = "研究可影响周边生产设施工作效率的装置",
--   type = { "tech" },
--   effects = {
--     unlock_recipe = {"广播塔1"},
--     unlock_item = {"广播塔I"},
--   },
--   prerequisites = {"发电机2"},
--   ingredients = {
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--     {"电子科技包", 1},
--   },
--   count = 70,
--   time = "25s"
-- }

prototype "效能提升" {
  desc = "生产可以降低机器能耗的插件",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "效能插件I"},
  prerequisites = {"优化1"},
  count = 5,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个效能插件I", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "速度提升" {
  desc = "生产可以加速机器生产的插件",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "速度插件I"},
  prerequisites = {"优化1"},
  count = 5,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个速度插件I", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "产能提升" {
  desc = "生产可以提高机器产能的插件",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "产能插件I"},
  prerequisites = {"优化1"},
  count = 5,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个产能插件I", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "矿物处理2" {
  desc = "将矿物进行碾碎并再加工的机械工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"粉碎机2"},
    unlock_item = {"粉碎机II"},
  },
  prerequisites = {"优化1"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 60,
  time = "25s"
}

prototype "氮化学" {
  desc = "研究含氮的化合物生产",
  type = { "tech" },
  effects = {
    unlock_recipe = {"氨气"},
    unlock_item = {"氨气"},
  },
  prerequisites = {"矿物处理2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 80,
  time = "15s"
}

prototype "氨制造" {
  desc = "生产工业气体氨气",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "氨气"},
  prerequisites = {"氮化学"},
  count = 500,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用组装机生产5个速度插件I", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "气候研究2" {
  desc = "对火星大气成分进行标本采集和研究",
  type = { "tech" },
  effects = {
    unlock_recipe = {"气候科技包2"},
  },
  prerequisites = {"氮化学"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 100,
  time = "15s"
}

prototype "玻璃制造" {
  desc = "研究更高效生产玻璃的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"玻璃2"},
  },
  prerequisites = {"气候研究2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 90,
  time = "15s"
}

prototype "建筑材料" {
  desc = "研究可以用于建材的新型材料",
  type = { "tech" },
  effects = {
    unlock_item = {"混凝土"},
  },
  prerequisites = {"玻璃制造"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 120,
  time = "15s"
}

prototype "地下水净化2" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"水电站2","地下水挖掘机2"},
    unlock_item = {"水电站II","地下水挖掘机II"},
  },
  prerequisites = {"建筑材料"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 160,
  time = "20s"
}

prototype "地热1" {
  desc = "研究开发地热资源的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"地热井1"},
    unlock_item = {"地热井I"},
  },
  prerequisites = {"建筑材料"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 120,
  time = "20s"
}

prototype "太阳能1" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"太阳能板1"},
    unlock_item = {"太阳能板I"},
  },
  prerequisites = {"建筑材料"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 150,
  time = "30s"
}

prototype "铺设太阳能板" {
  desc = "铺设更多的太阳能板",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = {"task" },
  task = {"select_entity", 0, "太阳能板I"},
  prerequisites = {"太阳能1"},
  count = 20,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_place_logistics.texture",
  },
  sign_desc = {
    { desc = "放置20个太阳能板I", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "蒸馏2" {
  desc = "将液体混合物汽化并分离的技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蒸馏厂2"},
    unlock_item = {"蒸馏厂II"},
  },
  prerequisites = {"太阳能1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 120,
  time = "30s"
}

prototype "硫磺处理" {
  desc = "加工含硫地热气获得其他化工品的工艺",
  type = { "tech" },
  effects = {
    unlock_item = {"硫酸"},
  },
  prerequisites = {"太阳能1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
  },
  count = 120,
  time = "30s"
}

prototype "硫酸生产" {
  desc = "生产大量的硫酸",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "硫酸"},
  prerequisites = {"硫磺处理"},
  count = 500,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产500个单位硫酸", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "过滤2" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"空气过滤器2"},
    unlock_item = {"空气过滤器II"},
  },
  prerequisites = {"硫磺处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 150,
  time = "30s"
}

prototype "浮选2" {
  desc = "使用浮选设备对矿石实行筛选",
  type = { "tech" },
  effects = {
    unlock_recipe = {"浮选器2"},
    unlock_item = {"浮选器II"},
  },
  prerequisites = {"硫磺处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 160,
  time = "30s"
}

prototype "化学工程2" {
  desc = "使用特殊设施生产化工产品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"化工厂2"},
    unlock_item = {"化工厂II"},
  },
  prerequisites = {"硫磺处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  count = 200,
  time = "30s"
}

prototype "化学研究" {
  desc = "对化学反应进行深度研究",
  type = { "tech" },
  effects = {
    unlock_recipe = {"化学科技包1"},
    unlock_item = {"化学科技包"},
  },
  prerequisites = {"过滤2","浮选2","化学工程2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
  },
  sign_desc = {
    { desc = "该科技是一项前沿科技，可引导其他的科技研究", icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture"},
  },
  sign_icon = "/pkg/vaststars.resources/ui/textures/science/key_sign.texture",
  count = 250,
  time = "30s"
}


---------------------------------物流研究-------------------------------------

prototype "钠处理" {
  desc = "研究获取钠原料的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"氢氧化钠电解"},
    unlock_item = {"钠"},
  },
  prerequisites = {"化学研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 150,
  time = "30s"
}

prototype "空气分离工艺2" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"空气分离2"},
    unlock_item = {"氦气"},
  },
  prerequisites = {"化学研究"},
  ingredients = {
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 160,
  time = "30s"
}

prototype "氦气生产" {
  desc = "生产更多的氦气",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "氦气"},
  prerequisites = {"空气分离工艺2"},
  count = 500,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产500个单位氦气", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "排放2" {
  desc = "研究气体和液体的排放工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"烟囱2","排水口2"},
    unlock_item = {"烟囱II","排水口II"},
  },
  prerequisites = {"氦气生产"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 250,
  time = "30s"
}

prototype "钛生产1" {
  desc = "研究可以提取钛原料的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"金红石1"},
    unlock_item = {"金红石"},
  },
  prerequisites = {"氦气生产"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 300,
  time = "30s"
}

prototype "高温分解" {
  desc = "研究在高温下化合石墨的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"甲烷转石墨"},
  },
  prerequisites = {"钠处理"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 200,
  time = "30s"
}

prototype "电池存储1" {
  desc = "研究可以储存和释放电能的元件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电池1"},
    unlock_item = {"电池I"},
  },
  prerequisites = {"高温分解"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 300,
  time = "30s"
}

prototype "电池制造" {
  desc = "生产更多的电池元件",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "电池I"},
  prerequisites = {"电池存储1"},
  count = 20,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用化工厂生产20个电池", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "复合材料" {
  desc = "多种材料组合成多相材料",
  type = { "tech" },
  effects = {
    unlock_recipe = {"玻璃纤维1"},
    unlock_item = {"玻璃纤维"},
  },
  prerequisites = {"电池存储1"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"化学科技包", 1},
  },
  count = 450,
  time = "30s"
}

prototype "太阳能存储2" {
  desc = "研究将太阳能板转化的电能进行储存的电池",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蓄电池2"},
    unlock_item = {"蓄电池II"},
  },
  prerequisites = {"复合材料"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1}, 
    {"化学科技包", 1},
  },
  count = 320,
  time = "30s"
}

prototype "钛生产2" {
  desc = "研究可以提取钛原料的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"四氯化钛","钛板"},
    unlock_item = {"四氯化钛","钛板"},
  },
  prerequisites = {"太阳能存储2","钛生产1"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "钛板生产" {
  desc = "生产更多的钛板",
  icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture",
  type = { "task" },
  task = {"stat_production", 0, "钛板"},
  prerequisites = {"钛生产2"},
  count = 30,
  tips_pic = {
    "/pkg/vaststars.resources/ui/textures/task_tips_pic/task_produce_plastic.texture",
  },
  sign_desc = {
    { desc = "用浮选器生产30个钛板", icon = "/pkg/vaststars.resources/ui/textures/construct/industry.texture"},
  },
}

prototype "无人机运输3" {
  desc = "使用无人机快速运送物品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"无人机平台3"},
    unlock_item = {"无人机平台III"},
  },
  prerequisites = {"钛生产2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "自动化3" {
  desc = "使用3D打印技术复制物品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"组装机3"},
    unlock_item = {"组装机III"},
  },
  prerequisites = {"钛生产2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "挖掘3" {
  desc = "研究对火星岩石的开采技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"采矿机3"},
    unlock_item = {"采矿机III"},
  },
  prerequisites = {"钛生产2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 350,
  time = "30s"
}

prototype "电子器件2" {
  desc = "生产精密的电子元器件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"处理器1"},
    unlock_item = {"处理器I"},
  },
  prerequisites = {"无人机运输3","自动化3","挖掘3"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 360,
  time = "30s"
}

-- prototype "广播2" {
--   desc = "研究可影响周边生产设施工作效率的装置",
--   type = { "tech" },
--   effects = {
--     unlock_recipe = {"广播塔2"},
--     unlock_item = {"广播塔II"},
--   },
--   prerequisites = {"电子器件2"},
--   ingredients = {
--     {"地质科技包", 1},  
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--     {"电子科技包", 1},
--     {"化学科技包", 1},
--   },
--   count = 380,
--   time = "30s"
-- }

prototype "优化2" {
  desc = "研究提高生产效率的插件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"效能插件2","速度插件2","产能插件2"},
    unlock_item = {"效能插件II","速度插件II","产能插件II"},
  },
  prerequisites = {"电子器件2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 400,
  time = "30s"
}

prototype "矿物处理3" {
  desc = "将矿物进行碾碎并再加工的机械工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"粉碎机3"},
    unlock_item = {"粉碎机III"},
  },
  prerequisites = {"优化2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 420,
  time = "30s"
}

prototype "太阳能2" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"太阳能板2"},
    unlock_item = {"太阳能板II"},
  },
  prerequisites = {"优化2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 420,
  time = "30s"
}

prototype "管道系统3" {
  desc = "研究可储藏流体原料的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"液罐3"},
    unlock_item = {"液罐III"},
  },
  prerequisites = {"优化2"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"化学科技包", 1},
  },
  count = 420,
  time = "30s"
}

prototype "地热2" {
  desc = "研究开发地热资源的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"地热井2"},
    unlock_item = {"地热井II"},
  },
  prerequisites = {"矿物处理3","太阳能2","管道系统3"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 500,
  time = "30s"
}

prototype "研究设施2" {
  desc = "研究可以开展大规模研发的设施",
  type = { "tech" },
  effects = {
    unlock_recipe = {"科研中心2"},
    unlock_item = {"科研中心II"},
  },
  prerequisites = {"矿物处理3","太阳能2","管道系统3"},
  ingredients = {
    {"地质科技包", 1},  
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 550,
  time = "30s"
}

prototype "高温防护" {
  desc = "研究能够耐高温的材料",
  type = { "tech" },
  effects = {
    unlock_recipe = {"隔热板1"},
    unlock_item = {"隔热板"},
  },
  prerequisites = {"研究设施2","地热2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 600,
  time = "35s"
}

prototype "物理研究" {
  desc = "研究物质结构以及基本运动规律",
  type = { "tech" },
  effects = {
    unlock_recipe = {"物理科技包1"},
    unlock_item = {"物理科技包"},
  },
  prerequisites = {"高温防护"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
  },
  count = 800,
  time = "40s"
}

--------------------------------------rocket-------------------------------------
prototype "电磁学3" {
  desc = "研究电能转换成机械能的基础供能装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电动机3"},
    unlock_item = {"电动机III"},
  },
  prerequisites = {"物理研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 500,
  time = "40s"
}

prototype "研究设施3" {
  desc = "研究可以开展大规模研发的设施",
  type = { "tech" },
  effects = {
    unlock_recipe = {"科研中心3"},
    unlock_item = {"科研中心III"},
  },
  prerequisites = {"物理研究"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 500,
  time = "40s"
}

prototype "机械研究2" {
  desc = "研究可以开展大规模研发的设施",
  type = { "tech" },
  effects = {
    unlock_recipe = {"机械科技包2"},
  },
  prerequisites = {"物理研究"},
  ingredients = {
    {"地质科技包", 1},
    {"机械科技包", 1},
    {"物理科技包", 1},
  },
  count = 500,
  time = "40s"
}

prototype "石墨分离" {
  desc = "研究将石墨分离成单层材料的工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"石墨烯"},
    unlock_item = {"石墨烯"},
  },
  prerequisites = {"研究设施3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 800,
  time = "40s"
}

prototype "地下水净化3" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"水电站3"},
    unlock_item = {"水电站III"},
  },
  prerequisites = {"电磁学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 800,
  time = "40s"
}

prototype "过滤3" {
  desc = "火星地下开采卤水进行过滤净化工艺",
  type = { "tech" },
  effects = {
    unlock_recipe = {"空气过滤器3"},
    unlock_item = {"空气过滤器III"},
  },
  prerequisites = {"电磁学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 800,
  time = "40s"
}

prototype "冶金学3" {
  desc = "研究工业高温熔炼的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"熔炼炉3"},
    unlock_item = {"熔炼炉III"},
  },
  prerequisites = {"电磁学3","研究设施3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 900,
  time = "40s"
}

prototype "浮选3" {
  desc = "使用浮选设备对矿石实行筛选",
  type = { "tech" },
  effects = {
    unlock_recipe = {"浮选器3"},
    unlock_item = {"浮选器III"},
  },
  prerequisites = {"冶金学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 900,
  time = "40s"
}

prototype "蒸馏3" {
  desc = "将液体混合物汽化并分离的技术",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蒸馏厂3"},
    unlock_item = {"蒸馏厂III"},
  },
  prerequisites = {"冶金学3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1000,
  time = "40s"
}

prototype "发电机3" {
  desc = "使用蒸汽作为工质将热能转为机械能的发电装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蒸汽发电机3"},
    unlock_item = {"蒸汽发电机III"},
  },
  prerequisites = {"浮选3","蒸馏3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1000,
  time = "40s"
}

prototype "微型化" {
  desc = "研究更加精密的电容元器件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电容2"},
    unlock_item = {"电容II"},
  },
  prerequisites = {"发电机3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1000,
  time = "40s"
}

prototype "电池存储2" {
  desc = "研究可以储存和释放电能的小型装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电池2"},
    unlock_item = {"电池II"},
  },
  prerequisites = {"微型化"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1100,
  time = "40s"
}

prototype "电解3" {
  desc = "使用电化学手段制取工业气体",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电解厂3"},
    unlock_item = {"电解厂III"},
  },
  prerequisites = {"电池存储2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1100,
  time = "40s"
}

prototype "电子器件3" {
  desc = "研究更加精密的电容元器件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"处理器2"},
    unlock_item = {"处理器II"},
  },
  prerequisites = {"电池存储2"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1200,
  time = "40s"
}

prototype "地热3" {
  desc = "研究开发地热资源的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"地热井3"},
    unlock_item = {"地热井III"},
  },
  prerequisites = {"电解3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1200,
  time = "40s"
}

prototype "化学工程3" {
  desc = "使用特殊设施生产化工产品",
  type = { "tech" },
  effects = {
    unlock_recipe = {"化工厂3"},
    unlock_item = {"化工厂III"},
  },
  prerequisites = {"电解3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1200,
  time = "40s"
}

prototype "太阳能3" {
  desc = "研究利用太阳能发电的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"太阳能板3"},
    unlock_item = {"太阳能板III"},
  },
  prerequisites = {"地热3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1300,
  time = "40s"
}

prototype "优化3" {
  desc = "研究提高生产效率的插件",
  type = { "tech" },
  effects = {
    unlock_recipe = {"效能插件3","速度插件3","产能插件3"},
    unlock_item = {"效能插件III","速度插件III","产能插件III"},
  },
  prerequisites = {"太阳能3","化学工程3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1400,
  time = "45s"
}

prototype "太阳能存储3" {
  desc = "研究将太阳能板转化的电能进行储存的电池",
  type = { "tech" },
  effects = {
    unlock_recipe = {"蓄电池3"},
    unlock_item = {"蓄电池III"},
  },
  prerequisites = {"优化3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1400,
  time = "45s"
}

-- prototype "广播3" {
--   desc = "研究可影响周边生产设施工作效率的装置",
--   type = { "tech" },
--   effects = {
--     unlock_recipe = {"广播塔3"},
--     unlock_item = {"广播塔III"},
--   },
--   prerequisites = {"太阳能3"},
--   ingredients = {
--     {"地质科技包", 1},
--     {"气候科技包", 1},
--     {"机械科技包", 1},
--     {"电子科技包", 1},
--     {"化学科技包", 1},
--     {"物理科技包", 1},
--   },
--   count = 1400,
--   time = "45s"
-- }

prototype "碳纳米科技" {
  desc = "研究可影响周边生产设施工作效率的装置",
  type = { "tech" },
  effects = {
    unlock_recipe = {"碳纳米管"},
    unlock_item = {"碳纳米管"},
  },
  prerequisites = {"太阳能3"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1400,
  time = "45s"
}

prototype "太空电梯牵引" {
  desc = "研究可供火箭运行的燃料",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电梯绳缆"},
    unlock_item = {"电梯绳缆"},
  },
  prerequisites = {"碳纳米科技"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1500,
  time = "45s"
}

prototype "太空电梯承重" {
  desc = "研究控制火箭运行的仪器",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电梯配重"},
    unlock_item = {"电梯配重"},
  },
  prerequisites = {"太空电梯牵引"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1500,
  time = "45s"
}

prototype "太空电梯装载" {
  desc = "研究组成火箭外部框架",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电梯厢体"},
    unlock_item = {"电梯厢体"},
  },
  prerequisites = {"太空电梯承重"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1500,
  time = "45s"
}

prototype "空间站" {
  desc = "研究保护火箭前端的特殊材料",
  type = { "tech" },
  effects = {
    unlock_recipe = {"电梯空间站"},
    unlock_item = {"电梯空间站"},
  },
  prerequisites = {"太空电梯装载"},
  ingredients = {
    {"地质科技包", 1},
    {"气候科技包", 1},
    {"机械科技包", 1},
    {"电子科技包", 1},
    {"化学科技包", 1},
    {"物理科技包", 1},
  },
  count = 1500,
  time = "45s"
}

