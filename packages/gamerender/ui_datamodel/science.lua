local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local click_tech_event = mailbox:sub {"click_tech"}
local return_mb = mailbox:sub {"return"}
local M = {}
local first_time = true
local tech_tree = {}
local current_tech
local game_world
function M:create(object_id)
    return {
        techs = {
            items = {},
        },
        current_tech_icon = " ",
        current_tech_desc = " ",
        -- selected_tech = nil,
        -- selected_recipe = nil
    }
end

function M:tick(datamodel, chest_object_id)
    if current_tech then
        if game_world:is_researched(current_tech.name) then
            print("---", current_tech.name, "finish")
        else
            local process = game_world:research_progress(current_tech.name)
            if process then
                print("---process : ", process)
            end
        end
    end
end
local techlist = {}
function M:stage_ui_update(datamodel)
    if first_time then
        datamodel.techs = {
            items = {}
        }
        local items = datamodel.techs.items
        local prototypes = iprototype.all_prototype_name()
        for key, value in pairs(prototypes) do
            if value.type[1] == "tech" then
                local name = string.sub(key, 7)
                tech_tree[name] = {name = name, pretech = {}, posttech = {}, detail = value}
                local idx = #items
                local simple_ingredients = {}
                local ingredients = irecipe:get_elements(value.ingredients)
                for _, ingredient in ipairs(ingredients) do
                    simple_ingredients[#simple_ingredients + 1] = {icon = ingredient.tech_icon, count = ingredient.count}
                end
                local detail = {}
                if value.sign_desc then
                    for _, desc in ipairs(value.sign_desc) do
                        detail[#detail+1] = desc
                    end
                end
                if value.effects and value.effects.unlock_recipe then
                    for _, recipe in ipairs(value.effects.unlock_recipe) do
                        local recipe_detail = prototypes["(recipe)" .. recipe]
                        if recipe_detail then
                            local input = {}
                            ingredients = irecipe:get_elements(recipe_detail.ingredients)
                            for _, ingredient in ipairs(ingredients) do
                                input[#input + 1] = {name = ingredient.name, icon = ingredient.icon, count = ingredient.count}
                            end
                            local output = {}
                            local results = irecipe:get_elements(recipe_detail.results)
                            for _, ingredient in ipairs(results) do
                                output[#output + 1] = {name = ingredient.name, icon = ingredient.icon, count = ingredient.count}
                            end
                            detail[#detail + 1] = {
                                name = recipe,
                                icon = recipe_detail.icon,
                                desc = recipe_detail.description,
                                input = input,
                                output = output
                            }
                        end
                    end
                end
                if #detail > 0 then
                    items[idx + 1] = {
                        index = idx + 1,
                        name = name,
                        icon = value.icon,
                        desc = value.desc or " ",
                        sign_icon = value.sign_icon,
                        detail = detail,
                        ingredients = simple_ingredients,
                        progress = 50,
                    }
                end
            end
        end
        
        for _, tnode in pairs(tech_tree) do
            local prenames = tnode.detail.prerequisites
            if prenames then
                for _, name in ipairs(prenames) do
                    local pre = tech_tree[name]
                    if not pre then
                        print("Error Cann't found tech: ", name)
                    else
                        tnode.pretech[#tnode.pretech + 1] = pre
                        pre.posttech[#pre.posttech + 1] = tnode
                    end
                end
            else
                current_tech = tnode
                techlist[#techlist + 1] = current_tech
                if not game_world then
                    game_world = gameplay_core.get_world()
                end
                --game_world:research_queue {current_tech.name}
            end
        end
        local tech = datamodel.techs.items[1]
        datamodel.current_tech_desc = tech.desc
        datamodel.current_tech_icon = tech.icon
        datamodel.current_tech = tech
        first_time = false
    end
    for _, _, _, index in click_tech_event:unpack() do
        local tech = datamodel.techs.items[index]
        datamodel.current_tech = tech
        datamodel.current_tech_desc = tech.desc
        datamodel.current_tech_icon = tech.icon
    end
    for _, _, _ in return_mb:unpack() do
        print("click return")
    end
end

return M