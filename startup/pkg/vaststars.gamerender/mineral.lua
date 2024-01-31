local ecs   = ...
local world = ecs.world
local w     = world.w

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local CONSTANT <const> = require "gameplay.interface.constant"
local ROTATORS <const> = CONSTANT.ROTATORS

local igroup = ecs.require "group"
local icoord = require "coord"
local iprototype = require "gameplay.interface.prototype"
local igame_object = ecs.require "engine.game_object"

local mineral_hash = {}
local mineral_cache = {}
local mineral_source = {}

local m = {}
function m.init(map)
    mineral_hash = {}
    mineral_cache = {}
    mineral_source = map

    for c, mineral in pairs(map) do
        local x, y = c:match("^(%d+),(%d+)$")
        x, y = x + 0, y + 0

        local typeobject = iprototype.queryByName(mineral)
        local errmsg <const> = "%s is defined as a type of mineral, but no corresponding mineral model is configured."
        local mineral_model = assert(typeobject).mineral_model or error(errmsg:format(mineral))

        local w, h = typeobject.mineral_area:match("^(%d+)x(%d+)$")
        w, h = w + 0, h + 0

        local hash = icoord.pack(x, y)
        mineral_hash[hash] = {x = x, y = y, w = w, h = h, mineral = mineral}

        for i = 0, w - 1 do
            for j = 0, h - 1 do
                mineral_cache[icoord.pack(x + i, y + j)] = hash
            end
        end

        local srt = {r = ROTATORS[math.random(1, 4)], t = icoord.position(x, y, w, h)}
        igame_object.create {
            prefab = mineral_model,
            group_id = igroup.id(x, y),
            srt = srt,
            render_layer = RENDER_LAYER.MINERAL
        }
    end
end

function m.get(x, y)
    local hash = mineral_cache[icoord.pack(x, y)]
    if not hash then
        return
    end
    local m = assert(mineral_hash[hash])
    return m, hash
end

function m.can_place(x, y, w, h)
    local mid_x, mid_y = x + w // 2, y + h // 2
    local hash = mineral_cache[icoord.pack(mid_x, mid_y)]
    local m = mineral_hash[hash]
    if not m then
        return false
    end
    if mid_x ~= m.x + m.w // 2 or mid_y ~= m.y + m.h // 2 then
        return false
    end
    return true, m.mineral
end

function m.source()
    return mineral_source
end

return m