local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype

prototype "铁板" {
    type = {"item"},
    stack = 8,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/plate-Fe.texture",
    item_description = "铁制材料锻造加工成的铁板",
    group = {"金属"},
}

prototype "铁丝" {
    type = {"item"},
    stack = 4,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/iron-wire.texture",
    item_description = "铁制材料锻造加工成的铁丝",
    group = {"金属"},
}

prototype "铁棒" {
    type = {"item"},
    stack = 4,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/iron_stick.texture",
    item_description = "铁制材料锻造加工成的铁棒",
    group = {"金属"},
}

prototype "钢板" {
    type = {"item"},
    stack = 4,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/steel-beam.texture",
    item_description = "铁板锻造加工成的钢板",
    group = {"金属"},
}

prototype "钢齿轮" {
    type = {"item"},
    stack = 4,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/steel-gear.texture",
    item_description = "一种钢制加工品",
    group = {"金属"},
}

prototype "铁矿石" {
    type = {"item"},
    stack = 12,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/ore-Fe.texture",
    item_description = "含铁的矿石",
    group = {"金属"},
}

prototype "铝矿石" {
    type = {"item"},
    stack = 12,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/ore-Al.texture",
    item_description = "含铝的矿石",
    group = {"金属"},
}

prototype "碾碎铁矿石" {
    type = {"item"},
    stack = 16,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/crush-ore-Fe.texture",
    item_description = "被粉碎的铁矿石",
    group = {"金属"},
}

prototype "碾碎铝矿石" {
    type = {"item"},
    stack = 16,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/crush-ore-Al.texture",
    item_description = "被粉碎的铝矿石",
    group = {"金属"},
}

prototype "氢氧化铝" {
    type = {"item"},
    stack = 8,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/aluminum-hydroxide.texture",
    item_description = "含铝的化合物",
    group = {"化工"},
}

prototype "氧化铝" {
    type = {"item"},
    stack = 8,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/alumina.texture",
    item_description = "含铝的氧化物",
    group = {"金属"},
}

prototype "碳化铝" {
    type = {"item"},
    stack = 8,
    pile = "4x2x4",
    icon = "textures/construct/aluminium-carbide.texture",
    item_description = "氧化铝燃烧后的剩余物",
    group = {"金属"},
}

prototype "铝板" {
    type = {"item"},
    stack = 8,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/plate-Al.texture",
    item_description = "一种高弹性聚合物材料",
    group = {"金属"},
}

prototype "铝棒" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/iron_stick.texture",
    item_description = "铝制材料锻造加工成的铝棒",
    group = {"金属"},
}

prototype "铝丝" {
    type = {"item"},
    stack = 8,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/construct/iron-wire.texture",
    item_description = "铝制材料锻造加工成的铝丝",
    group = {"金属"},
}

prototype "碎石" {
    type = {"item"},
    stack = 12,
    pile = "2x2x3",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/gravel.texture",
    item_description = "伴生在矿物里的碎石",
    group = {"金属"},
}

prototype "石砖" {
    type = {"item"},
    stack = 12,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/stone-brick.texture",
    item_description = "石头制成的砖头",
    group = {"物流"},
}

prototype "石墨" {
    type = {"item"},
    stack = 12,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/coal.texture",
    item_description = "一种化工原料",
    group = {"化工"},
}

prototype "硅" {
    type = {"item"},
    stack = 20,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/ore-Si.texture",
    item_description = "沙子中提炼的原料",
    group = {"化工"},
}

prototype "硅板" {
    type = {"item"},
    stack = 12,
    pile = "4x2x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/plate-Si.texture",
    item_description = "硅制成的硅板",
    group = {"器件"},
}

prototype "沙石矿" {
    type = {"item"},
    stack = 12,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/gravel.texture",
    item_description = "含沙石的矿石",
    group = {"金属"},
}

prototype "氢氧化钠" {
    type = {"item"},
    stack = 12,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/coal.texture",
    item_description = "一种化工原料",
    group = {"化工"},
}

-- prototype "石头" {
--     type = {"item"},
--     stack = 10,
--     pile = "4x4x4",
--     pile_model = "prefabs/stackeditems/gravel.prefab",
--     icon = "textures/construct/gravel.texture",
--     item_description = "一种矿石",
--     group = {"金属"},
-- }

