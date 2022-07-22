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
    local function calc(State)
        if State.last == "separator" then
            local typeobject = iprototype.queryByName("recipe", State.recipe_name)
            local main_output = assert(irecipe.get_elements(typeobject.results))[1]

            State.queue[#State.queue+1] = {
                name = main_output.name,
                icon = main_output.icon,
                count = State.count,
                progress = itypes.progress(State.progress, State.total_progress) * 100
            }
            State.manual_queue[#State.manual_queue+1] = {State.recipe_name, State.count}

            State.total_progress = 0
            State.count = 0
            State.recipe_name = ""

            State.progress = 0
        end
    end
    local funcs = {
        finish = function (State)
        end,
        separator = function (State, recipe_name)
            local typeobject = iprototype.queryByName("recipe", recipe_name)
            local main_output = assert(irecipe.get_elements(typeobject.results))[1]
            --
            State.count = State.count + main_output.count

            if State.recipe_name == "" then
                State.recipe_name = recipe_name
            else
                assert(State.recipe_name == recipe_name)
            end
        end,
        crafting = function (State, recipe_name)
            local typeobject = iprototype.queryByName("recipe", recipe_name)
            calc(State)

            --
            if State.last == "" then
                State.progress = State.progress + _get_manual_progress()
            else
                State.progress = State.progress + typeobject.time * 100
            end
            State.total_progress = State.total_progress + typeobject.time * 100
        end
    }

    local queue = gameplay_core.get_world():manual()
    local State = {
        queue = {}, -- {name = xx, icon = xx, count = xx, progress = xx} -- for display on main UI
        manual_queue = {}, -- {name = xx, count = xx} -- for world:manual()
        progress = 0, -- progress of current manual craft, reset after change to "crafting"
        total_progress = 0, -- total progress of current manual craft, reset after change to "crafting"
        count = 0, -- count of current manual craft, reset after change to "crafting"
        recipe_name = "", -- recipe_name of current manual craft, reset after change to "crafting"
        last = "",
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
    calc(State)

    return State
end

local solver = imanual.create()

local function get_queue(top)
    return _get_manual_state(top).queue
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
    get_queue = get_queue,
    cancel = cancel,
}
