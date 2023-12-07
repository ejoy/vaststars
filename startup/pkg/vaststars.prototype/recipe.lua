local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "铁板1" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  11,
    recipe_icon = "/pkg/vaststars.resources/textures/icons/recipe/plate-Fe-1.texture",
    ingredients = {
        {"铁矿石", 3},
    },
    results = {
        {"铁板", 1},
    },
    time = "6s",
    description = "铁矿石通过金属冶炼获得铁板",
}

prototype "轻质石砖" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    recipe_category =  "物流",
    recipe_order =  12,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/stone-brick.texture",
    ingredients = {
        {"碎石", 3},
        {"铝矿石", 2},
    },
    results = {
        {"轻质石砖", 1},
    },
    time = "3s",
    description = "铁矿石通过金属冶炼获得铁板",
}

prototype "铁板T1" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  11,
    recipe_icon = "/pkg/vaststars.resources/textures/icons/recipe/plate-Fe-1.texture",
    ingredients = {
        {"铁矿石", 5},
    },
    results = {
        {"铁板", 2},
        {"碎石", 1},
    },
    time = "8s",
    description = "铁矿石通过金属冶炼获得铁板",
}

prototype "铁板2" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  12,
    recipe_icon = "/pkg/vaststars.resources/textures/icons/recipe/plate-Fe-2.texture",
    ingredients = {
        {"碾碎铁矿石", 8},
        {"石墨", 1}
    },
    results = {
        {"铁板", 6},
        {"碎石", 2},
    },
    time = "12s",
    description = "使用碾碎铁矿石和石墨锻造铁板",
}

prototype "碾碎铁矿石" {
    type = { "recipe" },
    recipe_craft_category = "矿石粉碎",
    recipe_category =  "金属",
    recipe_order =  14,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/crush-ore-Fe.texture",
    ingredients = {
        {"铁矿石", 8},
    },
    results = {
        {"碾碎铁矿石", 7},
        {"碎石", 1},
    },
    time = "6s",
    description = "将铁矿石碾碎进行再加工",
}

prototype "碾碎铝矿石" {
    type = { "recipe" },
    recipe_craft_category = "矿石粉碎",
    recipe_category =  "金属",
    recipe_order =  14,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/crush-ore-Al.texture",
    ingredients = {
        {"铝矿石", 7},
    },
    results = {
        {"碾碎铝矿石", 5},
        {"沙子", 1},
        {"碾碎铁矿石", 1},
    },
    time = "5s",
    description = "将铝矿石碾碎进行再加工",
}

prototype "铝矿石浮选" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "金属",
    recipe_order =  14,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/aluminum-floating.texture",
    ingredients = {
        {"碾碎铝矿石", 4},
        {"碱性溶液", 30}
    },
    results = {
        {"氢氧化铝", 3},
        {"废水", 12},
    },
    time = "5s",
    description = "使用浮选工艺将含铝矿物从矿石中分离出来",
}

prototype "四氯化钛" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  11,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/alumina.texture",
    ingredients = {
        {"氯气", 80},
        {"石墨", 7},
        {"金红石", 4},
    },
    results = {
        {"四氯化钛", 15},
        {"废料", 2},
    },
    time = "10s",
    description = "将金红石进行氯化反应产生四氯化钛",
}

prototype "钛板" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "金属",
    recipe_order =  14,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/plate-Si.texture",
    ingredients = {
        {"氦气", 1},
        {"钠", 6},
        {"四氯化钛", 10},
    },
    results = {
        {"钛板", 1},
        {"废水", 4},
    },
    time = "8s",
    description = "将四氯化钛进行纯化获得钛",
}

prototype "氧化铝" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  16,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/alumina.texture",
    ingredients = {
        {"氢氧化铝", 4},
    },
    results = {
        {"氧化铝", 3},
    },
    time = "2s",
    description = "将氢氧化铝煅烧获得氧化铝",
}

prototype "铝板1" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  18,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/plate-Al-1.texture",
    ingredients = {
        {"氧化铝", 9},
        {"石墨", 5}
    },
    results = {
        {"铝板", 3},
        {"碳化铝", 4},
    },
    time = "10s",
    description = "使用氧化铝和石墨烧制铝板",
}

prototype "铝棒1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "金属",
    recipe_order =  20,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/aluminium-rod.texture",
    ingredients = {
        {"铝板", 4},
    },
    results = {
        {"铝棒", 5}
    },
    time = "8s",
    description = "使用铝板锻造铝棒",
}

prototype "铝丝1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "金属",
    recipe_order =  22,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/aluminium-rod.texture",
    ingredients = {
        {"铝棒", 5},
    },
    results = {
        {"铝丝", 7}
    },
    time = "10s",
    description = "使用铝棒锻造铝丝",
}

prototype "铁棒1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "金属",
    recipe_order =  13,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-rod.texture",
    ingredients = {
        {"铁板", 4},
    },
    results = {
        {"铁棒", 5}
    },
    time = "4s",
    description = "使用铁锭锻造铁棒",
}

prototype "铁丝1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    --recipe_category =  "金属",
    recipe_order =  14,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-wire.texture",
    ingredients = {
        {"铁棒", 3},
    },
    results = {
        {"铁丝", 4}
    },
    time = "6s",
    description = "使用铁棒锻造铁丝",
}

prototype "沙子1" {
    type = { "recipe" },
    recipe_craft_category = "矿石粉碎",
    recipe_category =  "金属",
    recipe_order =  40,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/sand.texture",
    ingredients = {
        {"碎石", 5},
    },
    results = {
        {"沙子", 3},
    },
    time = "5s",
    description = "粉碎沙石矿获得更微小的原材料",
}

prototype "石砖" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    recipe_category =  "物流",
    recipe_order =  100,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/stone-brick.texture",
    ingredients = {
        {"碎石", 2},
    },
    results = {
        {"石砖", 1},
    },
    time = "4s",
    description = "使用碎石炼制石砖",
}

prototype "硅1" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "金属",
    recipe_order =  68,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/ore-Si.texture",
    ingredients = {
        {"地下卤水", 60},
        {"沙子", 8},
    },
    results = {
        {"废水", 50},
        {"硅", 6},
    },
    time = "5s",
    description = "将沙子进行浮选获得硅",
}

prototype "玻璃1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/glass.texture",
    ingredients = {
        {"硅", 3},
    },
    results = {
        {"玻璃", 1},
    },
    time = "16s",
    description = "使用硅炼制玻璃",
}

prototype "玻璃2" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/glass.texture",
    ingredients = {
        {"硅", 5},
        {"氧化铝", 3},
        {"地热气", 400},
    },
    results = {
        {"玻璃", 4},
    },
    time = "40s",
    description = "使用硅和氨气炼制玻璃",
}

prototype "坩埚" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/crucible.texture",
    ingredients = {
        {"硅", 15},
    },
    results = {
        {"坩埚", 1},
    },
    time = "30s",
    description = "使用硅烧制坩埚",
}

prototype "硅板1" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  68,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/plate-Si.texture",
    ingredients = {
        {"硅", 5},
        {"石墨", 2},
    },
    results = {
        {"硅板", 3},
    },
    time = "10s",
    description = "使用硅炼制硅板",
}

prototype "橡胶" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "器件",
    recipe_order =  76,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/rubber.texture",
    ingredients = {
        {"丁二烯", 15},
    },
    results = {
        {"橡胶", 1},
    },
    time = "3s",
    description = "使用丁二烯合成橡胶",
}

prototype "电动机1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  52,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        -- {"铁棒", 1},
        -- {"铁丝", 2},
        {"石砖", 2},
        {"铁齿轮", 2},
    },
    results = {
        {"电动机I", 1},
    },
    time = "6s",
    description = "铁制品和塑料打造初级电动机",
}

prototype "电动机T1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  52,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"铁齿轮", 2},
        {"塑料", 1},
    },
    results = {
        {"电动机I", 1},
    },
    time = "8s",
    description = "铁制品和塑料打造初级电动机",
}

prototype "电动机2" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  52,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"钢齿轮", 1},
        {"绝缘线", 3},
        {"润滑油", 6},
        {"电动机I", 1},
    },
    results = {
        {"电动机II", 1},
    },
    time = "12s",
    description = "铁制品和塑料打造初级电动机",
}

prototype "电动机3" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  52,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"钛板", 4},
        {"铝丝", 8},
        {"电动机II", 1},
    },
    results = {
        {"电动机III", 1},
    },
    time = "16s",
    description = "铁制品和塑料打造初级电动机",
}

prototype "铁齿轮T1" {
    type = { "recipe" },
    recipe_craft_category = "金属小型制造",
    recipe_category =  "金属",
    recipe_order =  15,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-gear.texture",
    ingredients = {
        {"铁板", 4},
    },
    results = {
        {"铁齿轮", 2},
    },
    time = "4s",
    description = "使用铁制品加工铁齿轮",
}

prototype "铁齿轮" {
    type = { "recipe" },
    recipe_craft_category = "金属小型制造",
    recipe_category =  "金属",
    recipe_order =  15,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-gear.texture",
    ingredients = {
        {"铁板", 2},
        {"铁棒", 1},
    },
    results = {
        {"铁齿轮", 2},
    },
    time = "4s",
    description = "使用铁制品加工铁齿轮",
}


prototype "玻璃纤维1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "金属",
    recipe_order =  11,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/glass.texture",
    ingredients = {
        {"纯水", 20},
        {"玻璃", 4},
    },
    results = {
        {"玻璃纤维", 3},
        {"蒸汽", 50},
    },
    time = "15s",
    description = "将玻璃进行高温加工获得玻璃纤维",
}

