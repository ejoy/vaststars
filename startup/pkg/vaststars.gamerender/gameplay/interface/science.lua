local gameplay_core = require "gameplay.core"
local global = require "global"
local iprototype = require "gameplay.interface.prototype"

local M = {}

function M.update_tech_tree()
    if global.science.tech_tree then
        return
    end
    local tech_tree = {}
    for _, typeobject in pairs(iprototype.each_type "tech") do
        tech_tree[typeobject.name] = {name = typeobject.name, pretech = {}, posttech = {}, detail = typeobject, task = false }
    end
    for _, typeobject in pairs(iprototype.each_type "task") do
        tech_tree[typeobject.name] = {name = typeobject.name, pretech = {}, posttech = {}, detail = typeobject, task = true }
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

local function comp_tech(a, b)
    return a.detail.name < b.detail.name
end

function M.update_tech_list(gw)
    if not global.science.tech_tree then
        M.update_tech_tree()
    end

    local storage = gameplay_core.get_storage()
    storage.tech_picked_flag = storage.tech_picked_flag or {}
    global.science.tech_picked_flag = storage.tech_picked_flag

    local tech_tree = global.science.tech_tree
    local techlist = {}
    local finishlist = {}
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
        if gw:is_researched(tnode.name) then
            finishlist[#finishlist + 1] = tnode
            if global.science.tech_picked_flag[tnode.detail.name] == nil then
                global.science.tech_picked_flag[tnode.detail.name] = false
            end
        else
            if can_research then
                techlist[#techlist + 1] = tnode
                if global.science.tech_picked_flag[tnode.detail.name] == nil then
                    global.science.tech_picked_flag[tnode.detail.name] = true
                end
            end
        end
    end
    table.sort(techlist, comp_tech)
    table.sort(finishlist, comp_tech)
    global.science.tech_list = techlist
    global.science.finish_list = finishlist
end
return M