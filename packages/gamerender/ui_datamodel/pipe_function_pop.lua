local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local gameplay_core = require "gameplay.core"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"

local rotate_mb = mailbox:sub {"rotate"}

---------------
local M = {}
function M:create(object_id, left, top)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))
    if not e then
        return
    end
    local typeobject = iprototype.queryByName("entity", object.prototype_name)

    return {
        object_id = object_id,
        left = ("%0.2fvmin"):format(math.max(left - 34, 0)),
        top = ("%0.2fvmin"):format(math.max(top - 34, 0)),
    }
end

function M:stage_ui_update(datamodel)
    --
    for _, _, _, object_id in rotate_mb:unpack() do
    end
end

return M