prototype "隔热板1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "金属",
    recipe_order =  11,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/plate-Si.texture",
    ingredients = {
        {"玻璃纤维", 4},
        {"硅板", 5},
    },
    results = {
        {"隔热板", 1},
    },
    time = "15s",
    description = "将玻璃纤维和硅板进行高温加工获得隔热板",
}

prototype "混凝土" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "物流",
    recipe_order =  15,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/stone-brick.texture",
    ingredients = {
        {"纯水", 6},
        {"碎石", 4},
        {"沙子", 2},
        {"钢丝", 5},
    },
    results = {
        {"混凝土", 5},
    },
    time = "3s",
    description = "将水、石头、沙子按照一定比例混合再嵌入钢丝加工成混凝土",
}

prototype "小铁制箱子1" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    --recipe_category =  "物流",
    recipe_order =  10,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/stone-brick.texture",
    ingredients = {
        -- {"铁棒", 1},
        {"铁板", 10},
    },
    results = {
        {"小铁制箱子I", 1},
    },
    time = "2s",
    description = "使用铁制品制造箱子",
}

prototype "小铁制箱子2" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    --recipe_category =  "物流",
    recipe_order =  11,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/stone-brick.texture",
    ingredients = {
        {"橡胶", 1},
        {"钢板", 6},
        {"小铁制箱子I", 1},
    },
    results = {
        {"小铁制箱子II", 1},
    },
    time = "3s",
    description = "使用铁制品制造箱子",
}

prototype "大铁制箱子1" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    --recipe_category =  "物流",
    recipe_order =  13,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/stone-brick.texture",
    ingredients = {
        {"铝板", 4},
        {"小铁制箱子II", 5},
    },
    results = {
        {"大铁制箱子I", 1},
    },
    time = "5s",
    description = "使用铁制品制造箱子",
}

prototype "铁制电线杆" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    recipe_category =  "物流",
    recipe_order =  30,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-wire.texture",
    ingredients = {
        {"铁棒", 4},
        --{"铁丝", 4},
        {"塑料", 1},
    },
    results = {
        {"铁制电线杆", 1},
    },
    time = "6s",
    description = "导电材料制造电线杆",
}

prototype "远程电线杆" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    recipe_category =  "物流",
    recipe_order =  30,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-wire.texture",
    ingredients = {
        {"绝缘线", 4},
        {"铝丝", 3},
        {"铁制电线杆", 1},
    },
    results = {
        {"远程电线杆", 1},
    },
    time = "4s",
    description = "导电材料制造导电距离更远的电线杆",
}

prototype "广域电线杆" {
    type = { "recipe" },
    recipe_craft_category = "物流中型制造",
    recipe_category =  "物流",
    recipe_order =  30,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-wire.texture",
    ingredients = {
        {"混凝土", 8},
        {"远程电线杆", 1},
    },
    results = {
        {"广域电线杆", 1},
    },
    time = "10s",
    description = "导电材料制造导电范围更大的电线杆",
}

prototype "采矿机1" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  40,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/miner-design.texture",
    ingredients = {
        {"铁齿轮", 3},
        {"电动机I", 2},
    },
    results = {
        {"采矿机I", 1},
    },
    time = "6s",
    description = "使用铁制品和电动机制造采矿机",
}

prototype "采矿机2" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  40,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/miner-design.texture",
    ingredients = {
        {"碳化铝", 2},
        {"钢板", 5},
        {"电动机II", 1},
        {"采矿机I", 1},
    },
    results = {
        {"采矿机II", 1},
    },
    time = "10s",
    description = "使用铁制品和电动机制造采矿机",
}

prototype "采矿机3" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  40,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/miner-design.texture",
    ingredients = {
        {"钛板", 4},
        {"电动机III", 1},
        {"采矿机II", 1},
    },
    results = {
        {"采矿机III", 1},
    },
    time = "20s",
    description = "使用铁制品和电动机制造采矿机",
}

prototype "轻型采矿机" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  41,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/miner-design.texture",
    ingredients = {
        {"石砖", 4},
        {"铁板", 4},
    },
    results = {
        {"轻型采矿机", 1},
    },
    time = "10s",
    description = "使用石块和铁板制造采矿机",
}

prototype "熔炼炉1" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  50,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"铁板", 8},
        {"石砖", 12},
    },
    results = {
        {"熔炼炉I", 1},
    },
    time = "8s",
    description = "使用铁制品和石砖制造熔炼炉",
}

prototype "熔炼炉2" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  51,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"钢板", 4},
        {"坩埚", 2},
        {"熔炼炉I", 1},
    },
    results = {
        {"熔炼炉II", 1},
    },
    time = "15s",
    description = "使用铁制品和石砖制造熔炼炉",
}

prototype "熔炼炉3" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  51,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"钛板", 5},
        {"空气过滤器II", 1},
        {"熔炼炉II", 1},
    },
    results = {
        {"熔炼炉III", 1},
    },
    time = "30s",
    description = "使用铁制品和石砖制造熔炼炉",
}

prototype "组装机1" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"电动机I", 2},
        {"铁齿轮", 4},
    },
    results = {
        {"组装机I", 1},
    },
    time = "6s",
    description = "使用机械零件制造组装机",
}

prototype "组装机2" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  71,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"钢板", 4},
        {"铝板", 4},
        {"组装机I", 1},
    },
    results = {
        {"组装机II", 1},
    },
    time = "12s",
    description = "使用机械零件制造组装机",
}

prototype "组装机3" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  71,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"钛板", 6},
        {"无人机平台II", 1},
        {"组装机II", 1},
    },
    results = {
        {"组装机III", 1},
    },
    time = "24s",
    description = "使用机械零件制造组装机",
}

prototype "广播塔1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"电容I", 1},
        {"铁制电线杆", 1},
        {"铝板", 2},
    },
    results = {
        {"广播塔I", 1},
    },
    time = "20s",
    description = "生产可广播性能信号的装置",
}

prototype "广播塔2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"广域电线杆", 1},
        {"玻璃纤维", 4},
        {"广播塔I", 1},
    },
    results = {
        {"广播塔II", 1},
    },
    time = "30s",
    description = "生产可广播性能信号的装置",
}

prototype "广播塔3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"电动机III", 1},
        {"广播塔II", 1},
    },
    results = {
        {"广播塔III", 1},
    },
    time = "40s",
    description = "生产可广播性能信号的装置",
}

prototype "地热井1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"铝板", 20},
        {"铝棒", 10},
        {"管道1-X型", 30},
        {"地下水挖掘机I", 3},
    },
    results = {
        {"地热井I", 1},
    },
    time = "10s",
    description = "生产可挖掘地热资源的装置",
}

prototype "地热井2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"采矿机II", 1},
        {"地热井I", 1},
    },
    results = {
        {"地热井II", 1},
    },
    time = "10s",
    description = "生产可挖掘地热资源的装置",
}

prototype "地热井3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"效能插件I", 2},
        {"采矿机III", 1},
        {"地热井II", 1},
    },
    results = {
        {"地热井III", 1},
    },
    time = "15s",
    description = "生产可挖掘地热资源的装置",
}

prototype "蒸汽发电机1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  120,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"管道1-X型", 4},
        {"钢齿轮", 4},
        {"电动机I", 2},
    },
    results = {
        {"蒸汽发电机I", 1},
    },
    time = "8s",
    description = "管道和机械原料制造蒸汽发电机",
}

prototype "蒸汽发电机2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  120,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"电容I", 2},
        {"铝棒", 4},
        {"电动机II", 2},
        {"蒸汽发电机I", 1},
    },
    results = {
        {"蒸汽发电机II", 1},
    },
    time = "8s",
    description = "管道和机械原料制造蒸汽发电机",
}

prototype "蒸汽发电机3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  120,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"钛板", 12},
        {"电动机III", 1},
        {"蒸汽发电机II", 2},
    },
    results = {
        {"蒸汽发电机I", 1},
    },
    time = "8s",
    description = "管道和机械原料制造蒸汽发电机",
}

prototype "风力发电机1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    --recipe_category =  "加工",
    recipe_order =  10,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"铁制电线杆", 3},
        {"蒸汽发电机I", 2},
    },
    results = {
        {"风力发电机I", 1},
    },
    time = "5s",
    description = "电传输材料和发电设施制造风力发电机",
}

prototype "液罐1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  22,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"管道1-X型", 6},
        {"铁棒", 3},
    },
    results = {
        {"液罐I", 1},
    },
    time = "6s",
    description = "制造可装载流体原料的容器",
}

prototype "液罐2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  22,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"管道1-X型", 6},
        {"钢板", 5},
        {"塑料", 3},
        {"液罐I", 1},
    },
    results = {
        {"液罐II", 1},
    },
    time = "8s",
    description = "制造可装载流体原料的容器",
}

prototype "液罐3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  22,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"管道1-X型", 6},
        {"玻璃纤维", 4},
        {"液罐II", 1},
    },
    results = {
        {"液罐III", 1},
    },
    time = "8s",
    description = "制造可装载流体原料的容器",
}

prototype "化工厂1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"液罐I", 2},
        {"玻璃", 4},
        {"组装机I", 1},
    },
    results = {
        {"化工厂I", 1},
    },
    time = "15s",
    description = "流体容器和加工设备制造化工厂",
}

