local ecs = ...
local world = ecs.world
local w = world.w

local fs = require "filesystem"
local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local iprototype_cache = {}
local prototype_cache_sys = ecs.system "prototype_cache_system"
local global = require "global"

local cache = {}
local techs = {} -- task_name -> true

function prototype_cache_sys:prototype_prerestore()
    local game_template = gameplay_core.get_storage().game_template
    local start_tech = import_package("vaststars.prototype")(game_template).start_tech

    local mt = {}
    function mt:__index(k)
        local v = {}
        rawset(self, k, v)
        return v
    end

    local prerequisites = setmetatable({}, mt)
    for _, typeobject in pairs(iprototype.each_type "tech") do
        if typeobject.prerequisites then
            for _, name in ipairs(typeobject.prerequisites) do
                table.insert(prerequisites[name], typeobject.name)
            end
        end
    end
    for _, typeobject in pairs(iprototype.each_type "task") do
        if typeobject.prerequisites then
            for _, name in ipairs(typeobject.prerequisites) do
                table.insert(prerequisites[name], typeobject.name)
            end
        end
    end

    techs = {}
    local function insertTasks(taskName, prerequisites, techs)
        if techs[taskName] then
            return
        end
        techs[taskName] = true
        for _, name in ipairs(prerequisites[taskName]) do
            insertTasks(name, prerequisites, techs)
        end
    end
    insertTasks(start_tech, prerequisites, techs)

    ---
    global.science.tech_tree  = {}

    local tech_tree = {}
    for name in pairs(techs) do
        local typeobject = iprototype.queryByName(name)
        tech_tree[typeobject.name] = {name = typeobject.name, pretech = {}, posttech = {}, detail = typeobject, task = false }
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

function prototype_cache_sys:prototype_restore()
    cache = {}

    for file in fs.pairs(fs.path "/pkg/vaststars.gamerender/prototype_cache") do
        local s = file:stem():string()
        cache[s] = assert(ecs.require("prototype_cache." .. s))()
    end
end

function iprototype_cache.get(key)
    return cache[key]
end

function iprototype_cache.get_techs()
    return techs
end

return iprototype_cache
