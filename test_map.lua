local game = ...

game.create_entity "小型铁制箱子" {
    x = 1,
    y = 1,
    items = {
        {"铁矿石", 100},
    },
    description = "铁矿石",
}
game.create_entity "机器爪1" {
    x = 2,
    y = 1,
    dir = "W"
}
game.create_entity "组装机1" {
    x = 3,
    y = 1,
    recipe = "铁锭"
}
game.create_entity "机器爪1" {
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
    x = 7,
    y = 2,
    dir = "S"
}

game.create_entity "组装机1" {
    x = 7,
    y = 3,
    recipe = "铁棒1"
}

game.create_entity "机器爪1" {
    x = 7,
    y = 6,
    dir = "S"
}

game.create_entity "小型铁制箱子" {
    x = 7,
    y = 7,
    items = {
    },
    description = "铁棒",
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

local pipeType = {}
([[
═║
╔╦╗
╠╬╣
╚╩╝
]]):gsub("[^\n\r]", function (s)
    pipeType[s] = true
end)

local function create_pipe(x, y, graph)
    local j = 1
    for line in graph:gmatch "[^\n\r]*" do
        for i = 1, #line do
            local c = line:sub(i,i)
            if pipeType[c] then
                game.create_entity "管道1" {
                    x = x + i - 1,
                    y = y + j - 1,
                    pipetype = c
                }
            end
        end
        j = j + 1
    end
end

create_pipe(1, 14, [[
xxx
xxx════╗
xxx    ║
       xxx
       xxx
       xxx
xxx  ╔═╝ ║    xxx
xxx══╝   ╚════xxx
xxx           xxx
]])

game.create_entity "液罐1" {
    x = 1,
    y = 20,
    fluid = {"空气",20000}
}
game.create_entity "液罐1" {
    x = 1,
    y = 14,
    fluid = {}
}
game.create_entity "液罐1" {
    x = 15,
    y = 14,
    fluid = {}
}
game.create_entity "化工厂1" {
    x = 8,
    y = 17,
    recipe = "空气分离1"
}
