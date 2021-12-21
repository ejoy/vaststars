local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁锭" {
    type = { "recipe" },
    category = "金属冶炼",
    ingredients = {
        {"铁矿石", 5},
    },
    results = {
        {"铁锭", 2},
        {"碎石", 1}
    },
    time = "8s",
    description = "铁矿石通过金属冶炼获得铁锭",
}

prototype "铁板1" {
    type = { "recipe" },
    category = "金属锻造",
    ingredients = {
        {"铁锭", 4},
    },
    results = {
        {"铁板", 3}
    },
    time = "3s",
    description = "使用铁锭锻造铁板",

}

prototype "铁板2" {
    type = { "recipe" },
    category = "金属锻造",
    ingredients = {
        {"铁锭", 4},
        {"碎石", 2}
    },
    results = {
        {"铁板", 5}
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",

}