prototype "化工厂2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"科研中心I", 1},
        {"蒸馏厂II", 1},
        {"化工厂I", 1},
    },
    results = {
        {"化工厂II", 1},
    },
    time = "20s",
    description = "流体容器和加工设备制造化工厂",
}

prototype "化工厂3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"科研中心II", 1},
        {"浮选器II", 1},
        {"化工厂II", 1},
    },
    results = {
        {"化工厂III", 1},
    },
    time = "30s",
    description = "流体容器和加工设备制造化工厂",
}

prototype "铸造厂1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    --recipe_category =  "加工",
    recipe_order =  63,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"铁板", 4},
        {"熔炼炉I", 1},
    },
    results = {
        {"铸造厂I", 1},
    },
    time = "5s",
    description = "熔炼设备和机器爪制造铸造厂",
}

prototype "水电站1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"蒸馏厂I", 1},
        {"地下水挖掘机I", 1},
    },
    results = {
        {"水电站I", 1},
    },
    time = "5s",
    description = "蒸馏设施和地下水挖掘机制造水电站",
}

prototype "水电站2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"液罐II", 1},
        {"化工厂I", 1},
        {"水电站I", 1},
    },
    results = {
        {"水电站II", 1},
    },
    time = "10s",
    description = "蒸馏设施和地下水挖掘机制造水电站",
}

prototype "水电站3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"化工厂II", 1},
        {"浮选器II", 1},
        {"水电站II", 1},
    },
    results = {
        {"水电站III", 1},
    },
    time = "20s",
    description = "蒸馏设施和地下水挖掘机制造水电站",
}

prototype "蒸馏厂1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  62,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"烟囱I", 1},
        {"液罐I", 2},
        {"熔炼炉I", 1}, 
    },
    results = {
        {"蒸馏厂I", 1},
    },
    time = "5s",
    description = "液体容器和熔炼设备制造蒸馏厂",
}

prototype "蒸馏厂2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  62,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"熔炼炉II", 1},
        {"蒸馏厂I", 1},
    },
    results = {
        {"蒸馏厂II", 1},
    },
    time = "8s",
    description = "液体容器和熔炼设备制造蒸馏厂",
}

prototype "蒸馏厂3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  62,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"水电站II", 1},
        {"蒸馏厂II", 1},
    },
    results = {
        {"蒸馏厂III", 1},
    },
    time = "15s",
    description = "液体容器和熔炼设备制造蒸馏厂",
}

prototype "烟囱1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  65,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"铁棒", 2},
        {"管道1-X型", 3},
        {"石砖", 4},
    },
    results = {
        {"烟囱I", 1},
    },
    time = "4s",
    description = "铁制品和管道制造烟囱",
}

prototype "烟囱2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  65,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"混凝土", 10},
        {"钢板", 4},
        {"烟囱I", 2},
    },
    results = {
        {"烟囱II", 1},
    },
    time = "4s",
    description = "铁制品和管道制造烟囱",
}

prototype "压力泵1" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "化工",
    recipe_order =  40,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"电动机I", 1},
        {"管道1-X型", 4},
    },
    results = {
        {"压力泵I", 1},
    },
    time = "2s",
    description = "管道和电机制造压力泵",
}

prototype "地下水挖掘机1" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "化工",
    recipe_order =  50,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-excavator-design.texture",
    ingredients = {
        {"排水口I", 1},
        {"压力泵I", 1},
    },
    results = {
        {"地下水挖掘机I", 1},
    },
    time = "5s",
    description = "使用排水设施和泵制造地下水挖掘机",
}

prototype "地下水挖掘机2" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "化工",
    recipe_order =  50,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-excavator-design.texture",
    ingredients = {
        {"混凝土", 10},
        {"地下水挖掘机I", 1},
    },
    results = {
        {"地下水挖掘机II", 1},
    },
    time = "10s",
    description = "制造性能更好的地下水挖掘机",
}

prototype "空气过滤器1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"塑料", 4},
        {"烟囱I", 1},
    },
    results = {
        {"空气过滤器I", 1},
    },
    time = "8s",
    description = "塑料和排气设施制造空气过滤器",
}

prototype "空气过滤器2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"蒸汽发电机II", 1},
        {"空气过滤器I", 2},
    },
    results = {
        {"空气过滤器II", 1},
    },
    time = "12s",
    description = "制造性能更好的空气过滤器",
}

prototype "空气过滤器3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"烟囱II", 2},
        {"空气过滤器II", 2},
    },
    results = {
        {"空气过滤器III", 1},
    },
    time = "30s",
    description = "制造性能更好的空气过滤器",
}

prototype "排水口1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  56,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-excavator-design.texture",
    ingredients = {
        {"管道1-X型", 5},
        {"地下管1-JI型", 1},
    },
    results = {
        {"排水口I", 1},
    },
    time = "5s",
    description = "管道制造排水口",
}

prototype "排水口2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  56,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-excavator-design.texture",
    ingredients = {
        {"混凝土", 10},
        {"排水口I", 1},
    },
    results = {
        {"排水口II", 1},
    },
    time = "5s",
    description = "制造排水能力更强的排水口",
}


prototype "管道1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "化工",
    recipe_order =  10,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-rod.texture",
    ingredients = {
        {"石砖", 8},
    },
    results = {
        {"管道1-X型", 5},
        {"碎石", 1},
    },
    time = "8s",
    description = "石砖制造管道",
}

prototype "管道2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "化工",
    recipe_order =  11,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-rod.texture",
    ingredients = {
        {"铁棒", 2},
    },
    results = {
        {"管道1-X型", 2},
    },
    time = "4s",
    description = "铁制原料制造管道",
}

prototype "地下管1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "化工",
    recipe_order =  12,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-rod.texture",
    ingredients = {
        {"管道1-X型", 5},
        {"碎石", 2},
    },
    results = {
        {"地下管1-JI型", 2},
    },
    time = "5s",
    description = "管道和碎石制造地下管道",
}

prototype "地下管2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "化工",
    recipe_order =  14,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-rod.texture",
    ingredients = {
        {"地下管1-JI型", 1},
        {"钢板", 3},
        {"碎石", 2},
    },
    results = {
        {"地下管2-JI型", 2},
    },
    time = "5s",
    description = "管道和钢板制造地下管道",
}

prototype "粉碎机1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"铁板", 4},
        {"石砖", 8},
        {"采矿机I", 1},
    },
    results = {
        {"粉碎机I", 1},
    },
    time = "5s",
    description = "石砖和采矿机制造粉碎机",
}

prototype "粉碎机2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"绝缘线", 6},
        {"采矿机I", 1},
        {"粉碎机I", 1},   
    },
    results = {
        {"粉碎机II", 1},
    },
    time = "10s",
    description = "制造性能更好的粉碎机",
}

prototype "粉碎机3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"采矿机III", 1},
        {"粉碎机II", 1},
    },
    results = {
        {"粉碎机III", 1},
    },
    time = "20s",
    description = "制造性能更好的粉碎机",
}

prototype "仓库1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/depot.texture",
    ingredients = {
        {"铁齿轮", 4},
        {"石砖", 4},
    },
    results = {
        {"仓库I", 1},
    },
    time = "12s",
    description = "石砖和铁板制造仓库",
}


prototype "无人机平台1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/drone-depot-design.texture",
    ingredients = {
        {"电动机I", 2},
        {"石砖", 4},
    },
    results = {
        {"无人机平台I", 1},
    },
    time = "8s",
    description = "石砖和电动机制造无人机平台",
}

prototype "无人机平台2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/drone-depot-design.texture",
    ingredients = {
        {"铝棒", 2},
        {"钢齿轮", 4},
        {"无人机平台I", 1},
    },
    results = {
        {"无人机平台II", 1},
    },
    time = "12s",
    description = "制造运载能力更好的无人机平台",
}

prototype "无人机平台3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/drone-depot-design.texture",
    ingredients = {
        {"电动机II", 4},
        {"钛板", 8},
        {"无人机平台II", 1},
    },
    results = {
        {"无人机平台III", 1},
    },
    time = "24s",
    description = "制造运载能力更好的无人机平台",
}

prototype "电解厂1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  90,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"液罐I", 4},
        {"铁制电线杆", 8},
    },
    results = {
        {"电解厂I", 1},
    },
    time = "10s",
    description = "流体容器和电传输设备制造电解厂",
}

prototype "电解厂2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  90,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"远程电线杆", 4},
        {"电解厂I", 1},
    },
    results = {
        {"电解厂II", 1},
    },
    time = "20s",
    description = "建造产能更大的电解厂",
}

prototype "电解厂3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "化工",
    recipe_order =  90,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"广域电线杆", 4},
        {"电解厂II", 1},
    },
    results = {
        {"电解厂III", 1},
    },
    time = "25s",
    description = "建造产能更大的电解厂",
}

prototype "浮选器1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"粉碎机I", 1},
        {"水电站I", 1},
    },
    results = {
        {"浮选器I", 1},
    },
    time = "12s",
    description = "组合粉碎和水处理设施加工成浮选器",
}

prototype "浮选器2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"化工厂I", 1},
        {"浮选器I", 1},
    },
    results = {
        {"浮选器II", 1},
    },
    time = "16s",
    description = "建造性能更好的浮选器",
}

prototype "浮选器3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/furnace-design.texture",
    ingredients = {
        {"粉碎机II", 1},
        {"水电站II", 1},
        {"浮选器II", 1},
    },
    results = {
        {"浮选器III", 1},
    },
    time = "20s",
    description = "建造性能更好的浮选器",
}

