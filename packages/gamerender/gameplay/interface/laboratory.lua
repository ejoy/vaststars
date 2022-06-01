local iprototype = require "gameplay.interface.prototype"
local iworld = require "gameplay.interface.world"
local ichest = require "gameplay.interface.chest"
local irecipe = require "gameplay.interface.recipe"

local M = {}

local function get_elements(s)
    local r = {}
    for idx = 2, #s // 2 do
        local id = string.unpack("<I2", s, 2 * idx - 1)
        local typeobject = assert(iprototype:query(id), ("can not found id `%s`"):format(id))
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

    local headquater_e = iworld:get_headquater_entity(world)
    if not headquater_e then
        log.error("no headquater")
        return
    end

    local tech_typeobject = iprototype:query(tech)
    if iprototype:has_type(tech_typeobject.type, "task") then
        log.info("task")
        return
    end

    local tech_ingredients = irecipe:get_elements(tech_typeobject.ingredients)
    local laboratory_item_counts = {}
    for i, v in ipairs(tech_ingredients) do
        local c, n = world:container_get(e.laboratory.container, i)
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

    local headquater_item_counts = ichest:item_counts(world, headquater_e)
    for id, count in pairs(laboratory_item_counts) do
        if headquater_item_counts[id] then
            local c = math.min(headquater_item_counts[id], count)
            if c > 0 then
                if not world:container_pickup(headquater_e.chest.container, id, c) then
                    log.error(("failed to pickup `%s` `%s`"):format(id, c))
                else
                    if not world:container_place(e.assembling.container, id, c) then
                        log.error(("failed to place `%s` `%s`"):format(id, c))
                    end
                end
            end
        end
    end
    world:build()
end

return M