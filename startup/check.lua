package.path = "/engine/?.lua"
require "bootstrap"
import_package "vaststars.prototype"
local iprototype = import_package "vaststars.gamerender"("gameplay.interface.prototype")

-- Check if there are any duplicates in the ingredients and results of each recipe.
do
    local function check_elements(recipe_name, name, s)
        local r = {}
        for idx = 2, #s // 4 do
            local id = string.unpack("<I2I2", s, 4 * idx - 3)
            local typeobject = assert(iprototype.queryById(id), ("can not found id `%s`"):format(id))
            assert(not r[typeobject.name], ("recipe `%s` has duplicate %s `%s`"):format(recipe_name, name, typeobject.name))
            r[typeobject.name] = true
        end
        return r
    end

    for _, v in pairs(iprototype.each_maintype "recipe") do
        check_elements(v.name, "ingredient", v.ingredients)
        check_elements(v.name, "result", v.results)
    end
end

-- Check if each item has 'group' & 'icon' field
do
    local item_category = import_package "vaststars.prototype"("item_category")
    local function isValidCategory(category)
        for _, v in pairs(item_category) do
            if v.category == category then
                return true
            end
        end
        return false
    end

    for _, typeobject in pairs(iprototype.each_maintype("item")) do
        -- "任务" is a special item that is not subject to any checks.
        if typeobject.name == "任务" then
            goto continue
        end
        if not typeobject.group then
            log.error(typeobject.name .. " item must have group")
        else
            if not isValidCategory(typeobject.group[1]) then
                log.error(typeobject.name .. "|" .. typeobject.group[1] .. " item has invalid category")
            end
        end
        if not typeobject.icon then
            log.error(typeobject.name .. " item must have icon")
        end
        if not typeobject.item_description then
            log.error(typeobject.name .. " item must have item_description")
        end
        ::continue::
    end
end

-- The recipe for building center must meet: 1. Only one result; 2. The result must be a building
do
    local function check_elements(recipe_name, name, s)
        local r = {}
        for idx = 2, #s // 4 do
            local id = string.unpack("<I2I2", s, 4 * idx - 3)
            local typeobject = assert(iprototype.queryById(id), ("can not found id `%s`"):format(id))

            if #r > 1 then
                log.error("recipe `" .. recipe_name .. "` has more than one result (%d)" .. #r)
            end
            r[#r+1] = typeobject.name

            if not iprototype.has_type(typeobject.type, "building") then
                log.error("recipe `" .. recipe_name .. "` has invalid result `" .. typeobject.name .. "`")
            end
        end
        return r
    end

    local function check(category)
        for _, typeobject in pairs(iprototype.each_maintype "recipe") do
            if typeobject.category == category then
                check_elements(typeobject.name, "result", typeobject.results)
            end
        end
    end

    local typeobject = iprototype.queryByName "建造中心"
    local craft_categories = typeobject.craft_category
    for _, v in pairs(craft_categories) do
       check(v)
    end
end

print "ok"
