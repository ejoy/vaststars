local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "iron ignot" {
    type = {"item"},
    stack = 100,
    des = "铁矿石通过工业熔炼的锭",
}

prototype "iron plate" {
    type = {"item"},
    stack = 100,
    description = "锻造加工成的铁板",
}

prototype "iron ore" {
    type = {"item"},
    stack = 100,
    description = "一种导电导热的金属矿石",
}

prototype "gravel" {
    type = {"item"},
    stack = 100,
    description = "一种导电导热的金属矿石",
}

prototype "copper plate" {
    type = {"item"},
    stack = 100,
}
prototype "copper cable" {
    type = {"item"},
    stack = 100,
}
prototype "electronic circuit" {
    type = {"item"},
    stack = 100,
}

prototype "uranium fuel cell" {
	type = { "item" },
	stack = 50,
}

prototype "used up uranium fuel cell" {
	type = { "item" },
	stack = 50,
}