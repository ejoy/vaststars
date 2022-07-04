local iprototype = require "gameplay.interface.prototype"

local shift = 0
local dir_bits = {}
local accel = {}
local accel_reversed = {}

for _, typeobject in pairs(iprototype.each_maintype("entity")) do
    if not typeobject.pipe_type then
        goto continue
    end

    for _, entity_dir in ipairs(typeobject.pipe_direction) do
        local bits = 0
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            local dir = iprototype.rotate_dir(connection.position[3], entity_dir)
            dir_bits[typeobject.pipe_type] = dir_bits[typeobject.pipe_type] or {}
            if not dir_bits[typeobject.pipe_type][dir] then
                shift = shift + 1
                dir_bits[typeobject.pipe_type][dir] = shift
            end
            bits = bits | (1 << dir_bits[typeobject.pipe_type][dir])
        end
        accel[typeobject.pipe_type] = accel[typeobject.pipe_type] or {}
        assert(accel[typeobject.pipe_type][bits] == nil)
        accel[typeobject.pipe_type][bits] = {prototype_name = typeobject.name, dir = entity_dir}
    end
    ::continue::
end

for pipe_type, v1 in pairs(accel) do
    for bits, v2 in pairs(v1) do
        accel_reversed[v2.prototype_name] = accel_reversed[v2.prototype_name] or {}
        assert(accel_reversed[v2.prototype_name][v2.dir] == nil)
        accel_reversed[v2.prototype_name][v2.dir] = {
            pipe_type = pipe_type,
            bits = bits,
        }
    end
end

local M = {}
function M.set_connection(prototype_name, dir, connection_dir, s)
    assert(accel_reversed[prototype_name], ("invalid prototype_name `%s`"):format(prototype_name))
    assert(accel_reversed[prototype_name][dir], ("invalid dir `%s`"):format(dir))
    local typeobject = iprototype.queryByName("entity", prototype_name)
    local c = accel_reversed[prototype_name][dir]
    local bits
    if s then
        bits = c.bits |  (1 << dir_bits[typeobject.pipe_type][connection_dir])
    else
        bits = c.bits & ~(1 << dir_bits[typeobject.pipe_type][connection_dir])
    end
    assert(accel[c.pipe_type], ("invalid pipe_type `%s`"):format(c.pipe_type))
    local r = accel[c.pipe_type][bits]
    assert(r, ("invalid bits `%s`"):format(bits))
    return r.prototype_name, r.dir
end

function M.covers(prototype_name, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    for connection_dir in pairs(dir_bits[typeobject.pipe_type]) do
        prototype_name, dir = M.set_connection(prototype_name, dir, connection_dir, true)
    end
    return prototype_name, dir
end

function M.cleanup(prototype_name, dir)
    local typeobject = iprototype.queryByName("entity", prototype_name)
    for connection_dir in pairs(dir_bits[typeobject.pipe_type]) do
        prototype_name, dir = M.set_connection(prototype_name, dir, connection_dir, false)
    end
    return prototype_name, dir
end

return M