local create_cache = require "utility.cache"
local iprototype = require "gameplay.interface.prototype"

local tiles = create_cache("coord", "gameplay_eid") -- = {[coord] = {gameplay_eid = xx, coord = coord}

local m = {}
function m:set(gameplay_eid, x, y, w, h)
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local coord = iprototype.packcoord(x + i, y + j)
            tiles:set({coord = coord, gameplay_eid = gameplay_eid})
        end
    end
end

function m:remove(gameplay_eid)
    for coord in tiles:select("gameplay_eid", gameplay_eid) do
        tiles:remove(coord)
    end
end

function m:reset(gameplay_eid, x, y, w, h)
    self:remove(gameplay_eid)
    self:set(gameplay_eid, x, y, w, h)
end

function m:get(x, y, w, h)
    local result = {}
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local coord = iprototype.packcoord(x + i, y + j)
            local tile = tiles:selectkey(coord)
            if tile then
                result[tile.gameplay_eid] = true
            end
        end
    end
    return next, result, nil
end

function m:clear()
    tiles:clear()
end

return m