prototype "科研中心1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/lab-design.texture",
    ingredients = {
        {"玻璃", 8},
        {"铝棒", 8},
        {"无人机平台II", 4},
    },
    results = {
        {"科研中心I", 1},
    },
    time = "20s",
    description = "基础材料和无人机平台制造科研中心",
}

prototype "科研中心2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/lab-design.texture",
    ingredients = {
        {"化工厂II", 1},
        {"广播塔I", 1},
    },
    results = {
        {"科研中心II", 1},
    },
    time = "30s",
    description = "建造研发效果更好的科研中心",
}

prototype "科研中心3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/lab-design.texture",
    ingredients = {
        {"组装机III", 1},
        {"科研中心II", 2},
    },
    results = {
        {"科研中心III", 1},
    },
    time = "40s",
    description = "建造研发效果更好的科研中心",
}

prototype "太阳能板1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/solar-panel-design.texture",
    ingredients = {
        {"玻璃", 4},
        {"铝棒", 5},
        {"塑料", 2},
        {"硅板", 6},
    },
    results = {
        {"太阳能板I", 1},
    },
    time = "8s",
    description = "制造可以将太阳能转化成电能的硅板",
}

prototype "太阳能板2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/solar-panel-design.texture",
    ingredients = {
        {"钛板", 4},
        {"硅板", 4},
        {"太阳能板I", 1},
    },
    results = {
        {"太阳能板II", 1},
    },
    time = "25s",
    description = "制造可以将太阳能转化成电能的硅板",
}

prototype "太阳能板3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/solar-panel-design.texture",
    ingredients = {
        {"玻璃纤维", 4},
        {"太阳能板II", 2},
    },
    results = {
        {"太阳能板III", 1},
    },
    time = "25s",
    description = "制造可以将太阳能转化成电能的硅板",
}

prototype "蓄电池1" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/grid-battery-design.texture",
    ingredients = {
        {"电容I", 2},
        {"铝板", 2},
        {"橡胶", 1},
    },
    results = {
        {"蓄电池I", 1},
    },
    time = "4s",
    description = "制造可存储电能和输出电能的蓄电池",
}

prototype "蓄电池2" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/grid-battery-design.texture",
    ingredients = {
        {"电容II", 4},
        {"玻璃纤维", 4},
        {"蓄电池I", 3},
    },
    results = {
        {"蓄电池II", 1},
    },
    time = "8s",
    description = "制造可存储电能和输出电能的蓄电池",
}

prototype "蓄电池3" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/grid-battery-design.texture",
    ingredients = {
        {"蓄电池II", 3},
    },
    results = {
        {"蓄电池III", 1},
    },
    time = "20s",
    description = "制造可存储电能和输出电能的蓄电池",
}

prototype "物流站打印" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "物流",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/goodsstation-input-design.texture",
    ingredients = {
        {"电动机I", 1},
        {"石砖", 4},
    },
    results = {
        {"物流站", 1},
    },
    time = "8s",
    description = "向运输车辆装卸货物的车站",
}

prototype "物流中心打印" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "物流",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/goodsstation-out-design.texture",
    ingredients = {
        {"电动机I", 4},
        {"石砖", 20},
    },
    results = {
        {"物流中心", 1},
    },
    time = "15s",
    description = "运输车辆停靠和派发的车站",
}

-- prototype "火箭区段1" {
--     type = { "recipe" },
--     recipe_craft_category = "生产大型制造",
--     recipe_category =  "加工",
--     recipe_order =  64,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
--     ingredients = {
--         {"钢板", 20},
--         {"铝板", 30},
--         {"隔热板", 10},
--     },
--     results = {
--         {"火箭区段", 1},
--     },
--     time = "25s",
--     description = "生产可以拼接成完整火箭的区段",
-- }

-- prototype "火箭整流罩1" {
--     type = { "recipe" },
--     recipe_craft_category = "生产大型制造",
--     recipe_category =  "加工",
--     recipe_order =  64,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
--     ingredients = {
--         {"隔热板", 100},
--         {"钛板", 200},
--     },
--     results = {
--         {"火箭整流罩", 1},
--     },
--     time = "60s",
--     description = "生产保护火箭头部的金属装置",
-- }

prototype "电梯绳缆" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  63,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"碳纳米管", 20},
    },
    results = {
        {"电梯绳缆", 1},
    },
    time = "20s",
    description = "制造太空电梯的绳缆",
}


prototype "电梯配重" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"隔热板", 10},
        {"钛板", 20},
    },
    results = {
        {"电梯配重", 1},
    },
    time = "20s",
    description = "制造电梯的配重",
}

prototype "电梯厢体" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  65,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"钢板", 20},
        {"铝板", 30},
        {"隔热板", 10},
    },
    results = {
        {"电梯厢体", 1},
    },
    time = "25s",
    description = "制造拼接成完整太空电梯的厢体",
}

prototype "电梯空间站" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    recipe_category =  "加工",
    recipe_order =  66,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"电梯绳缆", 100},
        {"太阳能板III", 40},
    },
    results = {
        {"电梯空间站", 1},
    },
    time = "60s",
    description = "制造太空电梯的空间站",
}

prototype "碳纳米管" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "加工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"石墨烯", 2},
        {"氮气", 100},
    },
    results = {
        {"碳纳米管", 1},
    },
    time = "20s",
    description = "制造石墨烯",
}

prototype "太空电梯" {
    type = { "recipe" },
    recipe_craft_category = "生产大型制造",
    --recipe_category =  "加工",
    recipe_order =  66,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electric-motor.texture",
    ingredients = {
        {"电梯绳缆", 500},
        {"电梯配重", 100},
        {"电梯厢体", 50},
        {"电梯空间站", 1},
    },
    results = {
        {"太空电梯", 1},
    },
    time = "120s",
    description = "制造太空电梯的空间站",
}

prototype "车辆装配" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  128,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/construction-design.texture",
    ingredients = {
        {"铁齿轮", 4},
        {"橡胶", 4},
        {"电动机I", 1},
    },
    results = {
        {"运输车辆I", 1},
    },
    time = "8s",
    description = "制造运输汽车",
}

prototype "轻型运输车" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  128,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-gear.texture",
    ingredients = {
        {"铁板", 5},
    },
    results = {
        {"运输车辆I", 1},
    },
    time = "4s",
    description = "制造轻型运输车",
}

------------------打印-------------------
prototype "处理器1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "加工",
    recipe_order =  128,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/logic-circuit-1.texture",
    ingredients = {
        {"盐酸", 5},
        {"数据线", 2},
        {"玻璃纤维", 1},
    },
    results = {
        {"处理器I", 1},
    },
    time = "6s",
    description = "制造作为中央处理单元的电子元件",
}

prototype "处理器2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "加工",
    recipe_order =  128,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/logic-circuit-1.texture",
    ingredients = {
        {"氦气", 8},
        {"石墨烯", 1},
        {"处理器I", 1},
    },
    results = {
        {"处理器II", 1},
    },
    time = "15s",
    description = "制造作为中央处理单元的电子元件",
}


prototype "砖石公路打印" {
    type = { "recipe" },
    recipe_craft_category = "物流小型制造",
    recipe_category =  "物流",
    recipe_order =  104,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/stone-brick.texture",
    ingredients = {
        {"石砖", 5},
    },
    results = {
        {"砖石公路-X型", 15},
    },
    time = "6s",
    description = "使用石砖制造公路",
}

prototype "管道打印" {
    type = { "recipe" },
    recipe_craft_category = "框架打印",
    recipe_category =  "化工",
    recipe_order =  10,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-rod.texture",
    ingredients = {
        {"铁板", 2},
    },
    results = {
        {"管道1-X型", 2},
    },
    time = "5s",
    description = "铁板制造管道",
}

------------------框架-------------------
-- prototype "采矿机打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "物流",
--     recipe_order =  52,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-miner.texture",
--     ingredients = {
--         {"电动机I", 2},
--         {"石砖", 4},
--     },
--     results = {
--         {"采矿机I", 1},
--     },
--     time = "10s",
--     description = "打印采矿机",
-- }

-- prototype "电线杆打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "物流",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-electric-pole1.texture",
--     ingredients = {
--         {"铁板", 3},
--     },
--     results = {
--         {"铁制电线杆", 1},
--     },
--     time = "5s",
--     description = "打印可导电的电线杆",
-- }

-- prototype "无人机平台I打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "物流",
--     recipe_order =  55,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-drone-depot.texture",
--     ingredients = {
--         {"电动机I", 1},
--     },
--     results = {
--         {"无人机平台I", 1},
--     },
--     time = "5s",
--     description = "打印无人机平台I",
-- }

-- prototype "车站打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     --recipe_category =  "物流",
--     recipe_order =  56,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-logisitic.texture",
--     ingredients = {
--         {"电动机I", 1},
--     },
--     results = {
--         {"车站框架", 1},
--     },
--     time = "5s",
--     description = "打印车站",
-- }

-- prototype "科研中心打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "物流",
--     recipe_order =  56,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-lab.texture",
--     ingredients = {
--         {"电动机I", 8},
--         {"坩埚", 3},
--     },
--     results = {
--         {"科研中心I", 1},
--     },
--     time = "5s",
--     description = "打印科研中心",
-- }

-- prototype "蓄电池打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "加工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-grid-battery.texture",
--     ingredients = {
--         {"电动机I", 1},
--         {"硅", 4},
--     },
--     results = {
--         {"蓄电池I", 1},
--     },
--     time = "5s",
--     description = "打印可存储电能的电池",
-- }

