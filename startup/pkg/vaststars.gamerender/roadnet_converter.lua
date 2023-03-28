local iprototype = require "gameplay.interface.prototype"
local iconstant = require "gameplay.interface.constant"
local ALL_DIR = iconstant.ALL_DIR

local MAPPING <const> = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local _mask_to_shape_dir, _prototype_name_to_shape, _mask_to_prototype_name_dir, _prototype_name_dir_to_mask; do
    local mt = {
        __index = function(t, k)
            if not rawget(t, k) then
                t[k] = {}
            end
            return t[k]
        end
    }
    local mask_shape_dir = setmetatable({}, mt)
    local prototype_name_shape = {}
    local mask_prototype_name_dir = {}
    local prototype_name_dir_mask = setmetatable({}, mt)

    for _, pt in pairs(iprototype.each_type("building", "road")) do
        for _, dir in ipairs(pt.flow_direction) do
            local v = 0
            for _, conn in ipairs(pt.crossing.connections) do
                local dn = assert(iprototype.dir_tonumber(iprototype.rotate_dir(conn.position[3], dir)))
                v = v | (1 << dn)
            end

            mask_shape_dir[v] = {pt.track, dir}
            mask_prototype_name_dir[v] = {pt.name, dir}

            assert(not prototype_name_dir_mask[pt.name][dir])
            prototype_name_dir_mask[pt.name][dir] = v
        end

        prototype_name_shape[pt.name] = pt.track
    end

    function _mask_to_shape_dir(mask)
        local res = 0
        for _, dir in pairs(ALL_DIR) do
            local d = MAPPING[dir]
            local v = (mask >> d) & 0x01
            res = res | v << iprototype.dir_tonumber(dir)
        end
        return table.unpack(assert(mask_shape_dir[res]))
    end

    function _mask_to_prototype_name_dir(mask)
        local res = 0
        for _, dir in pairs(ALL_DIR) do
            local d = MAPPING[dir]
            local v = (mask >> d) & 0x01
            res = res | v << iprototype.dir_tonumber(dir)
        end
        return table.unpack(assert(mask_prototype_name_dir[res]))
    end

    function _prototype_name_dir_to_mask(prototype_name, dir)
        local v = assert(prototype_name_dir_mask[prototype_name][dir])
        local mask = 0
        for _, pd in pairs(ALL_DIR) do
            local d = MAPPING[pd]
            mask = mask | (((v >> iprototype.dir_tonumber(pd)) & 0x1) << d)
        end
        return mask
    end

    function _prototype_name_to_shape(prototype_name)
        return prototype_name_shape[prototype_name]
    end
end

return {
    mask_to_shape_dir = _mask_to_shape_dir,
    mask_to_prototype_name_dir = _mask_to_prototype_name_dir,
    prototype_name_dir_to_mask = _prototype_name_dir_to_mask,
    to_shape = _prototype_name_to_shape,
}