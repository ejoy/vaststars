local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local gameplay_core = require "gameplay.core"

local M = {}
function M:create(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))

    return {
        lorry_count = 0, -- TODO
        req_count = 0,
    }
end

function M:stage_ui_update(datamodel, object_id)
end

return M