-- prototype "水电站打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-hydroplant.texture",
--     ingredients = {
--         {"电动机I", 1},
--         {"坩埚", 2},
--     },
--     results = {
--         {"水电站I", 1},
--     },
--     time = "5s",
--     description = "打印可处理液体的装置",
-- }

-- prototype "粉碎机打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "加工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-hydroplant.texture",
--     ingredients = {
--         {"采矿机I", 1},
--         {"铁齿轮", 4},
--     },
--     results = {
--         {"粉碎机I", 1},
--     },
--     time = "5s",
--     description = "打印可粉碎物品的装置",
-- }

-- prototype "电解厂打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-electrolysis1.texture",
--     ingredients = {
--         {"液罐I", 4},
--         {"铁制电线杆", 8},
--     },
--     results = {
--         {"电解厂I", 1},
--     },
--     time = "5s",
--     description = "打印可电解液体的工厂",
-- }

-- prototype "液罐打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-electrolysis1.texture",
--     ingredients = {
--         {"管道1-X型", 6},
--     },
--     results = {
--         {"液罐I", 1},
--     },
--     time = "5s",
--     description = "打印可电解液体的工厂",
-- }

-- prototype "化工厂打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-chemistry2.texture",
--     ingredients = {
--         {"液罐I", 12},
--         {"组装机I", 1},
--     },
--     results = {
--         {"化工厂I", 1},
--     },
--     time = "5s",
--     description = "打印可处理化工原料的工厂",
-- }

-- prototype "组装机打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "加工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-assembler.texture",
--     ingredients = {
--         {"电动机I", 2},
--         {"铁齿轮", 4},
--     },
--     results = {
--         {"组装机I", 1},
--     },
--     time = "5s",
--     description = "打印可组装元件的工厂",
-- }

-- prototype "空气过滤器打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-air-filter1.texture",
--     ingredients = {
--         {"塑料", 4},
--         {"烟囱I", 1},
--     },
--     results = {
--         {"空气过滤器I", 1},
--     },
--     time = "5s",
--     description = "打印可过滤空气的装置",
-- }

-- prototype "烟囱打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-air-filter1.texture",
--     ingredients = {
--         {"石砖", 4},
--         {"管道1-X型", 3},
--     },
--     results = {
--         {"烟囱I", 1},
--     },
--     time = "5s",
--     description = "打印可过滤空气的装置",
-- }

-- prototype "排水口打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-air-filter1.texture",
--     ingredients = {
--         {"管道1-X型", 5},
--         {"地下管1-JI型", 1},
--     },
--     results = {
--         {"排水口I", 1},
--     },
--     time = "8s",
--     description = "打印可排泄液体的装置",
-- }

-- prototype "压力泵打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  40,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/pump1.texture",
--     ingredients = {
--         {"电动机I", 1},
--         {"管道1-X型", 4},
--     },
--     results = {
--         {"压力泵I", 1},
--     },
--     time = "5s",
--     description = "管道和电机制造压力泵",
-- }

-- prototype "地下水挖掘机打印" {
--     type = { "recipe" },
--     recipe_craft_category = "建筑打印",
--     recipe_category =  "化工",
--     recipe_order =  54,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/broken-pump.texture",
--     ingredients = {
--         {"排水口I", 1},
--         {"压力泵I", 1},
--     },
--     results = {
--         {"地下水挖掘机I", 1},
--     },
--     time = "10s",
--     description = "打印可挖掘地下水的装置",
-- }
---------------------建筑维修----------------------
prototype "维修无人机平台" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  50,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/drone-depot-design.texture",
    ingredients = {
        {"铁棒", 5},
        {"无人机平台框架", 1},
    },
    results = {
        {"无人机平台I", 1},
    },
    time = "4s",
    description = "维修破损的无人机平台",
}

prototype "维修铁制电线杆" {
    type = { "recipe" },
    recipe_craft_category = "生产手工制造",
    recipe_category =  "加工",
    recipe_order =  51,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/iron-wire.texture",
    ingredients = {
        {"铁棒", 2},
        {"电线杆框架", 1},
    },
    results = {
        {"铁制电线杆", 1},
    },
    time = "2s",
    description = "修复破损的铁制电线杆",
}

prototype "维修运输汽车" {
    type = { "recipe" },
    recipe_craft_category = "生产手工制造",
    recipe_category =  "加工",
    recipe_order =  54,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/steel-gear.texture",
    ingredients = {
        {"铁棒", 1},
        {"破损运输车辆", 1},
    },
    results = {
        {"运输车辆I", 1},
    },
    time = "3s",
    description = "修复破损的运输汽车",
}


prototype "维修物流站" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  55,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/goodsstation-input-design.texture",
    ingredients = {
        {"铁齿轮", 2},
        {"物流站框架", 1},
    },
    results = {
        {"物流站", 1},
    },
    time = "5s",
    description = "维修破损的物流站",
}

prototype "维修物流中心" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  55,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/goodsstation-out-design.texture",
    ingredients = {
        {"铁齿轮", 10},
        {"石砖", 10},
        {"物流中心框架", 1},
    },
    results = {
        {"物流中心", 1},
    },
    time = "10s",
    description = "维修破损的物流站",
}

prototype "维修空气过滤器" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  57,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"铁棒", 5},
        {"空气过滤器框架", 1},
    },
    results = {
        {"空气过滤器I", 1},
    },
    time = "4s",
    description = "维修破损的可过滤空气装置",
}

prototype "维修地下水挖掘机" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  58,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-excavator-design.texture",
    ingredients = {
        {"铁齿轮", 5},
        {"地下水挖掘机框架", 1},
    },
    results = {
        {"地下水挖掘机I", 1},
    },
    time = "4s",
    description = "维修破损的地下水挖掘装置",
}

prototype "维修水电站" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydroplant-design.texture",
    ingredients = {
        {"石砖", 16},
        {"水电站框架", 1},
    },
    results = {
        {"水电站I", 1},
    },
    time = "6s",
    description = "维修破损的水电站",
}

prototype "维修组装机" {
    type = { "recipe" },
    recipe_craft_category = "生产手工制造",
    recipe_category =  "加工",
    recipe_order =  62,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/assembler-design.texture",
    ingredients = {
        {"铁齿轮", 8},
        {"组装机框架", 1},
    },
    results = {
        {"组装机I", 1},
    },
    time = "4s",
    description = "修复破损的组装机",
}

prototype "维修太阳能板" {
    type = { "recipe" },
    recipe_craft_category = "生产手工制造",
    recipe_category =  "加工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/solar-panel-design.texture",
    ingredients = {
        {"铁齿轮", 3},
        {"石砖", 10},
        {"太阳能板框架", 1},
    },
    results = {
        {"太阳能板I", 1},
    },
    time = "10s",
    description = "修复破损的太阳能板",
}

prototype "轻型太阳能板" {
    type = { "recipe" },
    recipe_craft_category = "生产手工制造",
    recipe_category =  "加工",
    recipe_order =  65,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/solar-panel-design.texture",
    ingredients = {
        {"铁板", 4},
        {"轻质石砖", 4},
    },
    results = {
        {"轻型太阳能板", 1},
    },
    time = "3s",
    description = "修复破损的太阳能板",
}

prototype "维修蒸馏厂" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  66,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"铁齿轮", 8},
        {"蒸馏厂框架", 1},
    },
    results = {
        {"蒸馏厂I", 1},
    },
    time = "10s",
    description = "破损维修破损的蒸馏厂",
}

prototype "维修电解厂" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  68,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrolysis-design.texture",
    ingredients = {
        {"液罐I", 1},
        {"电解厂框架", 1},
    },
    results = {
        {"电解厂I", 1},
    },
    time = "10s",
    description = "破损维修破损的电解厂",
}

prototype "维修蒸汽发电机" {
    type = { "recipe" },
    recipe_craft_category = "生产手工制造",
    recipe_category =  "加工",
    recipe_order =  629,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"地下管1-JI型", 6},
        {"蒸汽发电机框架", 1},
    },
    results = {
        {"蒸汽发电机I", 1},
    },
    time = "4s",
    description = "修复破损的蒸汽发电机",
}

prototype "维修化工厂" {
    type = { "recipe" },
    recipe_craft_category = "建筑打印",
    recipe_category =  "加工",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemistry-design.texture",
    ingredients = {
        {"液罐I", 5},
        {"化工厂框架", 1},
    },
    results = {
        {"化工厂I", 1},
    },
    time = "10s",
    description = "破损维修破损的化工厂",
}

-------------------------------------------

prototype "地质科技包1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  80,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/geology-pack-1.texture",
    ingredients = {
        {"碎石", 2},
        {"铁矿石", 2},
        {"铝矿石", 2},
    },
    results = {
        {"地质科技包", 1},
    },
    time = "15s",
    description = "地质材料制造地质科技包",
}

prototype "地质科技包2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  81,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/geology-pack-2.texture",
    ingredients = {
        {"碎石", 1},
        {"碾碎铁矿石", 1},
        {"碾碎铝矿石", 1},
        {"沙子", 1},
    },
    results = {
        {"地质科技包", 2},
    },
    time = "8s",
    description = "地质材料制造地质科技包",
}

prototype "气候科技包1" {
    type = { "recipe" },
    recipe_craft_category = "流体液体处理",
    recipe_category =  "器件",
    recipe_order =  82,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/climatology-pack-1.texture",
    ingredients = {
        {"空气", 3000},
        {"地下卤水", 2000},
    },
    results = {
        {"气候科技包", 1},
    },
    time = "25s",
    description = "气候材料制造气候科技包",
}

