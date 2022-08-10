local gameplay_core = require "gameplay.core"
local iprototype = require "gameplay.interface.prototype"
local itypes = require "gameplay.interface.types"
local imanual = require "gameplay.interface.manual"

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
        if manual.status == STATUS_IDLE then
            return 0
        end
        return manual.progress
    end
end

local function _calc(crafting, mainoutput)
    local result = {}
    local progress = 0
    local current
    local first = true
    for _, v in ipairs(crafting) do
        local name = v[1]
        local time = v[2]

        if first then
            first = false
            progress = progress + _get_manual_progress()
        else
            progress = progress + time * 100
        end

        if name == mainoutput then
            if not current then
                if first then
                    current = _get_manual_progress()
                    first = false
                else
                    current = progress
                end
            end
            progress = 0
        end
        result[name] = (result[name] or 0) + 1
    end
    assert(progress == 0)
    return current, result
end

local function _get_manual_state(top)
    local funcs = {
        finish = function (State)
        end,
        separator = function (State, id)
            State.separator[#State.separator+1] = id

            if #State.separator == 4 then
                local recipe = State.separator[1]
                local recipe_times = State.separator[2]
                local first_total_time = State.separator[3] | State.separator[4] << 16

                local recipe_typeobject = assert(iprototype.queryById(recipe))
                local current, crafting = _calc(State.crafting, recipe_typeobject.name)
                local crafting_times = crafting[recipe_typeobject.name] or 0

                local total_progress = 0
                local progress
                if State.first then
                    if recipe_times == crafting_times then
                        total_progress = first_total_time * 100
                    else
                        total_progress = recipe_typeobject.time * 100
                    end
                    progress = itypes.progress(current or 0, total_progress) * 100
                    State.first = false
                else
                    progress = 0
                end

                State.queue[#State.queue+1] = {
                    name = recipe_typeobject.name,
                    icon = recipe_typeobject.icon,
                    count = crafting_times,
                    progress = progress,
                }

                State.manual_queue[#State.manual_queue+1] = {recipe_typeobject.name, crafting_times}

                State.crafting = {}
                State.separator = {}
            end
        end,
        crafting = function (State, recipe_name)
            local typeobject = iprototype.queryByName("recipe", recipe_name)
            State.crafting[#State.crafting+1] = {recipe_name, typeobject.time}
        end
    }

    local queue = gameplay_core.get_world():manual()
    local State = {
        queue = {}, -- {name = xx, icon = xx, count = xx, progress = xx} -- for display on main UI
        manual_queue = {}, -- {name = xx, count = xx} -- for world:manual()

        separator = {}, -- {recipe_typeobject, manual_crafting_times, manual_crafting_total_progress}, reset after count "separator" 4 times
        crafting = {}, --  = [recipe_name] = times, reset after count "separator" 4 times
        first = true,
    }

    for i = #queue, 1, -1 do
        funcs[queue[i][1]](State, queue[i][2])
        if top then
            if #State.queue >= top then
                break
            end
        end
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
