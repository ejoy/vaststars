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

function M:remove(object_id)
    local vsobject = vsobjects[object_id]
    if not vsobject then
        return
    end
    vsobject:remove()
    vsobjects[object_id] = nil
    print(("vsobject_manager:remove id(%s)"):format(object_id))
end

function M:get(id)
    return vsobjects[id]
end

return M