prototype "气候科技包2" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  82,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/climatology-pack-1.texture",
    ingredients = {
        {"地热气", 2},
        {"废水", 40},
        {"氮气", 80},
    },
    results = {
        {"气候科技包", 1},
    },
    time = "6s",
    description = "气候材料制造气候科技包",
}

prototype "机械科技包1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  84,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/mechanical-pack-1.texture",
    ingredients = {
        {"电动机I", 1},
        {"塑料", 3},
    },
    results = {
        {"机械科技包", 1},
    },
    time = "15s",
    description = "机械原料制造机械科技包",
}

prototype "机械科技包T1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  84,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/mechanical-pack-1.texture",
    ingredients = {
        {"电动机I", 1},
        {"铁齿轮", 3},
    },
    results = {
        {"机械科技包", 1},
    },
    time = "15s",
    description = "机械原料制造机械科技包",
}


prototype "机械科技包2" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  84,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/mechanical-pack-1.texture",
    ingredients = {
        {"电动机III", 2},
        {"钢板", 5},
    },
    results = {
        {"机械科技包", 15},
    },
    time = "80s",
    description = "机械原料制造机械科技包",
}

prototype "电子科技包1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  85,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/electrical-pack-1.texture",
    ingredients = {
        {"电容I", 1},
        {"绝缘线", 2},
        {"润滑油", 5},
    },
    results = {
        {"电子科技包", 1},
    },
    time = "12s",
    description = "电子元件制造电子科技包",
}

prototype "化学科技包1" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  85,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemical-pack-1.texture",
    ingredients = {
        {"橡胶", 5},
        {"硫酸", 18},
        {"混凝土", 6},
        {"氨气", 50},
    },
    results = {
        {"化学科技包", 2},
    },
    time = "25s",
    description = "化工材料制造化学科技包",
}

prototype "物理科技包1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "器件",
    recipe_order =  85,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/chemical-pack-1.texture",
    ingredients = {
        {"科研中心II", 1},
        {"组装机III", 1},
        {"蒸汽发电机II", 1},
    },
    results = {
        {"物理科技包", 10},
    },
    time = "400s",
    description = "物理设备制造物理科技包",
}


prototype "石铁矿挖掘" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    --recipe_category =  "金属",
    recipe_order =  20,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/rubber.texture",
    ingredients = {
    },
    results = {
        {"铁矿石", 1},
        {"碎石", 1},
    },
    time = "3s",
    description = "采集铁矿石",
}

prototype "铁矿石挖掘" {
    type = { "recipe" },
    recipe_craft_category = "矿石开采",
    --recipe_category =  "金属",
    recipe_order =  21,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/rubber.texture",
    ingredients = {
    },
    results = {
        {"铁矿石", 1},
    },
    time = "2s",
    description = "采集铁矿石",
}

prototype "碎石挖掘" {
    type = { "recipe" },
    recipe_craft_category = "矿石开采",
    --recipe_category =  "金属",
    recipe_order =  22,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/rubber.texture",
    ingredients = {
    },
    results = {
        {"碎石", 1},
    },
    time = "2s",
    description = "采集碎石",
}

prototype "砂岩挖掘" {
    type = { "recipe" },
    recipe_craft_category = "矿石开采",
    --recipe_category =  "金属",
    recipe_order =  22,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/rubber.texture",
    ingredients = {
    },
    results = {
        {"砂岩", 1},
    },
    time = "2s",
    description = "采集沙子",
}

prototype "铝矿挖掘" {
    type = { "recipe" },
    recipe_craft_category = "矿石开采",
    --recipe_category =  "金属",
    recipe_order =  23,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/rubber.texture",
    ingredients = {
    },
    results = {
        {"铝矿石", 1},
    },
    time = "3s",
    description = "采集铝矿石",
}

prototype "绝缘线1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"橡胶", 2},
        {"铝丝", 3},
    },
    results = {
        {"绝缘线", 4},
    },
    time = "4s",
    description = "生产外部绝缘的导线",
}

prototype "电容1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/capacitor-1.texture",
    ingredients = {
        {"石墨", 1},
        {"氧化铝", 1},
        {"塑料", 3},
        {"铝板", 2},
    },
    results = {
        {"电容I", 2}
    },
    time = "5s",
    description = "生产电子元器件电容",
}

prototype "电容2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  72,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/capacitor-1.texture",
    ingredients = {
        {"塑料", 15},
        {"氦气", 6},
        {"电容I", 2},
    },
    results = {
        {"电容II", 2}
    },
    time = "20s",
    description = "生产电子元器件电容",
}

prototype "金红石1" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "化工",
    recipe_order =  50,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/capacitor-1.texture",
    ingredients = {
        {"硫酸", 12},
        {"沙子", 5},
    },
    results = {
        {"二氧化碳", 5},
        {"废水", 10},
        {"金红石", 1},
    },
    time = "3s",
    description = "排水设施和压力泵制造抽水泵",
}

prototype "逻辑电路1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  74,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/logic-circuit-1.texture",
    ingredients = {
        {"电容I", 1},
        {"铝丝", 3},
        {"塑料", 3},
        {"硅板", 3},
    },
    results = {
        {"逻辑电路", 2},
    },
    time = "5s",
    description = "生产电子元器件逻辑电路",
}

prototype "运算电路1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  74,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/logic-circuit-1.texture",
    ingredients = {
        {"电容I", 2},
        {"铝丝", 2},
        {"塑料", 2},
        {"硅板", 2},
    },
    results = {
        {"运算电路", 3},
    },
    time = "5s",
    description = "生产电子元器件逻辑电路",
}

prototype "数据线1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"绝缘线", 5},
        {"电容I", 2},
    },
    results = {
        {"数据线", 2},
    },
    time = "4s",
    description = "生产可以传输数据的导线",
}

prototype "速度插件1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"数据线", 3},
        {"运算电路", 1},
    },
    results = {
        {"速度插件I", 1},
    },
    time = "8s",
    description = "加快生产速度的插件",
}

prototype "速度插件2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"处理器I", 1},
        {"速度插件I", 1},
    },
    results = {
        {"速度插件II", 1},
    },
    time = "12s",
    description = "加快生产速度的插件",
}

prototype "速度插件3" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"处理器II", 2},
        {"速度插件II", 2},
    },
    results = {
        {"速度插件III", 1},
    },
    time = "15s",
    description = "加快生产速度的插件",
}

prototype "效能插件1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"数据线", 3},
        {"逻辑电路", 1},
    },
    results = {
        {"效能插件I", 1},
    },
    time = "12s",
    description = "降低建筑电能消耗的插件",
}

prototype "效能插件2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"电池I", 1},
        {"效能插件I", 1},
    },
    results = {
        {"效能插件II", 1},
    },
    time = "20s",
    description = "降低建筑电能消耗的插件",
}

prototype "效能插件3" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"电池II", 2},
        {"效能插件II", 2},
    },
    results = {
        {"效能插件III", 1},
    },
    time = "30s",
    description = "降低建筑电能消耗的插件",
}

prototype "产能插件1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"数据线", 3},
        {"逻辑电路", 1},
        {"运算电路", 1},
    },
    results = {
        {"产能插件I", 1},
    },
    time = "16s",
    description = "生产可以传输数据的导线",
}

prototype "产能插件2" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"效能插件II", 1},
        {"速度插件II", 1},
        {"产能插件I", 1},
    },
    results = {
        {"产能插件II", 1},
    },
    time = "20s",
    description = "生产可以传输数据的导线",
}

prototype "产能插件3" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"效能插件III", 1},
        {"速度插件III", 1},
        {"产能插件II", 1},
    },
    results = {
        {"产能插件III", 1},
    },
    time = "30s",
    description = "生产可以传输数据的导线",
}

prototype "火箭控制器1" {
    type = { "recipe" },
    recipe_craft_category = "器件小型制造",
    recipe_category =  "器件",
    recipe_order =  70,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/insulated-wire-1.texture",
    ingredients = {
        {"速度插件III", 1},
        {"产能插件III", 1},
        {"效能插件III", 1},
    },
    results = {
        {"火箭控制器", 1},
    },
    time = "20s",
    description = "生产可以传输数据的导线",
}

prototype "空气过滤" {
    type = { "recipe" },
    recipe_craft_category = "过滤",
    --recipe_category =  "化工",
    recipe_order =  20,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
    },
    results = {
        {"空气", 100},
    },
    time = "1s",
    description = "采集大气并过滤",
}

prototype "地热采集" {
    type = { "recipe" },
    recipe_craft_category = "地热处理",
    --recipe_category =  "化工",
    recipe_order =  20,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
    },
    results = {
        {"地热气", 120},
    },
    time = "3s",
    description = "采集地热蒸汽",
}

prototype "离岸抽水" {
    type = { "recipe" },
    recipe_craft_category = "水泵",
    --recipe_category =  "化工",
    recipe_order =  10,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
    },
    results = {
        {"地下卤水", 120},
    },
    time = "0.1s",
    description = "抽取地表下的地下卤水",
}


prototype "空气分离1" {
    type = { "recipe" },
    recipe_craft_category = "过滤",
    recipe_category =  "化工",
    recipe_order =  11,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"空气", 150},
    },
    results = {
        {"氮气", 90},
        {"二氧化碳", 40},
    },
    time = "1s",
    description = "空气分离出纯净气体",
}

