local iBuilding = require "interface.building"
local iBackpack = require "interface.backpack"
local iChest = require "interface.chest"
local cChest = require "vaststars.chest.core"
local prototype = require "prototype"

local m = {}

local InvalidChest <const> = 0

local function chest_destroy(world, chest, recycle)
    return cChest.destroy(world._cworld, chest.chest, recycle)
end

function m.set_item(world, e, items)
    local chest_items = {}
    local station_items = {}
    if e.station.chest ~= InvalidChest then
        for i = 1, 256 do
            local slot = cChest.get(world._cworld, e.station.chest, i)
            if not slot then
                break
            end
            if slot.amount > 0 then
                station_items[slot.item] = slot.amount
            end
        end
        chest_destroy(world, e.station, false)
        e.station.chest = InvalidChest
        iBuilding.dirty(world, "station")
    end
    if e.chest.chest ~= InvalidChest then
        for i = 1, 256 do
            local slot = cChest.get(world._cworld, e.station.chest, i)
            if not slot then
                break
            end
            if slot.amount > 0 then
                chest_items[slot.item] = slot.amount
            end
        end
        chest_destroy(world, e.chest, false)
        e.chest.chest = InvalidChest
        iBuilding.dirty(world, "chest")
    end
    if items ~= nil then
        local mark = {}
        local chest_args = {}
        local station_args = {}
        for _, v in ipairs(items) do
            local type, item, limit = v[1], v[2], v[3]
            assert(not mark[item])
            mark[item] = true
            chest_args[#chest_args+1] = {
                type = type == "supply" and "demand" or "supply",
                item = item,
                limit = prototype.queryById(item).station_limit,
                amount = chest_items[item] or 0,
            }
            station_args[#station_args+1] = {
                type = type,
                item = item,
                limit = limit,
                amount = station_items[item] or 0,
            }
            chest_items[item] = nil
            station_items[item] = nil
        end
        e.chest.chest = iChest.create(world, chest_args)
        e.station.chest = iChest.create(world, station_args)
        iBuilding.dirty(world, "chest")
        iBuilding.dirty(world, "station")
    end
    for item, amount in pairs(station_items) do
        local limit = prototype.queryById(item).station_limit
        iBackpack.place(world, item, amount * limit)
    end
    for item, amount in pairs(chest_items) do
        iBackpack.place(world, item, amount)
    end
end

return m
