local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "制造组装机" {
    group = "建造",
    result = {"组装机I" , 1},
    images = {
        {"textures/construct/steel-beam.texture"},
        {"textures/construct/steel-beam.texture"},
    },
    description = "在平地上制造一台组装机",
}

prototype "生产铁片" {
    group = "生产",
    result = {"铁片" , 100},
    images = {
        {"textures/construct/steel-beam.texture"},
        {"textures/construct/steel-beam.texture"},
    },
    description = "使用熔炼炉生产100个铁片",
}