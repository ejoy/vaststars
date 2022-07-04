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

-- 'true' means that the direction is connectable
local connectable = {
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
for shape_type, v in pairs(connectable) do
    for _, dir in ipairs(directions[shape_type]) do
        local connectable_state = 0
        for b = West, North, -1 do
            if v[(b - DIRECTION[dir]) % 4] then
                connectable_state = connectable_state << 1 | 1
            else
                connectable_state = connectable_state << 1 | 0
            end
        end
        accel[shape_type] = accel[shape_type] or {}
        assert(not accel[shape_type][dir])
        accel[shape_type][dir] = connectable_state
    end
end

local accel_reversed = {}
for shape_type, v in pairs(accel) do
    for dir, connectable_state in pairs(v) do
        accel_reversed[connectable_state] = accel_reversed[connectable_state] or {}
        table.insert(accel_reversed[connectable_state], {shape_type = shape_type, dir = dir})
        table.sort(accel_reversed[connectable_state], function(a, b) return DIRECTION[a.dir] < DIRECTION[b.dir] end) -- 目前只有 O 型的管道会出现重复, 默认为竖向
    end
end

function M.to_state(shape_type, dir)
    assert(accel[shape_type] and accel[shape_type][dir], ("invalid shape_type `%s` dir `%s`"):format(shape_type, dir))
    return accel[shape_type][dir]
end

function M.to_type_dir(connectable_state)
    assert(accel_reversed[connectable_state])
    local t = accel_reversed[connectable_state][1]
    return t.shape_type, t.dir
end

function M.to_prototype_name(prototype_name, shape_type)
    return prototype_name:gsub("(.*%-)(%u*)(.*)", ("%%1%s%%3"):format(shape_type))
end

function M.set_shape_edge(connectable_state, connectable_dir, state)
    if state == true then
        return connectable_state |  (1 << connectable_dir)
    else
        return connectable_state & ~(1 << connectable_dir)
    end
end

function M.get_init_prototype_name(prototype_name)
    return prototype_name:gsub("(.*%-)(%u)(.*)", ("%%1%s%%3"):format("O"))
end

function M.get_state(prototype_name, dir, check_dir)
    local shape_type = assert(prototype_name:match(".*%-(%u).*"))
    return M.to_state(shape_type, dir) & (1 << DIRECTION[check_dir]) == (1 << DIRECTION[check_dir])
end

function M.get_shape(prototype_name)
    return assert(prototype_name:match(".*%-(%u*).*"))
end

function M.prototype_name_to_state(prototype_name, dir)
    local shape_type = assert(prototype_name:match(".*%-(%u).*"))
    return M.to_state(shape_type, dir)
end

return M