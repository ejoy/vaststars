local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local gameplay_core = require "gameplay.core"
local manual = require "gameplay.interface.manual"
local manual_add_mb = mailbox:sub {"manual_add"}

local item_category = import_package "vaststars.prototype"("item_category")

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

local manual_items = {}
local check = {}
for _, typeobject in pairs(iprototype.all_prototype_name("recipe")) do
    if typeobject.allow_manual ~= false then
        local ingredients = decode(typeobject.ingredients)
        local results = decode(typeobject.results)
        if ingredients and results and #results > 0 then
            local mainoutputid = assert(results[1]).id
            local typeobject_item = iprototype.queryById(mainoutputid)
            manual_items[#manual_items+1] = {
                id = typeobject_item.id,
                name = typeobject_item.name,
                icon = typeobject_item.icon,
                category = typeobject_item.group,
                time = itypes.time(typeobject.time),
                ingredients = get_ingredients(ingredients),
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
table.sort(manual_items, function(a, b)
    return a.id < b.id
end)

local solver = manual.create()


local M = {}
function M:create()
    return {
        item_category = item_category,
        manual_items = manual_items,
    }
end

function M:stage_ui_update(datamodel)
    for _, _, _, name, count in manual_add_mb:unpack() do
        local t = gameplay_core.get_world():manual()
        local output = manual.evaluate(solver, gameplay_core.manual_chest(), gameplay_core.get_world():manual_container(), {{name, count}})
        if not output then
            log.error("raw material shortages")
        else
            table.move(output, 1, #output, #t + 1, t)
            gameplay_core.get_world():manual(t)
        end
    end
end

return M