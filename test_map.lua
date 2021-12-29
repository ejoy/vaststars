local world = ...

world:create_entity "小型铁制箱子" {
    x = 1,
    y = 1,
    items = {
        {"铁矿石", 100},
    },
    description = "铁矿石",
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
    description = "碎石",
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
    description = "铁棒",
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
    description = "铁板",
}

world:create_entity "指挥中心" {
    x = 1,
    y = 10
}

world:create_entity "液罐1" {
    x = 1,
    y = 20,
    fluid = {"空气",20000}
}
world:create_entity "液罐1" {
    x = 1,
    y = 14,
    fluid = {"氮气",0}
}
world:create_entity "液罐1" {
    x = 15,
    y = 14,
    fluid = {"氧气",0}
}
world:create_entity "化工厂1" {
    x = 8,
    y = 17,
    recipe = "空气分离1"
}

local function PipeType(s)
    local m = 0
    for i = 1, 4 do
        if s:sub(i,i) ~= "_" then
            m = m | (1 << (i-1))
        end
    end
    return m
end

local convertPipeType = {
    ["║"] = PipeType "N_S_",
    ["═"] = PipeType "_E_W",
    ["╔"] = PipeType "_ES_",
    ["╠"] = PipeType "NES_",
    ["╚"] = PipeType "NE__",
    ["╦"] = PipeType "_ESW",
    ["╬"] = PipeType "NESW",
    ["╩"] = PipeType "NE_W",
    ["╗"] = PipeType "__SW",
    ["╣"] = PipeType "N_SW",
    ["╝"] = PipeType "N__W",
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
            c = utf8.char(c)
            if convertPipeType[c] then
                local x = ox + i - 1
                local y = oy + j - 1
                world:create_entity "管道1" {
                    x = x,
                    y = y,
                    pipe = {
                        type = convertPipeType[c],
                        fluid = 0,
                        id = 0,
                    },
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
xxx════╗
xxx    ║
       xxx
       xxx
       xxx
xxx  ╔═╝ ║    xxx
xxx══╝   ╚════xxx
xxx           xxx
]]
}
