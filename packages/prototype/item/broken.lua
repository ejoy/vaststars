local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "破损水电站" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-hydroplant.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的水电站",
    group = "加工",
    order = 110,
}

prototype "破损空气过滤器" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-air-filter1.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的空气过滤器",
    group = "加工",
    order = 111,
}

prototype "破损地下水挖掘机" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-pump.texture",
    model = "prefabs/rock.prefab",
    description = "破损地下水挖掘机",
    group = "加工",
    order = 112,
}

prototype "破损电解厂" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-electrolysis1.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的电解厂",
    group = "加工",
    order = 114,
}

prototype "破损化工厂" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-chemistry2.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的化工厂",
    group = "加工",
    order = 116,
}

prototype "破损组装机" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-assembler.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的组装机",
    group = "加工",
    order = 118,
}

prototype "破损铁制电线杆" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-electric-pole1.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的铁制电线杆",
    group = "加工",
    order = 120,
}

prototype "破损太阳能板" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-solar-panel.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的太阳能板",
    group = "加工",
    order = 122,
}

prototype "破损蓄电池" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/grid-battery.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的蓄电池",
    group = "加工",
    order = 124,
}

prototype "破损物流中心" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/logisitic1.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的物流中心",
    group = "加工",
    order = 126,
}

prototype "破损运输车辆" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/truck.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的运输车辆",
    group = "加工",
    order = 128,
}

prototype "破损车站" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/manufacture.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的车站",
    group = "加工",
    order = 130,
}