local game = ...

game.create_entity "chest" {
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
game.create_entity "assembling" {
    x = 3,
    y = 1,
    recipe = "iron ignot"
}
game.create_entity "inserter" {
    x = 6,
    y = 1,
    dir = "W"
}
game.create_entity "assembling" {
    x = 7,
    y = 1,
    recipe = "iron plate"
}
game.create_entity "inserter" {
    x = 10,
    y = 1,
    dir = "W"
}
game.create_entity "chest" {
    x = 11,
    y = 1,
    items = {
    },
    description = "铁板",
}

game.create_entity "headquater" {
    x = 1,
    y = 10
}
