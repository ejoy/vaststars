local global = require "global"
local iprototype = require "gameplay.interface.prototype"

local M = {}

function M.update_tech_tree()
    if global.science.tech_tree then
        return
    end
    local tech_tree = {}
    local prototypes = iprototype.all_prototype_name()
    for key, value in pairs(prototypes) do
        if value.type[1] == "tech" then
            local name = string.sub(key, 7)
            tech_tree[name] = {name = name, pretech = {}, posttech = {}, detail = value, task = value.task and true or false }
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
        end
    end
    global.science.tech_tree = tech_tree
end
function M.update_tech_list(gw)
    if not global.science.tech_tree then
        M.update_tech_tree()
    end
    local tech_tree = global.science.tech_tree
    local techlist = {}
    for _, tnode in pairs(tech_tree) do
        local prenames = tnode.detail.prerequisites
        local can_research = true
        if prenames then
            for _, name in ipairs(prenames) do
                local pre = tech_tree[name]
                if pre then
                    if can_research and not gw:is_researched(pre.name) then
                        can_research = false
                    end
                end
            end
        end
        if can_research and not gw:is_researched(tnode.name) then
            techlist[#techlist + 1] = tnode
        end
    end
    global.science.tech_list = techlist
end
return M