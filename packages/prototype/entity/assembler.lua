local gameplay = import_package "vaststars.gameplay"
local prototype = gameplay.prototype

prototype "组装机1" {
    model = "prefabs/assembling-1.prefab",
    icon = "construct/assembler.png",
    construct_detector = {"exclusive"},
    type = {"entity", "assembling", "consumer", "fluidboxes"},
    area = "3x3",
    speed = "100%",
    power = "150kW",
    priority = "secondary",
    fluidboxes = {
        input = {
            {
                capacity = 500,
                height = 100,
                base_level = -100,
                connections = {
                    {type="input", position={1,0,"N"}},
                }
            },
        },
        output = {
            {
                capacity = 500,
                height = 100,
                base_level = 100,
                connections = {
                    {type="output", position={1,2,"S"}},
                }
            },
        },
    }
}