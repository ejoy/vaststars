local tracedoc = require "utility.tracedoc"

local mt = {}
mt.__index = mt

function mt:put(prototype_name, id)
    self.__queue[prototype_name] = self.__queue[prototype_name] or {}
    table.insert(self.__queue[prototype_name], id)
end

function mt:pop(prototype_name)
    local queue = self.__queue[prototype_name]
    if not queue then
        return
    end
    local id = table.remove(queue, 1)
    if #queue == 0 then
        self.__queue[prototype_name] = nil
    end
    return id
end

function mt:remove(prototype_name, id)
    local queue = assert(self.__queue[prototype_name])

    local found = false
    for i, v in ipairs(queue) do
        if v == id then
            table.remove(queue, i)
            found = true
            break
        end
    end

    assert(found, "id not found in queue")
    if #queue == 0 then
        self.__queue[prototype_name] = nil
    end
end

function mt:for_each()
    return pairs(self.__queue)
end

function mt:size(prototype_name)
    local queue = self.__queue[prototype_name]
    if not queue then
        return 0
    end
    return #queue
end

function mt:changed()
    return tracedoc.changed(self.__queue)
end

function mt:commit()
    return tracedoc.commit(self.__queue)
end

return function()
    local M = {}
    M.__queue = tracedoc.new {}

    return setmetatable(M, mt)
end
