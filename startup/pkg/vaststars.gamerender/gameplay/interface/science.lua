local gameplay_core = require "gameplay.core"
local global = require "global"

local M = {}

local function comp_tech(a, b)
    return a.detail.name < b.detail.name
end

function M.update_tech_list(gw)
    assert(global.science.tech_tree)

    local storage = gameplay_core.get_storage()
    storage.tech_picked_flag = storage.tech_picked_flag or {}
    global.science.tech_picked_flag = storage.tech_picked_flag

    local tech_tree = global.science.tech_tree
    local techlist = {}
    local tech_flags = {}
    local finishlist = {}
    local finish_flags = {}
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
        if gw:is_researched(tnode.name) and not finish_flags[tnode.name] then
            finish_flags[tnode.name] = true
            finishlist[#finishlist + 1] = tnode
            if global.science.tech_picked_flag[tnode.detail.name] == nil then
                global.science.tech_picked_flag[tnode.detail.name] = false
            end
        else
            if can_research and not tech_flags[tnode.name] then
                tech_flags[tnode.name] = true
                techlist[#techlist + 1] = tnode
                if global.science.tech_picked_flag[tnode.detail.name] == nil then
                    global.science.tech_picked_flag[tnode.detail.name] = true
                end
            end
        end
    end
    table.sort(techlist, comp_tech)
    -- table.sort(finishlist, comp_tech)
    global.science.tech_list = techlist
    global.science.finish_list = finishlist
end
return M