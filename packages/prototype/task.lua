local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.register.prototype


prototype "任务名称" {
    type = "生产",
    images = {
        {"textures/construct/steel-beam.texture"},
        {"textures/construct/steel-beam.texture"},
    },
    condition = {
        item = {
            {"铁片",10},
            {"铁丝",40},
        },

        tech = {
            {"铁熔炼","化工"},
        },

        build = {
            {"组装机I",2},
            {"机器爪I",2},
        },
    },
    requirement = {
        --生产指定数量道具
        item = {
            {"铁片",10},
            {"铁丝",40},
        },

        --研究指定科技
        tech = {
            {"铁熔炼","化工"},
        },

        --建造指定数量建筑
        build = {
            {"组装机I",2},
            {"机器爪I",2},
        },

        --迁移指定物品(迁入/迁出指挥中心)
        movetoheadquarter = {
            {"组装机I",2},
            {"机器爪I",2},
        },

        movefromheadquarter = {
            {"组装机I",2},
            {"机器爪I",2},
        },
    },
    result = {
        nexttask ={"制造组装机","制造化工厂"},
    },
    description = "使用熔炼炉生产100个铁片",
}

prototype "制造组装机" {
    type = "建造",
    result = {"组装机I" , 1},
    images = {
        {"textures/construct/steel-beam.texture"},
        {"textures/construct/steel-beam.texture"},
    },
    description = "在平地上制造一台组装机",
}


prototype "制造组装机" {
    type = "建造",
    result = {"组装机I" , 1},
    images = {
        {"textures/construct/steel-beam.texture"},
        {"textures/construct/steel-beam.texture"},
    },
    description = "在平地上制造一台组装机",
}