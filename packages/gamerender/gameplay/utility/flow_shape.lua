local M = {}

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
    ['I'] = {'N', 'E', 'S', 'W'},
    ['T'] = {'N', 'E', 'S', 'W'},
    ['X'] = {'N'},
    ['O'] = {'N', 'E', 'S', 'W'},
}

local accel = {}
for shape_type, v in pairs(passable) do
    for _, dir in ipairs(directions[shape_type]) do
        local passable_state = 0
        for b = West, North, -1 do
            if v[(b - DIRECTION[dir]) % 4] then
                passable_state = passable_state << 1 | 1
            else
                passable_state = passable_state << 1 | 0
            end
        end
        accel[shape_type] = accel[shape_type] or {}
        assert(not accel[shape_type][dir])
        accel[shape_type][dir] = passable_state
    end
end

local accel_reversed = {}
for shape_type, v in pairs(accel) do
    for dir, passable_state in pairs(v) do
        accel_reversed[passable_state] = accel_reversed[passable_state] or {}
        table.insert(accel_reversed[passable_state], {shape_type = shape_type, dir = dir})
        table.sort(accel_reversed[passable_state], function(a, b) return DIRECTION[a.dir] < DIRECTION[b.dir] end) -- 目前只有 O 型的管道会出现重复, 默认为竖向
    end
end

function M:to_state(shape_type, dir)
    assert(accel[shape_type] and accel[shape_type][dir], ("invalid shape_type `%s` dir `%s`"):format(shape_type, dir))
    return accel[shape_type][dir]
end

function M:to_type_dir(passable_state)
    assert(accel_reversed[passable_state])
    local t = accel_reversed[passable_state][1]
    return t.shape_type, t.dir
end

function M:set_state(passable_state, passable_dir, state)
    if state == 0 then
        return passable_state & ~(1 << passable_dir)
    else
        return passable_state |  (1 << passable_dir)
    end
end

function M:get_init_prototype_name(prototype_name)
    return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format("O"))
end

function M:get_state(prototype_name, dir)
    local shape_type = assert(prototype_name:match(".*%-(%u).*"))
    return M:to_state(shape_type, dir) == 1
end

function M:get_shape(prototype_name)
    return assert(prototype_name:match(".*%-(%u*).*"))
end

return M