prototype "空气分离2" {
    type = { "recipe" },
    recipe_craft_category = "过滤",
    recipe_category =  "化工",
    recipe_order =  11,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"空气", 100},
    },
    results = {
        {"氮气", 55},
        {"二氧化碳", 33},
        {"氦气", 2},
    },
    time = "1s",
    description = "空气分离出纯净气体",
}

prototype "二氧化碳转甲烷" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  31,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/co22ch4.texture",
    ingredients = {
        {"二氧化碳", 32},
        {"氢气", 110},
    },
    results = {
        {"甲烷", 24},
        {"纯水", 10},
    },
    time = "1s",
    description = "二氧化碳转甲烷",
}

prototype "二氧化碳转一氧化碳" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  34,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/co22co.texture",
    ingredients = {
        {"二氧化碳", 40},
        {"氢气", 40},
    },
    results = {
        {"一氧化碳", 26},
        {"纯水", 8},
    },
    time = "1s",
    description = "二氧化碳转一氧化碳",
}


prototype "一氧化碳转石墨" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  10,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/co2graphite.texture",
    ingredients = {
        {"一氧化碳", 28},
        {"氢气", 36},
    },
    results = {
        {"石墨", 1},
        {"纯水", 5},
    },
    time = "2s",
    description = "一氧化碳转石墨",
}

prototype "甲烷转石墨" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  10,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/ch42ethene.texture",
    ingredients = {
        {"甲烷", 50},
    },
    results = {
        {"石墨", 2},
        {"氢气", 60},
    },
    time = "2s",
    description = "甲烷转石墨",
}

prototype "盐酸" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydrochloric.texture",
    ingredients = {
        {"氯气", 30},
        {"氢气", 30},
    },
    results = {
        {"盐酸", 60},
    },
    time = "1s",
    description = "氢气和氯气化合成盐酸",
}

prototype "润滑油" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/lubricant.texture",
    ingredients = {
        {"硅板", 1},
        {"盐酸", 38},
        {"甲烷", 12},
    },
    results = {
        {"润滑油", 10},
    },
    time = "4s",
    description = "盐酸和硅板合成润滑油",
}

prototype "氨气" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  60,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydrochloric.texture",
    ingredients = {
        {"氮气", 8},
        {"氢气", 24},
    },
    results = {
        {"氨气", 15},
    },
    time = "1s",
    description = "氮气和氢气合成氨气",
}

-- prototype "火箭燃料1" {
--     type = { "recipe" },
--     recipe_craft_category = "流体基础化工",
--     recipe_category =  "化工",
--     recipe_order =  34,
--     recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/hydrochloric.texture",
--     ingredients = {
--         {"铝丝", 20},
--         {"氧气", 300},
--         {"盐酸", 200},
--         {"氨气", 180},
--     },
--     results = {
--         {"火箭燃料", 3},
--         {"废水", 200},
--     },
--     time = "30s",
--     description = "二氧化碳转甲烷",
-- }

prototype "地下卤水电解1" {
    type = { "recipe" },
    recipe_craft_category = "电解",
    recipe_category =  "化工",
    recipe_order =  15,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/brine-electrolysis-1.texture",
    ingredients = {
        {"地下卤水", 45},
    },
    results = {
        {"氧气", 45},
        {"氢气", 110},
        {"氯气", 14},
        -- {"氢氧化钠", 1},
    },
    time = "1s",
    description = "卤水电解成氧气、氢气和氯气",
}

prototype "地下卤水电解2" {
    type = { "recipe" },
    recipe_craft_category = "电解",
    recipe_category =  "化工",
    recipe_order =  16,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/brine-electrolysis-2.texture",
    ingredients = {
        {"地下卤水", 40},
    },
    results = {
        {"氯气", 20},
        {"氢氧化钠", 1},
    },
    time = "1s",
    description = "卤水电解成氯气和氢氧化钠",
}

prototype "氢氧化钠电解" {
    type = { "recipe" },
    recipe_craft_category = "电解",
    recipe_category =  "化工",
    recipe_order =  16,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/brine-electrolysis-2.texture",
    ingredients = {
        {"氢氧化钠", 4},
    },
    results = {
        {"纯水", 15},
        {"氧气", 30},
        {"钠", 3},   
    },
    time = "1s",
    description = "卤水电解成氯气和氢氧化钠",
}

prototype "地下卤水净化" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  15,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/liquid-purify.texture",
    ingredients = {
        {"地下卤水", 100},
    },
    results = {
        {"纯水", 70},
        {"废水", 30},
    },
    time = "1s",
    description = "卤水净化成纯水",
}

prototype "纯水电解" {
    type = { "recipe" },
    recipe_craft_category = "电解",
    recipe_category =  "化工",
    recipe_order =  15,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-electrolysis.texture",
    ingredients = {
        {"纯水", 45},
    },
    results = {
        {"氧气", 70},
        {"氢气", 140},
    },
    time = "1s",
    description = "纯水电解成氧气和氢气",
}

prototype "甲烷转乙烯" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  36,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/ch42ethene.texture",
    ingredients = {
        {"氧气", 40},
        {"甲烷", 40},
    },
    results = {
        {"乙烯", 16},
        {"纯水", 8},
    },
    time = "1s",
    description = "甲烷转乙烯",
}

prototype "乙烯转丁二烯" {
    type = { "recipe" },
    recipe_craft_category = "过滤",
    recipe_category =  "化工",
    recipe_order =  38,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/ethene2butadiene.texture",
    ingredients = {
        {"乙烯", 50},
        {"蒸汽", 150},
    },
    results = {
        {"丁二烯", 20},
        {"氢气", 30},
    },
    time = "1s",
    description = "乙烯转丁二烯",
}

prototype "纯水转蒸汽" {
    type = { "recipe" },
    recipe_craft_category = "流体换热处理",
    recipe_category =  "化工",
    recipe_order =  112,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water2steam.texture",
    ingredients = {
        {"纯水", 70},
    },
    results = {
        {"蒸汽", 270},
    },
    time = "1s",
    description = "纯水加热成为蒸汽",
}

prototype "塑料1" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  20,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/plastic-1.texture",
    ingredients = {
        {"乙烯", 30},
        {"氯气", 30},
    },
    results = {
        {"塑料", 1},
        {"盐酸", 20},
    },
    time = "3s",
    description = "化工原料合成塑料",
}

prototype "塑料2" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "器件",
    recipe_order =  21,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/plastic-2.texture",
    ingredients = {
        {"乙烯", 20},
        {"丁二烯", 15},
    },
    results = {
        {"塑料", 4},
    },
    time = "8s",
    description = "化工原料合成塑料",
}

prototype "电池1" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  21,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/capacitor-1.texture",
    ingredients = {
        {"硫酸", 16},
        {"铝板", 3},
        {"石墨", 2},
        {"钠", 2},
    },
    results = {
        {"电池I", 1},
    },
    time = "10s",
    description = "化工原料合成电池",
}

prototype "电池2" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  21,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/capacitor-1.texture",
    ingredients = {
        {"电容II", 2},
        {"石墨烯", 2},
        {"电池I", 2},
    },
    results = {
        {"电池II", 1},
    },
    time = "12s",
    description = "化工原料合成电池",
}

prototype "石墨烯" {
    type = { "recipe" },
    recipe_craft_category = "器件基础化工",
    recipe_category =  "器件",
    recipe_order =  21,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/ore-Si.texture",
    ingredients = {
        {"氦气", 15},
        {"盐酸", 10},
        {"石墨", 3},
    },
    results = {
        {"废水", 12},
        {"石墨烯", 1},
    },
    time = "24s",
    description = "用石墨分离出单层结构的新材料",
}

prototype "酸碱中和" {
    type = { "recipe" },
    recipe_craft_category = "流体液体处理",
    recipe_category =  "化工",
    recipe_order =  65,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/neutralization.texture",
    ingredients = {
        {"碱性溶液", 80},
        {"盐酸", 80},
    },
    results = {
        {"废水", 100},
    },
    time = "1s",
    description = "酸碱溶液中和成废水",
}

prototype "碱性溶液" {
    type = { "recipe" },
    recipe_craft_category = "流体液体处理",
    recipe_category =  "化工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/solution.texture",
    ingredients = {
        {"纯水", 80},
        {"氢氧化钠", 3},
    },
    results = {
        {"碱性溶液", 100},
    },
    time = "1s",
    description = "碱性原料融水制造碱性溶液",
}

prototype "硫酸溶液" {
    type = { "recipe" },
    recipe_craft_category = "流体基础化工",
    recipe_category =  "化工",
    recipe_order =  64,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/neutralization.texture",
    ingredients = {
        {"氧气", 4},
        {"纯水", 16},
        {"地热气", 8},
    },
    results = {
        {"硫酸", 20},
    },
    time = "1s",
    description = "提取地热气中的硫化物生产硫酸溶液",
}

prototype "钢板1" {
    type = { "recipe" },
    recipe_craft_category = "金属冶炼",
    recipe_category =  "金属",
    recipe_order =  20,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/steel-beam.texture",
    ingredients = {
        {"铁板", 2},
        {"氧气", 30},
    },
    results = {
        {"钢板", 1},
        {"二氧化碳", 12},
        -- {"碎石", 1},
    },
    time = "6s",
    description = "铁板通过金属冶炼获得钢板",
}

