local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local click_tech_event = mailbox:sub {"click_tech"}
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
                items[idx + 1] = {index = idx + 1, name = name, progress = 50, detail = value}
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
        first_time = false
    end
    for _, _, _, index in click_tech_event:unpack() do
        print("click index : ", index)
    end
end

return M