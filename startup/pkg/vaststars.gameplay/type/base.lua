local type = require "register.type"

type "item"
    .stack "number"

type "fluid"

type "recipe"
    .ingredients "items"
    .results "items"
    .time "time"

type "tech"
    .ingredients "items"
    .time "time"
    .count "number"

type "road"
type "pipe"
type "pipe_to_ground"

local c = type "task"
    .ingredients "items"
    .task "task"
    .count "number"

function c:init()
    return {
        ingredients = {{"任务", 1}},
        time = 0,
    }
end
