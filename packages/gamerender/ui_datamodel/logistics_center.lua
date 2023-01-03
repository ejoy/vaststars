local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"

local add_req_mb = mailbox:sub {"add_req"}
local LORRY_CAPACITY <const> = 10

local function __get_req_count(e)
    local req_count = 0
    for _, slot in pairs(ichest.collect_item(gameplay_core.get_world(), e)) do
        if slot.lock_space ~= 0 then
            req_count = req_count + slot.lock_space
        end
    end
    return req_count
end

local M = {}
function M:create(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))

    return {
        lorry_count = e.station.lorry_count,
        req_count = __get_req_count(e),
    }
end

function M:stage_ui_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))

    for _ in add_req_mb:unpack() do
        if e.station.lorry_count + 1 > LORRY_CAPACITY then
            goto continue
        end
        e.station.lorry_count = e.station.lorry_count + 1
        ichest.add_req(gameplay_core.get_world(), e, "运输车辆I", 1) -- TODO: remove hardcode

        datamodel.lorry_count = e.station.lorry_count
        datamodel.req_count = __get_req_count(e)
        ::continue::
    end
end

return M