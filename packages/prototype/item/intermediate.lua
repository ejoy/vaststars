local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "铁锭" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron-ingot.texture",
    model = "prefabs/rock.prefab",
    des = "铁矿石通过工业熔炼的锭",
    group = "金属",
    order = 10,
}

prototype "铁板" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/plate-Fe.texture",
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
    icon = "textures/construct/iron_stick.texture",
    model = "prefabs/rock.prefab",
    description = "铁制材料锻造加工成的铁棒",
    group = "金属",
    order = 13,
}

prototype "钢板" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron-ingot.texture",
    model = "prefabs/rock.prefab",
    description = "铁板锻造加工成的钢板",
    group = "金属",
    order = 20,
}

prototype "钢齿轮" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/iron-ingot.texture",
    model = "prefabs/rock.prefab",
    description = "一种钢制加工品",
    group = "金属",
    order = 22,
}

prototype "铁矿石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/ore-Fe.texture",
    model = "prefabs/rock.prefab",
    description = "含铁的矿石",
    group = "金属",
    order = 1,
}

prototype "铝矿石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/ore-Al.texture",
    model = "prefabs/rock.prefab",
    description = "含铝的矿石",
    group = "金属",
    order = 30,
}

prototype "碾碎铁矿石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/crush-ore-Fe.texture",
    model = "prefabs/rock.prefab",
    description = "被粉碎的铁矿石",
    group = "金属",
    order = 28,
}

prototype "碾碎铝矿石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/crush-ore-Al.texture",
    model = "prefabs/rock.prefab",
    description = "被粉碎的铝矿石",
    group = "金属",
    order = 32,
}

prototype "氢氧化铝" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron.texture",
    model = "prefabs/rock.prefab",
    description = "含铝的化合物",
    group = "金属",
    order = 32,
}

prototype "氧化铝" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron.texture",
    model = "prefabs/rock.prefab",
    description = "含铝的氧化物",
    group = "金属",
    order = 32,
}

prototype "碳化铝" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron.texture",
    model = "prefabs/rock.prefab",
    description = "氧化铝燃烧后的剩余物",
    group = "金属",
    order = 32,
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
    icon = "textures/construct/ore-Si.texture",
    model = "prefabs/rock.prefab",
    description = "沙子中提炼的原料",
    group = "器件",
    order = 11,
}

prototype "硅锭I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/plate-Si.texture",
    model = "prefabs/rock.prefab",
    description = "硅制成的硅锭",
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
    icon = "textures/construct/sand.texture",
    model = "prefabs/rock.prefab",
    description = "伴生在矿物里的沙子",
    group = "金属",
    order = 40,
}

prototype "塑料" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/plastic.texture",
    model = "prefabs/rock.prefab",
    description = "一种化工成品",
    group = "器件",
    order = 20,
}

prototype "电动机I" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/electric-motor.texture",
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

prototype "坩埚" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/crucible.texture",
    model = "prefabs/rock.prefab",
    description = "一种硅制加工品",
    group = "器件",
    order = 72,
}

prototype "橡胶" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "一种高弹性聚合物材料",
    group = "器件",
    order = 70,
}

prototype "铝板" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/plate-Al.texture",
    model = "prefabs/rock.prefab",
    description = "一种高弹性聚合物材料",
    group = "金属",
    order = 72,
}

prototype "地质科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/recipe/geology-pack.texture",
    tech_icon = "textures/science/graybox.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
    group = "器件",
    order = 80,
}

prototype "气候科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/recipe/climatology-pack.texture",
    tech_icon = "textures/science/bluebox.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
    group = "器件",
    order = 82,
}

prototype "机械科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/recipe/mechanical-pack.texture",
    tech_icon = "textures/science/redbox.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
    group = "器件",
    order = 84,
}

prototype "废气" {
    type = {"item"},
    stack = 100,
    icon = "textures/fluid/gas.texture",
    description = "一种废弃气体",
}

prototype "废液" {
    type = {"item"},
    stack = 100,
    icon = "textures/fluid/liquid.texture",
    description = "一种废弃液体",
}

prototype "废料" {
    type = {"item"},
    stack = 100,
    icon = "textures/fluid/liquid.texture",
    description = "一种废弃固体",
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