prototype "沙子" {
    type = {"item"},
    stack = 12,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/sand.texture",
    item_description = "伴生在矿物里的沙子",
    group = {"金属"},
}

prototype "塑料" {
    type = {"item"},
    stack = 8,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/construct/plastic.texture",
    item_description = "一种化工成品",
    group = {"器件"},
}

prototype "电动机I" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/electric-motor.texture",
    item_description = "一种机械加工品",
    group = {"器件"},
}

prototype "铁齿轮" {
    type = {"item"},
    stack = 8,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/iron-gear.texture",
    item_description = "一种铁制加工品",
    group = {"金属"},
}

prototype "玻璃" {
    type = {"item"},
    stack = 8,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/glass.texture",
    item_description = "一种硅制加工品",
    group = {"金属"},
}

prototype "坩埚" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/crucible.texture",
    item_description = "一种硅制加工品",
    group = {"器件"},
}

prototype "橡胶" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/rubber.texture",
    item_description = "一种高弹性聚合物材料",
    group = {"器件"},
}

prototype "电容" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/capacitor.texture",
    item_description = "一种高弹性聚合物材料",
    group = {"器件"},
}

prototype "绝缘线" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/insulated-wire.texture",
    item_description = "一种高弹性聚合物材料",
    group = {"器件"},
}

prototype "逻辑电路" {
    type = {"item"},
    stack = 4,
    pile = "2x2x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/logic-circuit.texture",
    item_description = "一种高弹性聚合物材料",
    group = {"器件"},
}

prototype "地质科技包" {
    type = {"item"},
    stack = 2,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/gravel.prefab",
    icon = "textures/recipe/geology-pack.texture",
    tech_icon = "textures/science/graybox.texture",
    item_description = "一种科技研究包",
    group = {"器件"},
}

prototype "气候科技包" {
    type = {"item"},
    stack = 2,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ore.prefab",
    icon = "textures/recipe/climatology-pack.texture",
    tech_icon = "textures/science/bluebox.texture",
    item_description = "一种科技研究包",
    group = {"器件"},
}

prototype "机械科技包" {
    type = {"item"},
    stack = 2,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/recipe/mechanical-pack.texture",
    tech_icon = "textures/science/redbox.texture",
    item_description = "一种科技研究包",
    group = {"器件"},
}

prototype "电子科技包" {
    type = {"item"},
    stack = 2,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/recipe/electrical-pack.texture",
    tech_icon = "textures/science/pinkbox.texture",
    item_description = "一种科技研究包",
    group = {"器件"},
}

prototype "废料" {
    type = {"item"},
    stack = 16,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/fluid/liquid.texture",
    item_description = "一种废弃固体",
    group = {"器件"},
}

prototype "铜片" {
    type = {"item"},
    stack = 8,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/steel-beam.texture",
    group = {"金属"},
    item_description = "用来抓取货物的机械装置",
}
prototype "铜丝" {
    type = {"item"},
    stack = 8,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/iron-wire.texture",
    group = {"金属"},
    item_description = "用来抓取货物的机械装置",
}

prototype "电路板" {
    type = {"item"},
    stack = 8,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/processor.texture",
    group = {"器件"},
    item_description = "用来抓取货物的机械装置",
}

prototype "核铀燃料" {
	type = { "item" },
	stack = 50,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/coal.texture",
    group = {"器件"},
    item_description = "用来抓取货物的机械装置",
}

prototype "用尽的核铀燃料" {
	type = { "item" },
	stack = 50,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/coal.texture",
    group = {"器件"},
    item_description = "用来抓取货物的机械装置",
}

prototype "无人机" {
    type = {"item"},
    stack = 4,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/drone1.texture",
    item_description = "用来抓取货物的机械装置",
    group = {"器件"},
}

prototype "运输车框架" {
    type = {"item"},
    stack = 4,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/broken-truck.texture",
    item_description = "用来装配运输车的框架",
    group = {"加工"},
}
--------------------------
prototype "海藻" {
	type = { "item" },
	stack = 50,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/seaweed.texture",
    item_description = "一种植物",
    group = {"器件"},
}

prototype "纤维燃料" {
	type = { "item" },
	stack = 50,
    pile = "4x4x4",
    pile_model = "prefabs/stackeditems/iron-ingot.prefab",
    icon = "textures/construct/seaweed.texture",
    item_description = "一种燃料",
    group = {"器件"},
}