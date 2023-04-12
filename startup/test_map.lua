local world = ...


world:create_entity "小铁制箱子I" {
    x = 1,
    y = 1,
    items = {
        {"铁矿石", 100},
        {"碎石", 100},
    },
}
world:create_entity "组装机I" {
    x = 3,
    y = 1,
}
world:create_entity "科研中心I" {
    x = 7,
    y = 1,
}

world:research_queue {"铁加工1","铁矿熔炼"}

world:create_entity "指挥中心" {
    x = 1,
    y = 10,
    items = {
        {"铁锭",400},
        {"铝棒", 100},
    },
}

world:create_entity "空气过滤器I" {
    x = 2,
    y = 16,
    dir = "W",
    fluids = {
        output = {
            "空气"
        }
    }
}
world:create_entity "液罐I" {
    x = 1,
    y = 21,
    dir = "E",
    fluid = "氮气"
}
world:create_entity "液罐I" {
    x = 15,
    y = 21,
    dir = "N",
    fluid = "氧气"
}
--world:create_entity "压力泵I" {
--    x = 5,
--    y = 16,
--    dir = "E",
--}
world:create_entity "化工厂I" {
    x = 8,
    y = 18,
    recipe = "空气分离1",
    fluids = {
        input = {
            "空气"
        },
        output = {
            "氮气",
            "二氧化碳",
        }
    }
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
    ["^"] = {"地下管1-JI型", "N"},
    [">"] = {"地下管1-JI型", "E"},
    ["v"] = {"地下管1-JI型", "S"},
    ["<"] = {"地下管1-JI型", "W"},
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


 xx════╗
 xx    ║
       xxx
       xxx
       xxx
xxx  ╔═╝ ║    xxx
xxx══╝   ╚>  <xxx
xxx           xxx
]]
}

local gameplay = import_package "vaststars.gameplay"

local function init_fluid()
    local ecs = world.ecs
    local Map = {}
    local N <const> = 0
    local E <const> = 1
    local S <const> = 2
    local W <const> = 3
    local Direction <const> = {
        [N] = {0,-1},
        [E] = {1,0},
        [S] = {0,1},
        [W] = {-1,0},
    }
    local PipeDirection <const> = {
        N = N,
        E = E,
        S = S,
        W = W,
    }

    local function rotate(position, direction, area)
        local w, h = area >> 8, area & 0xFF
        local x, y = position[1], position[2]
        local dir = (PipeDirection[position[3]] + direction) % 4
        w = w - 1
        h = h - 1
        if direction == N then
            return x, y, dir
        elseif direction == E then
            return h - y, x, dir
        elseif direction == S then
            return w - x, h - y, dir
        elseif direction == W then
            return y, w - x, dir
        end
    end

    local function pipePostion(e, position, area)
        local x, y, dir = rotate(position, e.direction, area)
        return e.x + x + Direction[dir][1], e.y + y + Direction[dir][2]
    end

    local function pipeConnect(e, area, conn)
        local x, y, dir = rotate(conn.position, e.direction, area)
        return {
            x = e.x + x,
            y = e.y + y,
            dx = Direction[dir][1],
            dy = Direction[dir][2],
            ground = conn.ground,
        }
    end

    local function walk_pipe(fluid, start_x, start_y)
        local task = {}
        local function push(x, y)
            task[#task+1] = { x, y }
        end
        local function find_next(conn)
            if not conn.ground then
                return conn.x + conn.dx, conn.y + conn.dy
            end
            local x, y = conn.x, conn.y
            for _ = 1, conn.ground do
                x, y = x + conn.dx, y + conn.dy
                local p = Map[(x << 8)|y]
                if p then
                    for _, c in ipairs(p.connections) do
                        if c.ground then
                            return x, y
                        end
                    end
                end
            end
        end
        local function pop()
            local n = #task
            local t = task[n]
            task[n] = nil
            return t[1], t[2]
        end
        push(start_x, start_y)
        while #task > 0 do
            local x, y = pop()
            local p = Map[(x << 8)|y]
            if p ~= nil then
                if p.fluid == nil then
                    p.fluid = fluid
                    for _, conn in ipairs(p.connections) do
                        local nx, ny = find_next(conn)
                        if nx then
                            push(nx, ny)
                        end
                    end
                else
                    assert(p.fluid == fluid)
                end
            end
        end
    end

    local function walk_fluidbox(fluidboxes, classify, e)
        local pt = gameplay.prototype.queryById(e.prototype)
        for i, fluidbox in ipairs(pt.fluidboxes[classify.."put"]) do
            local fluid = fluidboxes[classify..i.."_fluid"]
            if fluid ~= 0 then
                for _, pipe in ipairs(fluidbox.connections) do
                    local x, y = pipePostion(e, pipe.position, pt.area)
                    walk_pipe(fluid, x, y)
                end
            end
        end
    end

    local function init()
        for v in ecs:select "fluidbox:in entity:in" do
            local e = v.entity
            local pt = gameplay.prototype.queryById(e.prototype)
            local fluidbox = pt.fluidbox
            local entity = {
                connections = {}
            }
            for _, conn in ipairs(fluidbox.connections) do
                entity.connections[#entity.connections+1] = pipeConnect(e, pt.area, conn)
            end
            local w, h = pt.area >> 8, pt.area & 0xFF
            if e.direction == E or e.direction == W then
                w, h = h, w
            end
            for i = 0, w-1 do
                for j = 0, h-1 do
                    local x = e.x + i
                    local y = e.y + j
                    Map[(x << 8)|y] = entity
                end
            end
        end
    end
    local function walk()
        for v in ecs:select "fluidboxes:in entity:in" do
            walk_fluidbox(v.fluidboxes, "in", v.entity)
            walk_fluidbox(v.fluidboxes, "out", v.entity)
        end
    end
    local function sync()
        for v in ecs:select "fluidbox:out entity:in fluidbox_changed?out" do
            local p = Map[(v.entity.x << 8)|v.entity.y]
            assert(p.fluid ~= 0 and p.fluid ~= nil)
            v.fluidbox.fluid = p.fluid
            v.fluidbox.id = 0
            v.fluidbox_changed = true
        end
    end

    init()
    walk()
    sync()
end

init_fluid()
