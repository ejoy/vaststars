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
local techlist = {}
local function update_techlist()
    local game_world = gameplay_core.get_world()
    techlist = {}
    for _, tnode in pairs(tech_tree) do
        local prenames = tnode.detail.prerequisites
        local can_research = true
        if prenames then
            for _, name in ipairs(prenames) do
                local pre = tech_tree[name]
                if not pre then
                    print("Error Cann't found tech: ", name)
                else
                    tnode.pretech[#tnode.pretech + 1] = pre
                    pre.posttech[#pre.posttech + 1] = tnode
                end
                if can_research and not game_world:is_researched(pre.name) then
                    can_research = false
                end
            end
        end
        if can_research and not game_world:is_researched(tnode.name) then
            techlist[#techlist + 1] = tnode
        end
    end
    local prototypes = iprototype.all_prototype_name()
    local function get_display_item(technode)
        local name = technode.name
        local value = technode.detail
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
        local progress = game_world:research_progress(name) or 0
        local queue = game_world:research_queue()
        return {
            name = name,
            icon = value.icon,
            desc = value.desc or " ",
            sign_icon = value.sign_icon,
            detail = detail,
            ingredients = simple_ingredients,
            count = value.count,
            time = value.time,
            task = value.task,
            progress = (progress > 0) and ((progress + 1) * 100 // value.count) or progress,
            running = queue and queue[1] == name or false
        }
    end
    local items = {}
    for _, technode in ipairs(techlist) do
        local di = get_display_item(technode)
        di.index = #items + 1
        items[#items + 1] = di
    end
    return items
end

local function get_button_str(tech)
    return (tech.running and "停止" or "开始") .. (tech.task and "任务" or "研究")
end

function M:create(object_id)
    local prototypes = iprototype.all_prototype_name()
    for key, value in pairs(prototypes) do
        if value.type[1] == "tech" then
            local name = string.sub(key, 7)
            tech_tree[name] = {name = name, pretech = {}, posttech = {}, detail = value, task = value.task and true or false }
        end
    end
    local items = update_techlist()
    current_tech = items[1]
    return {
        techitems = items,
        current_tech = current_tech,
        current_desc = current_tech.desc,
        current_icon = current_tech.icon,
        current_running = current_tech.running,
        current_button_str = get_button_str(current_tech)
    }
end

function M:tick(datamodel, chest_object_id)
    
end

function M:stage_ui_update(datamodel)
    local function set_current_tech(tech)
        if current_tech == tech then
            return
        end
        current_tech = tech
        datamodel.current_tech = tech
        datamodel.current_desc = tech.desc
        datamodel.current_icon = tech.icon
        datamodel.current_running = tech.running
        datamodel.current_button_str = get_button_str(tech)
    end
    
    local game_world = gameplay_core.get_world()

    for _, _, _, index in click_tech_event:unpack() do
        set_current_tech(datamodel.techitems[index])
    end

    for _, _, _ in switch_mb:unpack() do
        current_tech.running = not current_tech.running
        if current_tech.running then
            game_world:research_queue {current_tech.name}
            print("开始研究：", current_tech.name)
        else
            game_world:research_queue {}
            print("停止研究：", current_tech.name)
        end
        datamodel.current_running = current_tech.running
        datamodel.current_progress = current_tech.progress
        datamodel.current_button_str = get_button_str(current_tech)
    end
    if current_tech and not current_tech.finished then
        if game_world:is_researched(current_tech.name) then
            print("----研究完成：", current_tech.name)
            current_tech.finished = true
            local items = update_techlist()
            if #items > 0 then 
                set_current_tech(items[1])
            end
            datamodel.techitems = items
        else
            local progress = game_world:research_progress(current_tech.name)
            if progress then
                current_tech.progress = (progress + 1) * 100 // current_tech.count
                datamodel.current_progress = progress
                print(current_tech.name, " 进度 ", progress)
            end
        end
    end
end

return M