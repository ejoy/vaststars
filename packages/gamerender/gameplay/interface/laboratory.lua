local iprototype = require "gameplay.interface.prototype"
local iworld = require "gameplay.interface.world"
local irecipe = require "gameplay.interface.recipe"

local M = {}

local function get_elements(s)
    local r = {}
    for idx = 2, #s // 2 do
        local id = string.unpack("<I2", s, 2 * idx - 1)
        local typeobject = assert(iprototype.queryById(id), ("can not found id `%s`"):format(id))
        r[#r+1] = {id = id, name = typeobject.name, icon = typeobject.icon, tech_icon = typeobject.tech_icon, stack = typeobject.stack}
    end
    return r
end

function M:get_elements(s)
    return get_elements(s)
end

-- 原料添加
function M:place_material(world, e)
    if not e.laboratory then
        log.error("not laboratory")
        return
    end

    local tech = e.laboratory.tech
    if tech == 0 then
        log.info("not tech")
        return
    end

    local tech_typeobject = iprototype.queryById(tech)
    if iprototype.has_type(tech_typeobject.type, "task") then
        log.info("task")
        return
    end

    local tech_ingredients = irecipe.get_elements(tech_typeobject.ingredients)
    local laboratory_item_counts = {}
    for i, v in ipairs(tech_ingredients) do
        local c, n = iworld.chest_get(world, e.chest.id, i)
        if c then
            local count = v.count
            if n < count then
                laboratory_item_counts[c] = count - n
            end
        else
            laboratory_item_counts[v.id] = v.count
        end
    end

    if not next(laboratory_item_counts) then
        log.error("no material place")
        return
    end

    local headquater_item_counts = iworld.base_chest(world)
    for id, count in pairs(laboratory_item_counts) do
        if headquater_item_counts[id] then
            local c = math.min(headquater_item_counts[id], count)
            if c > 0 then
                iworld.base_chest_pickup_place(world, e.chest.id, id, c, true)
            end
        end
    end
    world:build()
end

return M