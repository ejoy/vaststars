local prototype = require "base.prototype"
local container = require "base.container"
local component = require "base.register.component"
local type = require "base.register.type"

component "chest" {
    type = "word",
}

local c = type "chest"
    .slots "number"

function c:ctor(init, pt)
    local id = container.create("chest", pt.slots)
    if init.items then
        for i, item in pairs(init.items) do
            local what = prototype.query("item", item[1])
            container.place(id, what.id, item[2])
        end
    end
    return {
        chest = id
    }
end
