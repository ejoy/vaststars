local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"

--[[
custom_type :
1. road_laying, count = x,
    task = {"unknown", 0, 1},
    task_params = {},
    count = xx,
2. lorry_count
    task = {"unknown", 0, 2},
    count = 2,
3. set_recipe, recipe = x,
    task = {"unknown", 0, 3},                          
    task_params = {recipe = "地质科技包1"},
    count = 1,
4. auto_complete_task
    task = {"unknown", 0, 4},
5. set_item
    task = {"unknown", 0, 5},
    task_params = {item = "xx"}
6. click_ui, ui = x,
    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_subscribe", building = ""},

    task = {"unknown", 0, 6},
    task_params = {ui = "item_transfer_unsubscribe", , building = ""},
7. place_item
    task = {"unknown", 0, 7},
    task_params = {building = xx, item = xx, },
    count = xx
8. set_items, 
    task = {"unknown", 0, 8},
    task_params = {items = {"demand|xx", "supply|xx", "transit|xx", ...}}
9. pickup_item
    task = {"unknown", 0, 9},
    task_params = {building = xx, item = xx, }
    count = xx
--]]
local custom_type_mapping = {
    [0] = {s = "undef", check = function() end}, -- TODO
    [1] = {s = "road_laying", check = function(task_params, progress, count) return (progress or 0) + count end},
    [2] = {s = "lorry_count", check = function(task_params)
        local ecs = gameplay_core.get_world().ecs

        local count = 0
        for e in ecs:select "lorry:in" do
            if e.lorry.prototype ~= 0 then
                count = count + 1
            end
        end
        return count
    end, },
    [3] = {s = "set_recipe", check = function(task_params, progress, recipe_name)
        if task_params.recipe == recipe_name then
            return 1
        else
            return 0
        end
    end, },
    [4] = {s = "auto_complete_task", check = function(task_params, progress)
        return 1
    end, },
    [5] = {s = "set_item", check = function(task_params, progress, item_name)
        if task_params.item == item_name then
            return 1
        else
            return 0
        end
    end, },
    [6] = {s = "click_ui", check = function(task_params, progress, ui, building)
        if task_params.ui == ui and task_params.building == building then
            return 1
        else
            return 0
        end
    end, },
    [7] = {s = "place_item", check = function(task_params, progress, building, item, count)
        if task_params.building == building and task_params.item == item and (progress or 0) < count then
            return count
        end
    end, },
    [8] = {s = "set_items", check = function(task_params, progress, items)
        table.sort(items, function(a, b) return a < b end)
        table.sort(task_params.items, function(a, b) return a < b end)
        if table.concat(items) == table.concat(task_params.items) then
            return 1
        else
            return 0
        end
    end, },
    [9] = {s = "pickup_item", check = function(task_params, progress, building, item, count)
        if task_params.building == building and task_params.item == item then
            return (progress or 0) + count
        end
    end, },
}

return function ()
    local mt = {}
    function mt:__index(k)
        self[k] = {}
        return self[k]
    end
    local cache = setmetatable({}, mt)

    local UNKNOWN <const> = 5 -- custom task type, see also register_unit("task", ...)
    for _, typeobject in pairs(iprototype.each_type("task")) do
        local task_type, _, custom_type = string.unpack("<I2I2I2", typeobject.task) -- second param is multiple
        if task_type ~= UNKNOWN then
            goto continue
        end

        local c = custom_type_mapping[custom_type]
        assert(c, "unknown custom_type: " .. custom_type)
        cache[c.s][typeobject.name] = {task_name = typeobject.name, task_params = typeobject.task_params, check = c.check}
        ::continue::
    end

    return cache
end