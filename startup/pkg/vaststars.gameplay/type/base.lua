local type = require "register.type"
local prototype = require "prototype"

type "item"
    .stack "integer"

type "fluid"


type "road"
type "pipe"
type "pipe_to_ground"
type "construction_center"
type "construction_chest"

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
