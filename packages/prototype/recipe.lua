local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "iron ignot" {
    type = { "recipe" },
    ingredients = {
        {"iron ore", 5},
    },
    results = {
        {"iron ignot", 2},
        {"gravel", 1}
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


prototype "electronic circuit" {
    type = { "recipe" },
    ingredients = {
        {"copper cable", 3},
        {"iron plate", 1}
    },
    results = {
        {"electronic circuit", 1}
    },
    time = "0.5s"
}

prototype "uranium combustion" {
    type = { "recipe" },
    ingredients = {
        {"uranium fuel cell", 1},
    },
    results = {
        {"used up uranium fuel cell", 1}
    },
    time = "200s"
}

prototype "copper cable" {
    type = { "recipe" },
    ingredients = {
        {"copper plate", 1}
    },
    results = {
        {"copper cable", 2}
    },
    time = "0.5s"
}