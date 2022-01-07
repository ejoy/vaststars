local world = ...

--[[
world:create_entity "小型铁制箱子" {
    x = 1,
    y = 1,
    items = {
        {"铁矿石", 100},
    },
}
world:create_entity "机器爪1" {
    x = 2,
    y = 1,
    dir = "W"
}
world:create_entity "组装机1" {
    x = 3,
    y = 1,
    recipe = "铁锭"
}
world:create_entity "机器爪1" {
    x = 6,
    y = 1,
    dir = "W"
}
world:create_entity "小型铁制箱子" {
    x = 7,
    y = 1,
    items = {
    },
}

world:create_entity "机器爪1" {
    x = 7,
    y = 2,
    dir = "N"
}

world:create_entity "组装机1" {
    x = 7,
    y = 3,
    recipe = "铁棒1"
}

world:create_entity "机器爪1" {
    x = 7,
    y = 6,
    dir = "N"
}

world:create_entity "小型铁制箱子" {
    x = 7,
    y = 7,
    items = {
    },
}

world:create_entity "机器爪1" {
    x = 8,
    y = 1,
    dir = "W"
}
world:create_entity "组装机1" {
    x = 9,
    y = 1,
    recipe = "铁板1"
}
world:create_entity "机器爪1" {
    x = 12,
    y = 1,
    dir = "W"
}
world:create_entity "小型铁制箱子" {
    x = 13,
    y = 1,
    items = {
    },
}
]]

world:create_entity "指挥中心" {
    x = 1,
    y = 10
}

world:create_entity "空气过滤器1" {
    x = 1,
    y = 15,
    dir = "W",
    fluid = {"空气",20000}
}
world:create_entity "液罐1" {
    x = 1,
    y = 22,
    dir = "E",
    fluid = {"氮气",0}
}
world:create_entity "液罐1" {
    x = 15,
    y = 22,
    dir = "N",
    fluid = {"氧气",0}
}
world:create_entity "压力泵1" {
    x = 5,
    y = 16,
    dir = "E",
    fluid = {}
}
world:create_entity "化工厂1" {
    x = 8,
    y = 18,
    recipe = "空气分离1"
}

local convertPipeType = {
    ["║"] = {"管道1-I型", "N"},
    ["═"] = {"管道1-I型", "E"},
    ["╔"] = {"管道1-L型", "E"},
    ["╠"] = {"管道1-T型", "W"},
    ["╚"] = {"管道1-L型", "N"},
    ["╦"] = {"管道1-T型", "N"},
    ["╬"] = {"管道1-X型", "N"},
    ["╩"] = {"管道1-T型", "S"},
    ["╗"] = {"管道1-L型", "S"},
    ["╣"] = {"管道1-T型", "E"},
    ["╝"] = {"管道1-L型", "W"},
}

local function create_pipe(t)
    local ox, oy = t.offset.x, t.offset.y
    local n = 0
    for _ in t.graph:gmatch "[^\n\r]*" do
        n = n + 1
    end
    local j = 1
    for line in t.graph:gmatch "[^\n\r]*" do
        local i = 1
        for _, c in utf8.codes(line) do
            local pipetype = convertPipeType[utf8.char(c)]
            if pipetype then
                local entity, dir = pipetype[1], pipetype[2]
                local x = ox + i - 1
                local y = oy + j - 1
                world:create_entity (entity) {
                    x = x,
                    y = y,
                    dir = dir,
                    fluid = {}
                }
            end
            i = i + 1
        end
        j = j + 1
    end
end

create_pipe {
    offset = {x=1, y=14},
    graph = [[

xxx
xxx═>>═╗
xxx    ║
       xxx
       xxx
       xxx
     ╔═╝ ║
xxx══╝   ╚════xxx
xxx           xxx
xxx           xxx
]]
}
