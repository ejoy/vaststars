local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local imanual = require "gameplay.interface.manual"

local STATUS_IDLE <const> = 0
local STATUS_REBUILD <const> = 3

local function get_progress(recipe_typeobject)
    for v in gameplay_core.select "manual:in" do
        local manual = v.manual
        if manual.status == STATUS_IDLE or manual.status == STATUS_REBUILD then
            return 0
        end
        local total = recipe_typeobject.time * 100
        return itypes.progress(manual.progress, total)
    end
end

local function get_queue(top)
    local queue = gameplay_core.get_world():manual()
    local result = {}
    local count
    for i = #queue, 1, -1 do
        if queue[i][1] == "finish" then
            count = (count or 0) + 1
        elseif queue[i][1] == "separator" then
            local recipe = queue[i][2]
            local recipe_typeobject = iprototype.queryByName("recipe", recipe)
            local progress = 0
            if #result == 0 then
                progress = get_progress(recipe_typeobject)
            end
            result[#result+1] = {name = recipe, count = count, icon = recipe_typeobject.icon, progress = progress}
            count = nil
        end

        if top then
            if #result >= top then
                break
            end
        end
    end
    return result
end

local solver = imanual.create()

local function cancel(index)
    local queue = {}
    for _, v in ipairs(gameplay_core.get_world():manual()) do
        if v[1] == "crafting" then
            local recipe_typeobject = iprototype.queryByName("recipe", v[2])
            queue[#queue+1] = {v[2], itypes.items(recipe_typeobject.results)[1].count}
        end
    end
    table.remove(queue, index)

    local t = gameplay_core.get_world():manual()
    local output = imanual.evaluate(solver, gameplay_core.manual_chest(), gameplay_core.get_world():manual_container(), queue)
    if not output then
        assert(false)
    else
        gameplay_core.get_world():manual(output)
    end
end

return {
    get_queue = get_queue,
    cancel = cancel,
}
