local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "headquater" {
    type ={"entity", "generator"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
}
prototype "assembling" {
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "50%",
    power = "150kW",
    priority = "secondary",
}
prototype "chest" {
    type = {"entity", "chest"},
    area = "1x1",
    slots = 20,
    stack = 10,
}

prototype "goods station" {
    type = {"entity", "chest"},
    area = "1x1",
    slots = 30,
    stack = 20,
}

prototype "inserter" {
    type = {"entity", "inserter", "consumer"},
    area = "1x1",
    speed = "1s",
    stack = 50,
    power = "13kW",
    priority = "primary",
}
prototype "nuclear reactor" {
    type = {"entity", "generator", "burner"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
}