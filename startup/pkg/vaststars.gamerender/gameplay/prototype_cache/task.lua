local CONSTANT = require "gameplay.interface.constant"
local ROAD_WIDTH_COUNT <const> = CONSTANT.ROAD_WIDTH_COUNT
local ROAD_HEIGHT_COUNT <const> = CONSTANT.ROAD_HEIGHT_COUNT
local IN_FLUIDBOXES <const> = CONSTANT.IN_FLUIDBOXES

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local icoord = require "coord"

--[[
custom_type :
1. is_road_connected
    task = {"unknown", 0, 1},
    task_params = {
        path = {
            {{117, 125}, {135, 125}},
            ...
        }
    },
    count = 1,
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
7. transfer
    task = {"unknown", 0, 7},
    task_params = {building = "xx", item = "xx", },
    count = xx
8. set_items, 
    task = {"unknown", 0, 8},
    task_params = {items = {"demand|xx", "supply|xx", "transit|xx", ...}}
9. 
10.in_one_power_grid
    task = {"unknown", 0, 10},
    task_params = {building = "xx", }
    count = xx
11.check_fluids_input
    task = {"unknown", 0, 11},
    task_params = {building = "xx", fluids = {"xx", "xx"}}
    count = 1
--]]

local function check_path_connected(sx, sy, dx, dy, road)
    assert(sx == dx or sy == dy)
    local start, stop, step
    if sx == dx then
        start, stop, step = sy, dy, sy < dy and ROAD_HEIGHT_COUNT or -ROAD_HEIGHT_COUNT
        for y = start, stop, step do
            if not road[icoord.pack(sx, y)] then
                return false
            end
        end
    else
        start, stop, step = sx, dx, sx < dx and ROAD_WIDTH_COUNT or -ROAD_WIDTH_COUNT
        for x = start, stop, step do
            if not road[icoord.pack(x, sy)] then
                return false
            end
        end
    end
    return true
end

local custom_type_mapping = {
    [0] = {s = "undef", check = function() end}, -- TODO
    [1] = {s = "is_road_connected", check = function(task_params, progress)
        local cache = {}
        local gameplay_world = gameplay_core.get_world()
        for e in gameplay_world.ecs:select "road building:in eid:in REMOVED:absent" do
            cache[icoord.pack(e.building.x, e.building.y)] = {
                eid = e.eid,
                x = e.building.x,
                y = e.building.y,
                prototype = iprototype.queryById(e.building.prototype).name,
                direction = iprototype.dir_tostring(e.building.direction),
            }
        end

        for _, v in ipairs(task_params.path) do
            if not check_path_connected(v[1][1], v[1][2], v[2][1], v[2][2], cache) then
                return progress
            end
        end
        return 1
    end},
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
    [7] = {s = "transfer", check = function(task_params, progress, building, item, count)
        if task_params.building == building and task_params.item == item then
            return (progress or 0) + count
        end
    end, },
    [8] = {s = "set_items", check = function(task_params, progress, items)
        local t = {}
        for _, item in ipairs(task_params.items) do
            t[item] = (t[item] or 0) + 1
        end

        for k, c in pairs(t) do
            if (items[k] or 0) < c then
                return 0
            end
        end
        return 1
    end, },
    [10] = {s = "in_one_power_grid", check = function(task_params, progress)
        local gameplay_world = gameplay_core.get_world()
        local ecs = gameplay_world.ecs

        local c = 0
        for i = 1, 255 do
            local pg = ecs:object("powergrid", i+1)
            if pg.active == 0 then
                break
            end
            c = c + 1
            if c > 1 then
                return progress
            end
        end

        local count = 0
        for e in ecs:select "building:in capacitance:in road:absent" do
            local typeobject = iprototype.queryById(e.building.prototype)
            if task_params.building == typeobject.name and e.capacitance.network ~= 0 then
                count = count + 1
            end
        end

        return math.max(count, progress or 0)
    end, },
    [11] = {s = "check_fluids_input", check = function(task_params, progress)
        local gameplay_world = gameplay_core.get_world()
        local ecs = gameplay_world.ecs
        local building = task_params.building
        local types = iprototype.queryByName(building).type
        local count = 0

        if iprototype.has_type(types, "fluidboxes") then
            for e in ecs:select "fluidboxes:in building:in" do
                local typeobject = iprototype.queryById(e.building.prototype)
                if building ~= typeobject.name then
                    goto continue
                end

                local t = {}
                for _, v in ipairs(IN_FLUIDBOXES) do
                    local fluid = e.fluidboxes[v.fluid]
                    local id = e.fluidboxes[v.id]
                    if fluid ~= 0 and id ~= 0 then
                        local r = gameplay_core.fluidflow_query(fluid, id)
                        local f = iprototype.queryById(fluid)
                        t[f.name] = r.volume
                    end
                end

                for _, v in ipairs(task_params.fluids) do
                    if t[v] == nil then
                        goto continue
                    end
                    if t[v] <= 0 then
                        goto continue
                    end
                end

                count = count + 1
                ::continue::
            end
        elseif iprototype.has_type(types, "fluidbox") then
            for e in ecs:select "fluidbox:in building:in" do
                local typeobject = iprototype.queryById(e.building.prototype)
                if building ~= typeobject.name then
                    goto continue
                end
                assert(#task_params.fluids == 1)

                if e.fluidbox.fluid == 0 or e.fluidbox.id == 0 then
                    goto continue
                end

                local r = gameplay_core.fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
                local f = iprototype.queryById(e.fluidbox.fluid)
                if task_params.fluids[1] == f.name then
                    if r.volume > 0 then
                        count = count + 1
                    else
                        goto continue
                    end
                end
                ::continue::
            end
        else
            assert(false)
        end
        return count
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
        local task_type, _, custom_type = string.unpack("<I2I2I2", typeobject.task or error(("`%s` missing task parameter"):format(typeobject.name))) -- second param is multiple
        if task_type ~= UNKNOWN then
            goto continue
        end

        local c = custom_type_mapping[custom_type] or error(("task: %s, unknown custom_type: %d"):format(typeobject.name, custom_type))
        cache[c.s][typeobject.name] = {task_name = typeobject.name, task_params = typeobject.task_params, check = c.check}
        ::continue::
    end

    return cache
end