local game = ...

game.create_entity "small chest" {
    x = 1,
    y = 1,
    items = {
        {"iron ore", 100},
    },
    description = "铁矿石",
}
game.create_entity "inserter" {
    x = 2,
    y = 1,
    dir = "W"
}
game.create_entity "chemical plant 1" {
    x = 3,
    y = 1,
    recipe = "iron ignot"
}
game.create_entity "inserter" {
    x = 6,
    y = 1,
    dir = "W"
}
game.create_entity "small chest" {
    x = 7,
    y = 1,
    items = {
    },
    description = "碎石",
}
game.create_entity "inserter" {
    x = 8,
    y = 1,
    dir = "W"
}
game.create_entity "chemical plant 1" {
    x = 9,
    y = 1,
    recipe = "iron plate 2"
}
game.create_entity "inserter" {
    x = 12,
    y = 1,
    dir = "W"
}
game.create_entity "small chest" {
    x = 13,
    y = 1,
    items = {
    },
    description = "铁板",
}

game.create_entity "headquater" {
    x = 1,
    y = 10
}
