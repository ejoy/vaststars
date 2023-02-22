local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

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
    icon = "textures/construct/broken-grid-battery.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的蓄电池",
    group = "加工",
    order = 124,
}

prototype "破损物流中心" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-logisitic.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的物流中心",
    group = "加工",
    order = 126,
}

prototype "破损运输车辆" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-truck.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的运输车辆",
    group = "加工",
    order = 128,
}

prototype "破损基建站" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-goodsstation-output.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的基建站",
    group = "加工",
    order = 132,
}

prototype "破损物流需求站" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-goodsstation-input.texture",
    model = "prefabs/rock.prefab",
    description = "损坏的物流需求站",
    group = "加工",
    order = 134,
}

----

prototype "水电站设计图" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-hydroplant.texture",
    model = "prefabs/rock.prefab",
    description = "水电站的设计图",
    group = "加工",
    order = 110,
}

prototype "空气过滤器设计图" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-air-filter1.texture",
    model = "prefabs/rock.prefab",
    description = "空气过滤器的设计图",
    group = "加工",
    order = 111,
}

prototype "地下水挖掘机设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-pump.texture",
    model = "prefabs/rock.prefab",
    description = "地下水挖掘机的设计图",
    group = "加工",
    order = 112,
}

prototype "电解厂设计图" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-electrolysis1.texture",
    model = "prefabs/rock.prefab",
    description = "电解厂的设计图",
    group = "加工",
    order = 114,
}

prototype "化工厂设计图" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-chemistry2.texture",
    model = "prefabs/rock.prefab",
    description = "化工厂的设计图",
    group = "加工",
    order = 116,
}

prototype "采矿机设计图" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-assembler.texture",
    model = "prefabs/rock.prefab",
    description = "采矿机的设计图",
    group = "加工",
    order = 117,
}

prototype "组装机设计图" {
    type = {"item"},
    stack = 10,
    icon = "textures/construct/broken-assembler.texture",
    model = "prefabs/rock.prefab",
    description = "组装机的设计图",
    group = "加工",
    order = 118,
}

prototype "电线杆设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-electric-pole1.texture",
    model = "prefabs/rock.prefab",
    description = "铁制电线杆的设计图",
    group = "加工",
    order = 120,
}

prototype "仓库网格设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-electric-pole1.texture",
    model = "prefabs/rock.prefab",
    description = "仓库网格的设计图",
    group = "加工",
    order = 121,
}

prototype "装卸站设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-electric-pole1.texture",
    model = "prefabs/rock.prefab",
    description = "装卸站的设计图",
    group = "加工",
    order = 122,
}

prototype "太阳能板设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-solar-panel.texture",
    model = "prefabs/rock.prefab",
    description = "太阳能板的设计图",
    group = "加工",
    order = 122,
}

prototype "蓄电池设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-grid-battery.texture",
    model = "prefabs/rock.prefab",
    description = "蓄电池的设计图",
    group = "加工",
    order = 124,
}

prototype "物流中心设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-logisitic.texture",
    model = "prefabs/rock.prefab",
    description = "物流中心的设计图",
    group = "加工",
    order = 126,
}

prototype "车辆厂设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-goodsstation-output.texture",
    model = "prefabs/rock.prefab",
    description = "车辆厂的设计图",
    group = "加工",
    order = 128,
}

prototype "道路建造站设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-goodsstation-output.texture",
    model = "prefabs/rock.prefab",
    description = "道路建造站的设计图",
    group = "加工",
    order = 130,
}

prototype "管道建造站设计图" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/broken-goodsstation-output.texture",
    model = "prefabs/rock.prefab",
    description = "管道建造站的设计图",
    group = "加工",
    order = 132,
}