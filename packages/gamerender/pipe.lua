local ecs = ...

local vector2 = ecs.require "vector2"
local m = {}

local North <const> = 0
local East  <const> = 1
local South <const> = 2
local West  <const> = 3
local DIRECTION <const> = {
    N = 0,
    E = 1,
    S = 2,
    W = 3,
}

local to_passable_state, to_prototype_dir, set_passable_state ; do
    -- 'true' means that the direction is passable
    local passable = {
        ['U'] = {[North] = true,  [East] = false, [South] = false, [West] = false, },
        ['L'] = {[North] = true,  [East] = true,  [South] = false, [West] = false, },
        ['I'] = {[North] = true,  [East] = false, [South] = true , [West] = false, },
        ['T'] = {[North] = false, [East] = true,  [South] = true , [West] = true,  },
        ['X'] = {[North] = true,  [East] = true,  [South] = true , [West] = true,  },
        ['O'] = {[North] = false, [East] = false, [South] = false, [West] = false, },
    }

    local directions = {
        ['U'] = {'N', 'E', 'S', 'W'},
        ['L'] = {'N', 'E', 'S', 'W'},
        ['I'] = {'N', 'E'},
        ['T'] = {'N', 'E', 'S', 'W'},
        ['X'] = {'N'},
        ['O'] = {'N', 'E'},
    }

    local accel = {}
    for prototype, v in pairs(passable) do
        for _, dir in ipairs(directions[prototype]) do
            local passable_state = 0
            for b = West, North, -1 do
                if v[(b - DIRECTION[dir]) % 4] then
                    passable_state = passable_state << 1 | 1
                else
                    passable_state = passable_state << 1 | 0
                end
            end
            accel[prototype] = accel[prototype] or {}
            assert(not accel[prototype][dir])
            accel[prototype][dir] = passable_state
        end
    end

    local accel_reversed = {}
    for prototype, v in pairs(accel) do
        for dir, passable_state in pairs(v) do
            accel_reversed[passable_state] = accel_reversed[passable_state] or {}
            table.insert(accel_reversed[passable_state], {prototype = prototype, dir = dir})
        end
    end

    function to_passable_state(prototype, dir)
        assert(accel[prototype] and accel[prototype][dir], ("invalid prototype `%s` dir `%s`"):format(prototype, dir))
        return accel[prototype][dir]
    end

    function to_prototype_dir(passable_state)
        assert(accel_reversed[passable_state])
        local t = accel_reversed[passable_state][1]
        return t.prototype, t.dir
    end

    function set_passable_state(passable_state, passable_dir, state)
        if state == 0 then
            return passable_state & ~(1 << passable_dir)
        else
            return passable_state |  (1 << passable_dir)
        end
    end
end

local neighbor <const> = {
    {vector2.DOWN,  South},
    {vector2.UP,    North},
    {vector2.LEFT,  West},
    {vector2.RIGHT, East},
}

-- prototype_name 格式: 管道1-L型, 其中 L 为水管分类(prototype)
-- is_fluidbox = function(x, y) return true/false end
function m.update(prototype_name, x, y, is_fluidbox)
    local passable_state = 0

    for _, v in ipairs(neighbor) do
        if is_fluidbox(x + v[1][1], y + v[1][2]) then
            passable_state = set_passable_state(passable_state, v[2], 1)
        end
    end

    local prototype, dir = to_prototype_dir(passable_state)
    return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(prototype)), dir
end

return m