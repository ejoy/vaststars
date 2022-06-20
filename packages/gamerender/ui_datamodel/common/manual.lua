local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local imanual = require "gameplay.interface.manual"

local STATUS_IDLE <const> = 0

local function get_progress(recipe_typeobject)
    for v in gameplay_core.select "manual:in" do
        local manual = v.manual
        if manual.status == STATUS_IDLE then
            return 0
        end
        local total = recipe_typeobject.time * 100
        return itypes.progress(manual.progress, total)
    end
end

local function get_count(s)
    for _, v in ipairs(itypes.items(s)) do
        if iprototype.is_fluid_id(v.id) then -- 有流体的配方不允许手搓
            assert(false)
            return
        end
        return v.count
    end
    assert(false)
end

local function get_queue(top)
    local queue = {}
    for _, v in ipairs(gameplay_core.get_world():manual()) do
        if v[1] == "crafting" then
            local recipe_typeobject = iprototype.queryByName("recipe", v[2])
            local progress = "0"
            if #queue == 0 then
                progress = get_progress(recipe_typeobject)
            end
            queue[#queue+1] = {name = v[2], count = get_count(recipe_typeobject.results), icon = recipe_typeobject.icon, progress = progress}

            if top then
                if #queue >= top then
                    break
                end
            end
        end
    end
    return queue
end

local solver = imanual.create()

local function cancel(index)
    local queue = {}
    for _, v in ipairs(gameplay_core.get_world():manual()) do
        if v[1] == "crafting" then
            local recipe_typeobject = iprototype.queryByName("recipe", v[2])
            queue[#queue+1] = {v[2], get_count(recipe_typeobject.results)}
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
