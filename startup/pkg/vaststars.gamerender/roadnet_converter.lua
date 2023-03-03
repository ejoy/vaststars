local iprototype = require "gameplay.interface.prototype"
local mapping = {
    W = 0, -- left
    N = 1, -- top
    E = 2, -- right
    S = 3, -- bottom
}

local _from_track, _to_shape, _mask_to_prototype_name, _prototype_name_dir_to_mask; do
    local mt = {
        __index = function(t, k)
            if not rawget(t, k) then
                t[k] = {}
            end
            return t[k]
        end
    }
    local cache = setmetatable({}, mt)
    local cache_rev = setmetatable({}, mt)
    local prototype_name_shape = {}
    local mask_prototype_name_dir = {}
    local prototype_name_dir_to_mask = setmetatable({}, mt)

    for _, pt in pairs(iprototype.each_maintype("building", "road")) do
        for _, dir in ipairs(pt.flow_direction) do
            local mask = 0
            for _, conn in ipairs(pt.crossing.connections) do
                local d = assert(mapping[iprototype.rotate_dir(conn.position[3], dir)])
                local v
                if conn.roadside then
                    v = 2
                else
                    v = 1
                end
                mask = mask | (v << (d * 2))
            end

            cache[pt.track][dir] = mask
            cache_rev[mask] = {pt.track, dir}
            mask_prototype_name_dir[mask] = {pt.name, dir}
            prototype_name_dir_to_mask[pt.name][dir] = mask
        end

        prototype_name_shape[pt.name] = pt.track
    end

    function _from_track(mask)
        return cache_rev[mask]
    end

    function _to_shape(prototype_name)
        return prototype_name_shape[prototype_name]
    end

    function _mask_to_prototype_name(mask)
        return mask_prototype_name_dir[mask][1], mask_prototype_name_dir[mask][2]
    end

    -- TODO: remove this function
    function _prototype_name_dir_to_mask(prototype_name, dir)
        local mask = prototype_name_dir_to_mask[prototype_name][dir]
        local r = 0
        for _, b in pairs(mapping) do
            if mask & (1 << (b * 2)) == (1 << (b * 2)) then
                r = r | (1 << (b))
            end
        end
        return r
    end
end

-- TODO: 
local function _convert_mask(mask)
    local r = 0
    for _, b in pairs(mapping) do
        if mask & (1 << b) ~= 0 then
            r = r | (1 << (b * 2))
        end
    end
    return r
end

local function convert(t)
    local res = {}
    for _, r in ipairs(t) do
        local typeobject = iprototype.queryByName(r.prototype_name)
        res[iprototype.packcoord(r.x, r.y)] = {
            r.x,
            r.y,
            "normal",
            typeobject.track,
            r.dir
        }
    end
    return res
end

-- Convert archive data to render data format
local function from(t)
    local res = {}
    for coord, mask in pairs(t) do
        local v = _from_track(_convert_mask(mask))
        local shape, dir = v[1], v[2]
        local x, y = iprototype.unpackcoord(coord)
        res[coord] = {x, y, "normal", shape, dir}
    end
    return res
end

local function to_roadnet_data(t)
    local res = {}
    for coord, mask in pairs(t) do
        local prototype_name, dir = _mask_to_prototype_name(_convert_mask(mask))
        res[coord] = {prototype_name, dir}
    end
    return res
end

return {
    convert = convert,
    from = from,
    to_shape = _to_shape,
    to_roadnet_data = to_roadnet_data,
    prototype_name_dir_to_mask = _prototype_name_dir_to_mask,
}