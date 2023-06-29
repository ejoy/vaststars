local type = require "register.type"

type "fluid"

type "pipe"
type "pipe_to_ground"
type "mountain"

local auto_set_recipe = type "auto_set_recipe"
function auto_set_recipe:ctor(init, pt)
    return {
        auto_set_recipe = true,
    }
end

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

function tech:init(object)
    assert(object.ingredients, "ingredients is empty.")
    assert(object.time, "time is empty.")
    assert(object.count, "count is empty.")
    return {}
end

local task = type "task"
    .ingredients "items"
    .task "task"
    .count "integer"
    .time "time"

function task:preinit()
    return {
        ingredients = {{"任务", 1}},
    }
end

function task:init()
    return {
        time = 0,
    }
end

local base = type "base"

function base:ctor(init, pt)
    return {
        base = true,
        base_changed = true,
    }
end
