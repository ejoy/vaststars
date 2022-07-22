local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local imanual = require "gameplay.interface.manual"
local irecipe = require "gameplay.interface.recipe"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1
local STATUS_REBUILD <const> = 3

-- 组装机I + 3

-- no raw materials need to make
--[[
separator 破损组装机
separator 破损组装机
separator 破损组装机
finish 组装机I
crafting 破损组装机
finish 组装机I
crafting 破损组装机
finish 组装机I
crafting 破损组装机
--]]

-- need to make raw materials
--[[
{"石砖", 8},
{"铁板", 4 * 3}, -->> {"铁齿轮", 3}
{"破损组装机", 1},

separator 破损组装机
separator 破损组装机
separator 破损组装机
finish 组装机I
crafting 破损组装机
crafting 铁齿轮
crafting 铁齿轮
--]]
local function _get_manual_progress()
    for v in gameplay_core.select "manual:in" do
        local manual = v.manual
        if manual.status == STATUS_IDLE or manual.status == STATUS_REBUILD then
            return 0
        end
        return manual.progress
    end
end

local function _get_manual_state(top)
    local funcs = {
        finish = function (State)
        end,
        separator = function (State, id)
            State.separator[#State.separator+1] = id

            if #State.separator == 3 then
                local recipe_prototype = assert(iprototype.queryById(State.separator[1]))
                local manual_crafting_times = State.separator[2]
                local total_progress = State.separator[3] * 100
                State.queue[#State.queue+1] = {
                    name = recipe_prototype.name,
                    icon = recipe_prototype.icon,
                    count = manual_crafting_times,
                    progress = itypes.progress(State.progress, total_progress) * 100
                }

                State.manual_queue[#State.manual_queue+1] = {recipe_prototype.name, manual_crafting_times}

                State.separator = {}
                State.progress = 0
            end
        end,
        crafting = function (State, recipe_name)
            local typeobject = iprototype.queryByName("recipe", recipe_name)

            --
            if State.last == "" then
                State.progress = State.progress + _get_manual_progress()
            else
                State.progress = State.progress + typeobject.time * 100
            end
        end
    }

    local queue = gameplay_core.get_world():manual()
    local State = {
        queue = {}, -- {name = xx, icon = xx, count = xx, progress = xx} -- for display on main UI
        manual_queue = {}, -- {name = xx, count = xx} -- for world:manual()

        last = "",
        progress = 0, -- progress of current manual craft, reset after change to "crafting"
        separator = {}, -- {recipe_prototype, manual_crafting_times, manual_crafting_total_progress}
    }

    for i = #queue, 1, -1 do
        funcs[queue[i][1]](State, queue[i][2])
        if top then
            if #State.queue >= top then
                break
            end
        end
        State.last = queue[i][1]
    end
    assert(#State.separator == 0)

    return State
end

local solver = imanual.create()

local function get_queue(top)
    return _get_manual_state(top).queue
end

local function get_manual_queue()
    return _get_manual_state().manual_queue
end

local function cancel(index)
    local queue = _get_manual_state().manual_queue
    if #queue < index then
        return false
    end
    table.remove(queue, index)

    local output = imanual.evaluate(solver, gameplay_core.manual_chest(), gameplay_core.get_world():manual_container(), queue)
    if not output then
        assert(false)
    else
        assert(gameplay_core.get_world():manual(output))
    end
    return true
end

return {
    get_manual_queue = get_manual_queue,
    get_queue = get_queue,
    cancel = cancel,
}
