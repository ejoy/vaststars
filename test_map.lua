local game = ...

game.create_entity "小型铁制箱子" {
    x = 1,
    y = 1,
    items = {
        {"铁矿石", 100},
    },
    description = "铁矿石",
}
game.create_entity "inserter" {
    x = 2,
    y = 1,
    dir = "W"
}
game.create_entity "组装机1" {
    x = 3,
    y = 1,
    recipe = "铁锭"
}
game.create_entity "inserter" {
    x = 6,
    y = 1,
    dir = "W"
}
game.create_entity "小型铁制箱子" {
    x = 7,
    y = 1,
    items = {
    },
    description = "碎石",
}
game.create_entity "机器爪1" {
    x = 8,
    y = 1,
    dir = "W"
}
game.create_entity "组装机1" {
    x = 9,
    y = 1,
    recipe = "铁板1"
}
game.create_entity "机器爪1" {
    x = 12,
    y = 1,
    dir = "W"
}
game.create_entity "小型铁制箱子" {
    x = 13,
    y = 1,
    items = {
    },
    description = "铁板",
}

game.create_entity "指挥中心" {
    x = 1,
    y = 10
}
