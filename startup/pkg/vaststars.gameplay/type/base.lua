local type = require "register.type"
local prototype = require "prototype"

type "item"
    .stack "integer"

type "fluid"


type "road"
type "pipe"
type "pipe_to_ground"

local recipe = type "recipe"
    .ingredients "items"
    .results "items"
    .time "time"

function recipe:init(object)
    assert(object.time, "time is empty.")
    return {}
end

local tech = type "tech"
    .ingredients "items"
    .time "time"
    .count "integer"

function tech:init()
    return {
        time = 0
    }
end

local task = type "task"
    .ingredients "items"
    .task "task"
    .count "integer"
    .time "time"

function task:init()
    return {
        ingredients = {{"任务", 1}},
        time = 0,
    }
end

local inventory = type "inventory"
    .chest_type "chest_type"

function inventory:ctor(init, pt)
    local world = self
    local items = {}
    for _, v in ipairs(init.items or {}) do
        items[#items+1] = world:chest_slot {
            type = pt.chest_type,
            item = v[1],
            amount = v[2],
        }
    end

    return {
        inventory = {
            chest = world:container_create(table.concat(items)),
        },
        inventory_changed = true,
    }
end