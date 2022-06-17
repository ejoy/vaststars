local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"

local function decode(s)
    local t = {}
    for _, v in ipairs(itypes.items(s)) do
        if iprototype.is_fluid_id(v.id) then -- 有流体的配方不允许手搓
            return
        end

        local item_typeobject = iprototype.queryById(v.id)
        t[#t+1] = { id = v.id, name = item_typeobject.name, count = v.count }
    end
    return t
end

local function get_main_output(recipe)
    local recipe_typeobject = iprototype.queryById(recipe)
    local results = decode(recipe_typeobject.results)
    return results[1]
end

local M = {}
function M:create()
    local t = {}
    for _, v in ipairs(gameplay_core.get_world():manual()) do
        if v[1] == "finish" then
            t[#t+1] = get_main_output(v[2])
        end
    end

    -- TODO
    local function getter()
        local t = {}
        for _, typeobject in pairs(iprototype.all_prototype_name("item")) do
            t[#t+1] = {name = typeobject.name, count = math.random(1, 5), icon = typeobject.icon, progress = math.random(1, 100)}
            if #t > 10 then
                break
            end
        end
        return t
    end

    return {
        queue = getter(),
        ingredients = getter(),
    }
end

function M:stage_ui_update(datamodel)
end

return M