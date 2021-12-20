local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "iron ignot" {
    type = { "recipe" },
    ingredients = {
        {"iron ore", 5},
    },
    results = {
        {"iron ignot", 2},
        --{"gravel", 1}
    },
    time = "8s"
}

prototype "iron plate" {
    type = { "recipe" },
    ingredients = {
        {"iron ignot", 4},
    },
    results = {
        {"iron plate", 3}
    },
    time = "3s"
}
