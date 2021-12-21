local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "headquater" {
    type ={"entity", "generator"},
    area = "5x5",
    power = "1MW",
    priority = "primary",
}
prototype "assembling 1" {
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
}

prototype "furnace 1" {
    type = {"entity", "assembling", "consumer"},
    area = "3x3",
    speed = "50%",
    power = "75kW",
    priority = "secondary",
}

prototype "small chest" {
    type = {"entity", "chest"},
    area = "1x1",
    slots = 10,
    stack = 50,
}

prototype "miner" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}

prototype "goods station 1" {
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
    power = "12kW",
    priority = "secondary",
}

prototype "steam generator 1" {
    type ={"entity", "generator"},
    area = "2x3",
    power = "1MW",
    priority = "secondary",
}

prototype "chemical plant 1" {
    type ={"entity", "assembling", "consumer"},
    area = "3x3",
    power = "200kW",
    drain = "6kW",
    priority = "secondary",
}

prototype "distillery 1" {
    type ={"entity", "assembling", "consumer"},
    area = "5x5",
    power = "240kW",
    priority = "secondary",
}

prototype "crusher 1" {
    type ={"entity", "assembling", "consumer"},
    area = "3x3",
    power = "100kW",
    drain = "3kW",
    priority = "secondary",
}

prototype "logistics center" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "600kW",
    priority = "secondary",
}

prototype "storage tank 1" {
    type ={"entity"},
    area = "3x3",
}

prototype "offshore pump" {
    type ={"entity", "consumer"},
    area = "1x2",
    power = "6kW",
    priority = "secondary",
}

prototype "pump 1" {
    type ={"entity", "consumer"},
    area = "1x2",
    power = "10kW",
    drain = "300W",
    priority = "secondary",
}

prototype "chimney 1" {
    type ={"entity"},
    area = "2x2",
}

prototype "outfall 1" {
    type ={"entity"},
    area = "2x2",
}

prototype "wind turbine 1" {
    type ={"entity", "generator"},
    area = "3x3",
    power = "1.2MW",
    priority = "primary",
}

prototype "iron electric pole" {
    type ={"entity"},
    area = "1x1",
}

prototype "lab 1" {
    type ={"entity", "consumer"},
    area = "3x3",
    power = "150kW",
    priority = "secondary",
}

prototype "electrolyzer 1" {
    type ={"entity", "assembling", "consumer"},
    area = "5x5",
    power = "1MW",
    drain = "30kW",
    priority = "secondary",
}

prototype "air filter" {
    type ={"entity", "consumer"},
    area = "2x2",
    power = "50kW",
    drain = "1.5kW",
    priority = "secondary",
}

prototype "pipe 1" {
    type ={"entity"},
    area = "1x1",
}

prototype "underground pipe 1" {
    type ={"entity"},
    area = "1x1",
}

prototype "solar panel" {
    type ={"entity","generator"},
    area = "3x3",
    power = "100kW",
    priority = "primary",
}

prototype "accumulator" {
    type ={"entity"},
    area = "2x2",
    priority = "secondary",
}

prototype "hydro plant" {
    type ={"entity", "assembling", "consumer"},
    area = "5x5",
    power = "150kW",
    priority = "secondary",
}

prototype "nuclear reactor" {
    type = {"entity", "generator", "burner"},
    area = "3x3",
    power = "40MW",
    priority = "primary",
}