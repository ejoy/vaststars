local gameplay = import_package "vaststars.gameplay"
local game = gameplay.game

--[[
  o  o  o
  |  |  |
 xxxxxxxxx
 xxxxxxxxx
 xxxxxxxxx
   || ||
  xxx xxx
o-xxx xxx-o
  xxx xxx
   |   |
   o   o
]]

--铜板箱
game.create_entity "chest" {
    x = 2,
    y = 10,
    items = {
        {"copper plate", 100},
        {"copper plate", 50},
    },
    description = "铜板箱",
}
game.create_entity "chest" {
    x = 5,
    y = 10,
    items = {
        {"copper plate", 100},
        {"copper plate", 50},
    },
    description = "铜板箱",
}
game.create_entity "chest" {
    x = 8,
    y = 10,
    items = {
        {"copper plate", 100},
        {"copper plate", 50},
    },
    description = "铜板箱",
}

--铁板箱
game.create_entity "chest" {
    x = 0,
    y = 3,
    items = {{"iron plate", 100}},
    description = "铁板箱",
}
game.create_entity "chest" {
    x = 10,
    y = 3,
    items = {{"iron plate", 100}},
    description = "铁板箱",
}

--绿板箱
game.create_entity "chest" {
    x = 3,
    y = 0,
    items = {},
    description = "绿板箱",
}
game.create_entity "chest" {
    x = 7,
    y = 0,
    items = {},
    description = "绿板箱",
}

--铜板爪
game.create_entity "inserter" {
    x = 2,
    y = 9,
    dir = "N"
}
game.create_entity "inserter" {
    x = 5,
    y = 9,
    dir = "N"
}
game.create_entity "inserter" {
    x = 8,
    y = 9,
    dir = "N"
}

--铜丝爪
game.create_entity "inserter" {
    x = 3,
    y = 5,
    dir = "N"
}
game.create_entity "inserter" {
    x = 4,
    y = 5,
    dir = "N"
}
game.create_entity "inserter" {
    x = 6,
    y = 5,
    dir = "N"
}
game.create_entity "inserter" {
    x = 7,
    y = 5,
    dir = "N"
}

--铁板爪
game.create_entity "inserter" {
    x = 1,
    y = 3,
    dir = "W",
}
game.create_entity "inserter" {
    x = 9,
    y = 3,
    dir = "E"
}

--绿板爪
game.create_entity "inserter" {
    x = 3,
    y = 1,
    dir = "N"
}
game.create_entity "inserter" {
    x = 7,
    y = 1,
    dir = "N"
}

--铜丝厂
game.create_entity "assembling" {
    x = 1,
    y = 6,
    recipe = "copper cable"
}
game.create_entity "assembling" {
    x = 4,
    y = 6,
    recipe = "copper cable"
}
game.create_entity "assembling" {
    x = 7,
    y = 6,
    recipe = "copper cable"
}

--绿板厂
game.create_entity "assembling" {
    x = 2,
    y = 2,
    recipe = "electronic circuit"
}
game.create_entity "assembling" {
    x = 6,
    y = 2,
    recipe = "electronic circuit"
}

game.create_entity "test generator" {
    x = 10,
    y = 10,
}
