local ecs = ...
local world = ecs.world
local w = world.w

local create_vsobject = ecs.require "vsobject"

local M = {}
local vsobjects = {}

function M:create(init)
    local vsobject = create_vsobject(init)
    vsobjects[vsobject.id] = vsobject
    return vsobject
end

function M:remove(vsobject_id)
    local vsobject = assert(vsobjects[vsobject_id])
    vsobject:remove()
    vsobjects[vsobject_id] = nil
end

function M:get(id)
    return vsobjects[id]
end

return M