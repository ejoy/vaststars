local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁锭" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/steel-beam.texture",
    model = "prefabs/rock.prefab",
    des = "铁矿石通过工业熔炼的锭",
}

prototype "铁板" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/steel-beam.texture",
    model = "prefabs/rock.prefab",
    description = "铁制材料锻造加工成的铁板",
}

prototype "铁丝" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron-wire.texture",
    model = "prefabs/rock.prefab",
    description = "铁制材料锻造加工成的铁丝",
}

prototype "铁棒" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/steel-beam.texture",
    model = "prefabs/rock.prefab",
    description = "铁制材料锻造加工成的铁棒",
}

prototype "铁矿石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/iron.texture",
    model = "prefabs/rock.prefab",
    description = "含铁的矿石",
}

prototype "碎石" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "伴生在矿物里的碎石",
}

prototype "石砖" {
    type = {"item"},
    stack = 200,
    icon = "textures/construct/stone-brick.texture",
    model = "prefabs/rock.prefab",
    description = "石头制成的砖头",
}

prototype "石墨" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "一种化工原料",
}

prototype "硅" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "沙子中提炼的原料",
}

prototype "沙石矿" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "含沙石的矿石",
}

prototype "氢氧化钠" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "一种化工原料",
}

prototype "石头" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "一种矿石",
}

prototype "沙子" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "伴生在矿物里的沙子",
}

prototype "塑料" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/gravel.texture",
    model = "prefabs/rock.prefab",
    description = "一种化工成品",
}

prototype "电动机1" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/turbine1.texture",
    model = "prefabs/rock.prefab",
    description = "一种机械加工品",
}

prototype "铁齿轮" {
    type = {"item"},
    stack = 50,
    icon = "textures/construct/iron-gear.texture",
    model = "prefabs/rock.prefab",
    description = "一种铁制加工品",
}

prototype "玻璃" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/coal.texture",
    model = "prefabs/rock.prefab",
    description = "一种硅制加工品",
}

prototype "地质科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/science-pack.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
}

prototype "气候科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/science-pack.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
}

prototype "机械科技包" {
    type = {"item"},
    stack = 100,
    icon = "textures/construct/science-pack.texture",
    model = "prefabs/rock.prefab",
    description = "一种科技研究包",
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

--------------------------
prototype "海藻" {
	type = { "item" },
	stack = 50,
    icon = "textures/construct/seaweed.texture",
    model = "prefabs/rock.prefab",
    description = "一种植物",
}

prototype "纤维燃料" {
	type = { "item" },
	stack = 50,
    icon = "textures/construct/seaweed.texture",
    model = "prefabs/rock.prefab",
    description = "一种燃料",
}