prototype "钢丝1" {
    type = { "recipe" },
    recipe_craft_category = "器件中型制造",
    recipe_category =  "金属",
    recipe_order =  20,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/steel-beam.texture",
    ingredients = {
        {"钢板", 3},
        {"润滑油", 1},
    },
    results = {
        {"钢丝", 3},
    },
    time = "2s",
    description = "铁板通过金属冶炼获得钢板",
}

prototype "钢齿轮" {
    type = { "recipe" },
    recipe_craft_category = "金属小型制造",
    recipe_category =  "金属",
    recipe_order =  22,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/steel-gear.texture",
    ingredients = {
        {"钢板", 3},
    },
    results = {
        {"钢齿轮", 2},
    },
    time = "6s",
    description = "使用钢制品加工钢齿轮",
}

prototype "铁矿石回收" {
    type = { "recipe" },
    recipe_craft_category = "矿石粉碎",
    recipe_category =  "金属",
    recipe_order =  104,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/ore-Fe-recycle.texture",
    ingredients = {
        {"碾碎铁矿石", 4},
    },
    results = {
        {"碎石", 3},
    },
    time = "2s",
    description = "铁矿石回收",
}

prototype "碎石回收" {
    type = { "recipe" },
    recipe_craft_category = "矿石粉碎",
    recipe_category =  "金属",
    recipe_order =  106,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gravel-recycle.texture",
    ingredients = {
        {"碎石", 4},
    },
    results = {
        {"废料", 3},
    },
    time = "2s",
    description = "碎石回收",
}

prototype "铝矿石回收" {
    type = { "recipe" },
    recipe_craft_category = "矿石粉碎",
    recipe_category =  "金属",
    recipe_order =  106,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gravel-recycle.texture",
    ingredients = {
        {"铝矿石", 5},
    },
    results = {
        {"废料", 4},
    },
    time = "2s",
    description = "碎石回收",
}

prototype "沙子回收" {
    type = { "recipe" },
    recipe_craft_category = "流体液体处理",
    recipe_category =  "金属",
    recipe_order =  102,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/sand-recycle.texture",
    ingredients = {
        {"地下卤水", 80},
        {"沙子", 4},
    },
    results = {
        {"废水", 100},
    },
    time = "1s",
    description = "沙子排泄",
}

prototype "废料中和" {
    type = { "recipe" },
    recipe_craft_category = "矿石浮选",
    recipe_category =  "金属",
    recipe_order =  102,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"盐酸", 10},
        {"废料", 1},
    },
    results = {
        {"废水", 6},
        {"二氧化碳", 5},
    },
    time = "1s",
    description = "废料中和",
}

prototype "地下卤水排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体液体排泄",
    --recipe_category =  "化工",
    recipe_order =  101,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"地下卤水", 100},
    },
    results = {
    },
    time = "1s",
    description = "地下卤水排泄",
}

prototype "纯水排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体液体排泄",
    --recipe_category =  "化工",
    recipe_order =  102,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"纯水", 100},
    },
    results = {
    },
    time = "1s",
    description = "纯水排泄",
}

prototype "碱性溶液排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体液体排泄",
    --recipe_category =  "化工",
    recipe_order =  103,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"碱性溶液", 100},
    },
    results = {
    },
    time = "1s",
    description = "碱性溶液排泄",
}

prototype "盐酸排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体液体排泄",
    --recipe_category =  "化工",
    recipe_order =  104,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"盐酸", 100},
    },
    results = {
    },
    time = "1s",
    description = "盐酸排泄",
}

prototype "润滑油排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体液体排泄",
    --recipe_category =  "化工",
    recipe_order =  105,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"润滑油", 100},
    },
    results = {
    },
    time = "1s",
    description = "润滑油排泄",
}

prototype "氮气排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  110,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"氮气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氮气排泄",
}

prototype "氧气排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  111,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"氧气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氧气排泄",
}

prototype "二氧化碳排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  112,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"二氧化碳", 100},
    },
    results = {
    },
    time = "1s",
    description = "二氧化碳排泄",
}

prototype "氢气排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  113,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"氢气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氢气排泄",
}


prototype "蒸汽排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  114,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"蒸汽", 100},
    },
    results = {
    },
    time = "1s",
    description = "蒸汽排泄",
}

prototype "甲烷排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  115,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"甲烷", 100},
    },
    results = {
    },
    time = "1s",
    description = "甲烷排泄",
}

prototype "废水排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体液体排泄",
    --recipe_category =  "化工",
    recipe_order =  116,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"废水", 100},
    },
    results = {
    },
    time = "1s",
    description = "废水排泄",
}

prototype "氯气排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  117,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"氯气", 100},
    },
    results = {
    },
    time = "1s",
    description = "氢气排泄",
}

prototype "空气排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  117,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"空气", 100},
    },
    results = {
    },
    time = "1s",
    description = "空气排泄",
}

prototype "一氧化碳排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  117,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"一氧化碳", 100},
    },
    results = {
    },
    time = "1s",
    description = "一氧化碳排泄",
}

prototype "丁二烯排泄" {
    type = { "recipe" },
    recipe_craft_category = "流体气体排泄",
    --recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"丁二烯", 100},
    },
    results = {
    },
    time = "1s",
    description = "丁二烯排泄",
}

prototype "蒸汽发电" {
    type = { "recipe" },
    recipe_craft_category = "流体发电",
    recipe_category =  "化工",
    recipe_order =  119,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-electrolysis.texture",
    ingredients = {
        {"蒸汽", 30},
    },
    results = {
    },
    time = "1s",
    description = "蒸汽发电",
}

prototype "地热气发电" {
    type = { "recipe" },
    recipe_craft_category = "流体发电",
    recipe_category =  "化工",
    recipe_order =  120,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water-electrolysis.texture",
    ingredients = {
        {"地热气", 30},
    },
    results = {
    },
    time = "1.25s",
    description = "地热气发电",
}

---------地下卤水生成矿物配方----------
prototype "热管1" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  16,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"纯水", 100},
        {"铝板", 4},
        {"管道1-X型", 6},
    },
    results = {
        {"热管1-X型", 1},
    },
    time = "1s",
    description = "制造可以传导热量的管道",
}

prototype "换热器1" {
    type = { "recipe" },
    recipe_craft_category = "生产中型制造",
    recipe_category =  "加工",
    recipe_order =  28,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/gas-separate.texture",
    ingredients = {
        {"热管1-X型", 4},
        {"液罐I", 1},
        {"熔炼炉I", 1},
    },
    results = {
        {"换热器I", 1},
    },
    time = "3s",
    description = "制造可以将水变成蒸汽的换热器",
}

prototype "纯水沸腾" {
    type = { "recipe" },
    recipe_craft_category = "流体换热处理",
    recipe_category =  "化工",
    recipe_order =  108,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/water2steam.texture",
    ingredients = {
        {"纯水", 60},
    },
    results = {
        {"蒸汽", 60},
    },
    time = "1s",
    description = "纯水转蒸汽",
}

prototype "卤水沸腾" {
    type = { "recipe" },
    recipe_craft_category = "流体换热处理",
    recipe_category =  "化工",
    recipe_order =  108,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/brine2steam.texture",
    ingredients = {
        {"地下卤水", 90},
    },
    results = {
        {"蒸汽", 60},
        -- {"废水", 10},
    },
    time = "1.5s",
    description = "卤水转蒸汽",
}

prototype "特殊地质科技包" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    --recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"碎石", 1},
    },
    results = {
        {"地质科技包",3},
    },
    time = "3s",
    description = "丁二烯排泄",
}

prototype "特殊铁矿石" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    --recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"地质科技包", 1},
    },
    results = {
        {"铁矿石",7},
    },
    time = "3s",
    description = "丁二烯排泄",
}

prototype "特殊电解" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    --recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"铁板", 8},
    },
    results = {
    },
    time = "3s",
    description = "丁二烯排泄",
}

prototype "特殊电解2" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"铁板", 1},
    },
    results = {
        {"地下卤水", 100},
    },
    time = "1s",
    description = "丁二烯排泄",
}

prototype "特殊电解3" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"铁板", 1},
    },
    results = {
        {"空气", 100},
    },
    time = "1s",
    description = "丁二烯排泄",
}

prototype "特殊化工" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"空气", 100},
        {"地下卤水", 100},
    },
    results = {
        {"氧气",200},
    },
    time = "1s",
    description = "丁二烯排泄",
}

prototype "特殊水电" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"空气", 100},
        {"地下卤水", 100},
    },
    results = {
        {"气候科技包",10},
    },
    time = "3s",
    description = "丁二烯排泄",
}

prototype "特殊化工2" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"氧气", 100},
    },
    results = {
        {"空气", 100},
        {"地下卤水", 100},
    },
    time = "3s",
    description = "丁二烯排泄",
}

prototype "特殊蒸馏" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    recipe_category =  "化工",
    recipe_order =  118,
    recipe_icon =  "/pkg/vaststars.resources/textures/icons/recipe/waste-recycle.texture",
    ingredients = {
        {"空气", 100},
    },
    results = {
        {"地下卤水", 100},
    },
    time = "3s",
    description = "丁二烯排泄",
}

prototype "特殊铁板" {
    type = { "recipe" },
    recipe_craft_category = "登录配方",
    recipe_category =  "金属",
    recipe_order =  11,
    recipe_icon = "/pkg/vaststars.resources/textures/icons/recipe/plate-Fe-1.texture",
    ingredients = {
        {"铁矿石", 1},
    },
    results = {
        {"铁板", 2},
    },
    time = "1s",
    description = "铁矿石通过金属冶炼获得铁板",
}