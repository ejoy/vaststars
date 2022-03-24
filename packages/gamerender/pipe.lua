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

local typedir_to_passable_state, passable_state_to_typedir, set_passable_state ; do
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
        ['O'] = {'N', 'E', 'S', 'W'},
    }

    local accel = {}
    for type_t, v in pairs(passable) do
        for _, dir in ipairs(directions[type_t]) do
            local state = 0
            for b = West, North, -1 do
                if v[(b - DIRECTION[dir]) % 4] then
                    state = state << 1 | 1
                else
                    state = state << 1 | 0
                end
            end
            accel[type_t .. dir] = state
        end
    end

    local accel_reversed = {}
    for typedir, passable_state in pairs(accel) do
        accel_reversed[passable_state] = accel_reversed[passable_state] or {}
        table.insert(accel_reversed[passable_state], typedir)
    end

    function typedir_to_passable_state(typedir)
        return accel[typedir]
    end

    function passable_state_to_typedir(passable_state)
        return accel_reversed[passable_state][1]
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
    {vector2.DOWN, South},
    {vector2.UP,   North},
    {vector2.LEFT, West},
    {vector2.RIGHT,East},
}
function m.adjust(prototype_name, x, y, check)
    local passable_state = 0

    for _, v in ipairs(neighbor) do
        if check(x + v[1][1], y + v[1][2]) then
            passable_state = set_passable_state(passable_state, v[2], 1)
        end
    end

    local typedir = passable_state_to_typedir(passable_state)
    local new_prototype_name = prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format(typedir:sub(1, 1)))
    return new_prototype_name, typedir:sub(2, 2)
end

return m