local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"

return function ()
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

    local res = {}
    local function insertTasks(taskName, prerequisites, res)
        res[#res+1] = taskName
        for _, name in ipairs(prerequisites[taskName]) do
            insertTasks(name, prerequisites, res)
        end
    end
    insertTasks(start_tech, prerequisites, res)

    local unlocked_tech = setmetatable({}, mt)
    for _, name in ipairs(res) do
        local typeobject = iprototype.queryByName(name)
        if typeobject.effects and typeobject.effects.unlock_item then
            for _, prototype_name in ipairs(typeobject.effects.unlock_item) do
                unlocked_tech[prototype_name][typeobject.name] = true
            end
        end
    end

    return unlocked_tech
end