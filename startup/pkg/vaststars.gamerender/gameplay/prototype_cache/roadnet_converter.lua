local iprototype = require "gameplay.interface.prototype"

return function()
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
        local track = pt.track
        for _, dir in ipairs(pt.building_direction) do
            local v = 0
            for _, conn in ipairs(pt.crossing.connections) do
                local dn = assert(iprototype.rotate_dir(conn.position[3], dir))
                v = v | (1 << dn)
            end

            mask_shape_dir[v] = {track, dir}
            mask_prototype_name_dir[v] = {pt.name, dir}

            assert(not prototype_name_dir_mask[pt.name][dir])
            prototype_name_dir_mask[pt.name][dir] = v
        end

        prototype_name_shape[pt.name] = track
    end

    return {
        mask_shape_dir = mask_shape_dir,
        prototype_name_shape = prototype_name_shape,
        mask_prototype_name_dir = mask_prototype_name_dir,
        prototype_name_dir_mask = prototype_name_dir_mask,
    }
end