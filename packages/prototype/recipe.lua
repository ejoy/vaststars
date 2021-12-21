local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "铁锭" {
    type = { "recipe" },
    category = "smelting",
    ingredients = {
        {"iron ore", 5},
    },
    results = {
        {"iron ignot", 2},
        {"gravel", 1}
    },
    time = "8s",
    description = "铁矿石通过金属冶炼获得铁锭",
}

prototype "铁板1" {
    type = { "recipe" },
    category = "machine-casting",
    ingredients = {
        {"iron ignot", 4},
    },
    results = {
        {"iron plate", 3}
    },
    time = "3s",
    description = "使用铁锭锻造铁板",

}

prototype "铁板2" {
    type = { "recipe" },
    category = "machine-casting",
    ingredients = {
        {"iron ignot", 4},
        {"gravel", 2}
    },
    results = {
        {"iron plate", 5}
    },
    time = "5s",
    description = "使用铁锭和碎石锻造铁板",

}