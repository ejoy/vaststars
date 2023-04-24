local iprototype = require "gameplay.interface.prototype"
local iconstant = require "gameplay.interface.constant"
local iprototype_cache = require "gameplay.prototype_cache.init"

local ALL_DIR = iconstant.ALL_DIR

local MAPPING <const> = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local _mask_to_shape_dir, _prototype_name_to_shape, _mask_to_prototype_name_dir, _prototype_name_dir_to_mask; do
    function _mask_to_shape_dir(mask)
        local res = 0
        for _, dir in pairs(ALL_DIR) do
            local d = MAPPING[dir]
            local v = (mask >> d) & 0x01
            res = res | v << iprototype.dir_tonumber(dir)
        end
        return table.unpack(assert(iprototype_cache.get("roadnet_converter").mask_shape_dir[res]))
    end

    function _mask_to_prototype_name_dir(mask)
        local res = 0
        for _, dir in pairs(ALL_DIR) do
            local d = MAPPING[dir]
            local v = (mask >> d) & 0x01
            res = res | v << iprototype.dir_tonumber(dir)
        end
        return table.unpack(assert(iprototype_cache.get("roadnet_converter").mask_prototype_name_dir[res]))
    end

    local cover = {
        ['I'] = {
            ['S'] = 'N',
            ['W'] = 'E',
        },
        ['X'] = {
            ['W'] = 'N',
            ['S'] = 'N',
            ['E'] = 'N',
        },
        ['O'] = {
            ['W'] = 'N',
            ['S'] = 'N',
            ['E'] = 'N',
        },
    }
    function _prototype_name_dir_to_mask(prototype_name, dir)
        local typeobject = iprototype.queryByName(prototype_name)
        if cover[typeobject.track] and cover[typeobject.track][dir] then
            dir = cover[typeobject.track][dir]
        end
        local v = assert(iprototype_cache.get("roadnet_converter").prototype_name_dir_mask[prototype_name][dir])
        local mask = 0
        for _, pd in pairs(ALL_DIR) do
            local d = MAPPING[pd]
            mask = mask | (((v >> iprototype.dir_tonumber(pd)) & 0x1) << d)
        end
        return mask
    end

    function _prototype_name_to_shape(prototype_name)
        return iprototype_cache.get("roadnet_converter").prototype_name_shape[prototype_name]
    end
end

return {
    mask_to_shape_dir = _mask_to_shape_dir,
    mask_to_prototype_name_dir = _mask_to_prototype_name_dir,
    prototype_name_dir_to_mask = _prototype_name_dir_to_mask,
    to_shape = _prototype_name_to_shape,
}