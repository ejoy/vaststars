local iBuilding = require "interface.building"
local iBackpack = require "interface.backpack"
local cChest = require "vaststars.chest.core"
local prototype = require "prototype"

local m = {}

local InvalidChest <const> = 0

local CHEST_TYPE <const> = {
    [0] = 0,
    [1] = 1,
    [2] = 2,
    [3] = 3,
    none = 0,
    supply = 1,
    demand = 2,
    transit = 3,
}
local function chest_slot(t)
    assert(t.type and t.item and t.amount and t.limit)
    return string.pack("<I1I1I2I2I2I2I2",
        CHEST_TYPE[t.type],
        0,
        t.item,
        t.amount,
        t.limit,
        0, -- lock_item
        0  -- lock_space
    )
end

function m.create(world, items)
    local t = {}
    for _, item in ipairs(items) do
        t[#t+1] = chest_slot(item)
    end
    return cChest.create(world._cworld, table.concat(t))
end

local function chest_destroy(world, chest, recycle)
    return cChest.destroy(world._cworld, chest.chest, recycle)
end

local function assembling_reset(world, e, chest)
    local olditems = {}
    if chest.chest ~= InvalidChest then
        for i = 1, 256 do
            local slot = cChest.get(world._cworld, chest.chest, i)
            if not slot then
                break
            end
            if slot.type ~= "none" then
                assert(not olditems[slot.item])
                olditems[i] = slot
            end
        end
        chest_destroy(world, chest, true)
        chest.chest = InvalidChest
        iBuilding.dirty(world, "chest")
    end
end

local function isFluidId(id)
    local pt = prototype.queryById(id)
    for _, t in ipairs(pt.type) do
        if t == "fluid" then
            return true
        end
    end
    return false
end

local function assembling_reset_items(world, recipe, chest, option, maxslot)
    local ingredients_n <const> = #recipe.ingredients//4 - 1
    local results_n <const> = #recipe.results//4 - 1
    local hash = {}
    local olditems = {}
    local newitems = {}
    if chest.chest ~= InvalidChest then
        for i = 1, 256 do
            local slot = cChest.get(world._cworld, chest.chest, i)
            if not slot then
                break
            end
            if slot.type ~= "none" and slot.amount > 0 then
                iBackpack.place(world, slot.item, slot.amount)
            end
        end
    end
    local count = #olditems
    local function create_slot(type, id, limit)
        local o = {}
        if hash[id] then
            local i = hash[id]
            o = olditems[i]
            olditems[i] = nil
            hash[id] = nil
        end
        newitems[#newitems+1] = {
            type = type,
            item = id,
            limit = limit,
            amount = o.amount or 0,
        }
    end
    for idx = 1, ingredients_n do
        local id, n = string.unpack("<I2I2", recipe.ingredients, 4*idx+1)
        create_slot(isFluidId(id) and "none" or "demand", id, n * option.ingredientsLimit)
    end
    for idx = 1, results_n do
        local id, n = string.unpack("<I2I2", recipe.results, 4*idx+1)
        create_slot(isFluidId(id) and "none" or "supply", id, n * option.resultsLimit)
    end
    for i = count, 1, -1 do
        local v = olditems[i]
        if #newitems > maxslot + ingredients_n then
            if v.amount > 0 then
                iBackpack.place(world, v.item, v.amount)
            end
        else
            if v and v.type == "supply" then
                create_slot(v.type, v.item, v.amount)
            end
        end
    end
    return newitems
end

local function assembling_set(world, e, recipe, option, maxslot)
    local chest = e.chest
    option = option or {
        ingredientsLimit = 2,
        resultsLimit = 2,
    }
    local items = assembling_reset_items(world, recipe, chest, option, maxslot)
    if chest.chest ~= InvalidChest then
        chest_destroy(world, chest, false)
    end
    chest.chest = m.create(world, items)
    iBuilding.dirty(world, "chest")
end

function m.assembling_set(world, e, recipe, option, maxslot)
    if recipe == nil then
        assembling_reset(world, e, e.chest)
        return
    end
    assembling_set(world, e, recipe, option, maxslot)
end

function m.station_set(world, e, items)
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
        local chest_args = {}
        local station_args = {}
        for _, v in ipairs(items) do
            local type, item, limit = v[1], v[2], v[3]
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
        e.chest.chest = m.create(world, chest_args)
        e.station.chest = m.create(world, station_args)
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

function m.chest_set(world, e, items)
    local chest_items = {}
    if e.chest.chest ~= InvalidChest then
        for i = 1, 256 do
            local slot = cChest.get(world._cworld, e.chest.chest, i)
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
        local chest_args = {}
        for _, v in ipairs(items) do
            local type, item = v[1], v[2]
            chest_args[#chest_args+1] = {
                type = type,
                item = item,
                limit = prototype.queryById(item).hub_limit,
                amount = chest_items[item] or 0,
            }
            chest_items[item] = nil
        end
        e.chest.chest = m.create(world, chest_args)
        iBuilding.dirty(world, "chest")
    end
    for item, amount in pairs(chest_items) do
        iBackpack.place(world, item, amount)
    end
end

function m.chest_pickup(world, e, i, n)
    return cChest.pickup(world._cworld, e.chest.chest, i, n)
end

function m.chest_place(world, e, i, n)
    return cChest.place(world._cworld, e.chest.chest, i, n)
end

function m.get(world, c, i)
    return cChest.get(world._cworld, c.chest, i)
end

return m
