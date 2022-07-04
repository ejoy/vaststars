local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local gameplay_core = require "gameplay.core"
local imanual = require "gameplay.interface.manual"
local manual_add_mb = mailbox:sub {"manual_add"}
local check_material_mb = mailbox:sub {"check_material"}
local imanualcommon = require "ui_datamodel.common.manual"

local recipe_category = import_package "vaststars.prototype"("recipe_category")
local recipe_category_to_group = {}
for _, v in ipairs(recipe_category) do
    for _, category in ipairs(v.category) do
        recipe_category_to_group[category] = v.group
    end
end

local function decode(s)
    local t = {}
    for _, v in ipairs(itypes.items(s)) do
        if iprototype.is_fluid_id(v.id) then -- 有流体的配方不允许手搓
            return
        end
        t[#t+1] = { id = v.id, count = v.count }
    end
    return t
end

local function get_ingredients(ingredients)
    local t = {}
    for _, v in ipairs(ingredients) do
        local typeobject_item = iprototype.queryById(v.id)
        t[#t+1] = {name = typeobject_item.name, icon = typeobject_item.icon, count = v.count}
    end
    return t
end

local manual_recipe = {}
local check = {}
for _, typeobject in pairs(iprototype.each_maintype("recipe")) do
    if typeobject.allow_manual ~= false then
        local ingredients = decode(typeobject.ingredients)
        local results = decode(typeobject.results)
        if ingredients and results and #results > 0 then
            local mainoutputid = assert(results[1]).id
            local typeobject_item = iprototype.queryById(mainoutputid)

            manual_recipe[#manual_recipe+1] = {
                id = typeobject.id,
                name = typeobject.name,
                icon = typeobject.icon,
                category = assert(recipe_category_to_group[typeobject.category]),
                time = itypes.time(typeobject.time),
                ingredients = get_ingredients(ingredients),
                result = get_ingredients(results),
                order = typeobject.order,
            }
            if typeobject.allow_as_intermediate ~= false then
                if check[mainoutputid] then
                    error("duplicate mainoutput: " .. typeobject_item.name)
                end
                check[mainoutputid] = true
            end
        end
    end
end

local solver = imanual.create()

local M = {}
function M:create()
    return {
        recipe_category = recipe_category,
        manual_recipe = manual_recipe,
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _, name, count in manual_add_mb:unpack() do
        local t = gameplay_core.get_world():manual()
        local output = imanual.evaluate(solver, gameplay_core.manual_chest(), gameplay_core.get_world():manual_container(), {{name, count}})
        if not output then
            log.error("material shortages")
        else
            table.move(output, 1, #output, #t + 1, t)
            gameplay_core.get_world():manual(t)
        end
    end

    for _, _, _, name, count in check_material_mb:unpack() do
        local output = imanual.evaluate(solver, gameplay_core.manual_chest(), gameplay_core.get_world():manual_container(), {{name, count}})
        if not output then
            datamodel.material_shortages = true
        else
            datamodel.material_shortages = false
        end
    end
end

return M