local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local gameplay_core = require "gameplay.core"
local ichest = require "gameplay.interface.chest"

local add_req_mb = mailbox:sub {"add_req"}
local LORRY_CAPACITY <const> = 10
local INVALID_LORRY_ID <const> = 0xffff

local function __get_req_count(e)
    local req_count = 0
    for _, slot in pairs(ichest.collect_item(gameplay_core.get_world(), e)) do
        if slot.lock_space ~= 0 then
            req_count = req_count + slot.lock_space
        end
    end
    return req_count
end

local function __get_lorry_count(e)
    local lorry_count = 0
    for i = 1, LORRY_CAPACITY do
        if e.station["lorry" .. i] ~= INVALID_LORRY_ID then
            lorry_count = lorry_count + 1
        end
    end
    return lorry_count
end

local M = {}
function M:create(object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))

    return {
        lorry_count = __get_lorry_count(e),
        req_count = __get_req_count(e),
    }
end

function M:stage_ui_update(datamodel, object_id)
    local object = assert(objects:get(object_id))
    local e = gameplay_core.get_entity(assert(object.gameplay_eid))

    for _ in add_req_mb:unpack() do
        for i = 1, LORRY_CAPACITY do
            if e.station["lorry" .. i] == INVALID_LORRY_ID then
                ichest.add_req(gameplay_core.get_world(), e, "运输车辆I", 1) -- TODO: remove hardcode
                datamodel.req_count = __get_req_count(e)
                break
            end
        end
    end
end

return M