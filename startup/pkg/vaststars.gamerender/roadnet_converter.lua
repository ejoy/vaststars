local iprototype = require "gameplay.interface.prototype"
local iprototype_cache = require "gameplay.prototype_cache.init"

local _mask_to_shape_dir, _prototype_name_to_shape, _mask_to_prototype_name_dir, _prototype_name_dir_to_mask; do
    function _mask_to_shape_dir(mask)
        return table.unpack(assert(iprototype_cache.get("roadnet_converter").mask_shape_dir[mask]))
    end

    function _mask_to_prototype_name_dir(mask)
        return table.unpack(assert(iprototype_cache.get("roadnet_converter").mask_prototype_name_dir[mask]))
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
        return assert(iprototype_cache.get("roadnet_converter").prototype_name_dir_mask[prototype_name][dir])
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