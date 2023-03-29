local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

-- prototype "破损水电站" {
--     type = {"item"},
--     stack = 10,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-hydroplant.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损空气过滤器" {
--     type = {"item"},
--     stack = 10,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-air-filter1.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损地下水挖掘机" {
--     type = {"item"},
--     stack = 50,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-pump.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损电解厂" {
--     type = {"item"},
--     stack = 10,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-electrolysis1.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损化工厂" {
--     type = {"item"},
--     stack = 10,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-chemistry2.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损组装机" {
--     type = {"item"},
--     stack = 10,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-assembler.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损铁制电线杆" {
--     type = {"item"},
--     stack = 50,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-electric-pole1.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损太阳能板" {
--     type = {"item"},
--     stack = 50,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-solar-panel.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损蓄电池" {
--     type = {"item"},
--     stack = 50,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-grid-battery.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

-- prototype "破损物流中心" {
--     type = {"item"},
--     stack = 50,
--     pile = "2x2x4",
--     pile_model = "prefabs/stackeditems/iron-ore.prefab",
--     icon = "textures/construct/broken-logisitic.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

prototype "破损运输车辆" {
    type = {"item"},
    stack = 50,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-truck.texture",
    group = {"加工"},
    item_description = "需要维修的运输车辆",
}

-- prototype "破损物流需求站" {
--     type = {"item"},
--     stack = 50,
--     icon = "textures/construct/broken-goodsstation-input.texture",
--     group = {"加工"},
--     item_description = "用来抓取货物的机械装置",
-- }

----

prototype "水电站设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-hydroplant.texture",
    group = {"加工"},
    item_description = "用于建造水电站的设计图",
}

prototype "空气过滤器设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-air-filter1.texture",
    group = {"加工"},
    item_description = "用于建造空气过滤器的设计图",
}

prototype "地下水挖掘机设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-pump.texture",
    group = {"加工"},
    item_description = "用于建造地下水挖掘机的设计图",
}

prototype "电解厂设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-electrolysis1.texture",
    group = {"加工"},
    item_description = "用于建造电解厂的设计图",
}

prototype "化工厂设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-chemistry2.texture",
    group = {"加工"},
    item_description = "用于建造化工厂的设计图",
}

prototype "采矿机设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-miner.texture",
    group = {"加工"},
    item_description = "用于建造采矿机的设计图",
}

prototype "组装机设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-assembler.texture",
    group = {"加工"},
    item_description = "用于建造组装机的设计图",
}

prototype "电线杆设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-electric-pole1.texture",
    group = {"加工"},
    item_description = "用于建造铁制电线杆的设计图",
}

prototype "无人机仓库设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-drone-depot.texture",
    group = {"加工"},
    item_description = "用于建造无人机仓库的设计图",
}

prototype "车站设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-logisitic.texture",
    group = {"加工"},
    item_description = "用于建造车站的设计图",
}

prototype "送货车站设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-logisitic.texture",
    group = {"加工"},
    item_description = "用于建造送货车站的设计图",
}

prototype "收货车站设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-logisitic.texture",
    group = {"加工"},
    item_description = "用于建造收货车站的设计图",
}

prototype "熔炼炉设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-furnace.texture",
    group = {"加工"},
    item_description = "用于建造熔炼炉的设计图",
}

prototype "太阳能板设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-solar-panel.texture",
    group = {"加工"},
    item_description = "用于建造太阳能板的设计图",
}

prototype "蓄电池设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-grid-battery.texture",
    group = {"加工"},
    item_description = "用于建造蓄电池的设计图",
}

prototype "物流中心设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-logisitic.texture",
    group = {"加工"},
    item_description = "用于建造物流中心的设计图",
}

prototype "车辆厂设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-goodsstation-output.texture",
    group = {"加工"},
    item_description = "用于建造车辆厂的设计图",
}

prototype "道路建造站设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/road-builder.texture",
    group = {"加工"},
    item_description = "用于建造道路建造站的设计图",
}

prototype "管道建造站设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/pipe-builder.texture",
    group = {"加工"},
    item_description = "用于建造管道建造站的设计图",
}

prototype "科研中心设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-lab.texture",
    group = {"加工"},
    item_description = "用于建造科研中心的设计图",
}

prototype "运输车辆设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-truck.texture",
    group = {"加工"},
    item_description = "用于建造运输车辆的设计图",
}

prototype "建造中心设计图" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/broken-truck.texture",
    group = {"加工"},
    item_description = "用于建造建造中心的设计图",
}