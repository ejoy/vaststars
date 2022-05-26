local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local click_tech_event = mailbox:sub {"click_tech"}
local return_mb = mailbox:sub {"return"}
local switch_mb = mailbox:sub {"switch"}
local M = {}
local first_time = true
local tech_tree = {}
local current_tech
local game_world
local techlist = {}
function M:create(object_id)
    local items = {}
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
                    running = false
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
    return {
        techs = {
            items = items,
        },
        current_tech = items[1],
        current_desc = items[1].desc,
        current_icon = items[1].icon,
        current_running = items[1].running,
        current_lefttime = "12h21m23s",
        current_button_str = items[1].running and "停止" or "开始"
    }
end

function M:tick(datamodel, chest_object_id)
    
end

function M:stage_ui_update(datamodel)
    local function set_current_tech(tech)
        if datamodel.current_tech == tech then
            return
        end
        datamodel.current_tech = tech
        datamodel.current_desc = tech.desc
        datamodel.current_icon = tech.icon
        datamodel.current_running = tech.running
        datamodel.current_lefttime = "12h21m23s"
        datamodel.current_button_str = tech.running and "停止" or "开始"
    end
    
    for _, _, _, index in click_tech_event:unpack() do
        set_current_tech(datamodel.techs.items[index])
    end
    for _, _, _ in switch_mb:unpack() do
        datamodel.current_tech.running = not datamodel.current_tech.running
        print("datamodel.current_tech.running : ", datamodel.current_tech.running)
        datamodel.current_running = datamodel.current_tech.running
    end

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

return M