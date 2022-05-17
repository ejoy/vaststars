local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁锭" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/steel-beam.texture",
    model = "prefabs/rock.prefab",
    des = "铁矿石通过工业熔炼的锭",
    group = "金属",
    order = 10,
}

prototype "铁板" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron-ingot.texture",
    model = "prefabs/rock.prefab",
    description = "铁制材料锻造加工成的铁板",
    group = "金属",
    order = 11,
}

prototype "铁丝" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron-wire.texture",
    model = "prefabs/rock.prefab",
    description = "铁制材料锻造加工成的铁丝",
    group = "金属",
    order = 14,
}

prototype "铁棒" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/steel-beam.texture",
    model = "prefabs/rock.prefab",
    description = "铁制材料锻造加工成的铁棒",
    group = "金属",
    order = 13,
}

prototype "铁矿石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron.texture",
    model = "prefabs/rock.prefab",
    description = "含铁的矿石",
    group = "金属",
    order = 1,
}

prototype "碎石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "伴生在矿物里的碎石",
    group = "金属",
    order = 3,
}

prototype "石砖" {
    type = {"item"},
    stack = 200,
    icon = "textures/construct/stone-brick.texture",
    model = "prefabs/rock.prefab",
    description = "石头制成的砖头",
    group = "物流",
    order = 100,
}

prototype "石墨" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "一种化工原料",
    group = "器件",
    order = 10,
}

prototype "硅" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "沙子中提炼的原料",
    group = "器件",
    order = 11,
}

prototype "沙石矿" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "含沙石的矿石",
    group = "金属",
    order = 4,
}

prototype "氢氧化钠" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "一种化工原料",
    group = "金属",
    order = 20,
}

prototype "石头" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "一种矿石",
    group = "金属",
    order = 5,
}

prototype "沙子" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "伴生在矿物里的沙子",
    group = "金属",
    order = 40,
}

prototype "塑料" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "一种化工成品",
    group = "器件",
    order = 20,
}

prototype "电动机I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/turbine1.texture",
    model = "prefabs/rock.prefab",
    description = "一种机械加工品",
    group = "器件",
    order = 52,
}

prototype "铁齿轮" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/iron-gear.texture",
    model = "prefabs/rock.prefab",
    description = "一种铁制加工品",
    group = "金属",
    order = 15,
}

prototype "玻璃" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "一种硅制加工品",
    group = "金属",
    order = 70,
}

prototype "地质科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/science-pack.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
    group = "器件",
    order = 80,
}

prototype "气候科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/science-pack.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
    group = "器件",
    order = 82,
}

prototype "机械科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/science-pack.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
    group = "器件",
    order = 84,
}

prototype "气体排泄物" {
    type = {"item"},
    stack = 100,
    icon = "textures/fluid/gas.texture",
    description = "一种废弃气体",
}

prototype "液体排泄物" {
    type = {"item"},
    stack = 100,
    icon = "textures/fluid/liquid.texture",
    description = "一种废弃液体",
}

prototype "铜片" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/steel-beam.texture",
    model = "prefabs/rock.prefab",
}
prototype "铜丝" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron-wire.texture",
    model = "prefabs/rock.prefab",
}
prototype "电路板" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/processor.texture",
    model = "prefabs/rock.prefab",
}

prototype "核铀燃料" {
	type = { "item" },
	stack = 50,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
}

prototype "用尽的核铀燃料" {
	type = { "item" },
	stack = 50,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
}

prototype "无人机" {
    type = {"item"},
    stack = 20,
    icon = "textures/construct/drone1.texture",
    model = "prefabs/drone.prefab",
    des = "可飞行的小型空中运输工具",
    group = "器件",
    order = 70,
}
--------------------------
prototype "海藻" {
	type = { "item" },
	stack = 50,
    icon = "textures/construct/seaweed.texture",
    model = "prefabs/rock.prefab",
    description = "一种植物",
    group = "金属",
    order = 2,
}

prototype "纤维燃料" {
	type = { "item" },
	stack = 50,
    icon = "textures/construct/seaweed.texture",
    model = "prefabs/rock.prefab",
    description = "一种燃料",
    group = "器件",
    order = 26,
}