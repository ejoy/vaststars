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
    none = 0,
    supply = 1,
    demand = 2,
}
local function chest_slot(t)
    assert(t.type)
    assert(t.item)
    local id = t.item
    if type(id) == "string" then
        assert(prototype.queryByName(id), ("item %s not found"):format(id))
        id = prototype.queryByName(id).id
    end
    return string.pack("<I1I1I2I2I2I2I2",
        CHEST_TYPE[t.type],
        0,
        id,
        t.amount or 0,
        t.limit or 2,
        t.lock_item or 0,
        t.lock_space or 0
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

local function chest_dirty(world, e)
    iBuilding.dirty(world, "hub")
    if e.station then
        iBuilding.dirty(world, "station")
    end
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
        chest_dirty(world, e)
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
            amount = o.amount,
            lock_item = type ~= "demand" and o.lock_item or nil,
            lock_space = o.lock_space,
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
    iBuilding.dirty(world, "hub")
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
        chest_destroy(world, e.station.chest, false)
        e.station.chest = InvalidChest
        chest_dirty(world, e)
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
        chest_destroy(world, e.chest.chest, false)
        e.chest.chest = InvalidChest
        chest_dirty(world, e)
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
        chest_dirty(world, e)
    end
    for item, amount in pairs(station_items) do
        local limit = prototype.queryById(item).station_limit
        iBackpack.place(world, item, amount * limit)
    end
    for item, amount in pairs(chest_items) do
        iBackpack.place(world, item, amount)
    end
end

function m.hub_set(world, e, items)
    if e.hub.chest == InvalidChest then
        local info = {}
        for i, item in ipairs(items) do
            info[i] = {
                type = "demand",
                item = item,
                limit = item ~= 0 and prototype.queryById(item).hub_limit or 0,
                amount = 0,
            }
        end
        e.hub.chest = m.create(world, info)
        chest_dirty(world, e)
        return
    end
    for i, item in ipairs(items) do
        local slot = cChest.get(world._cworld, e.hub.chest, i)
        assert(slot and slot.type ~= "none")
        if slot.item == item then
            if item ~= 0 then
                local limit = prototype.queryById(item).hub_limit
                if slot.limit ~= limit then
                    cChest.set(world._cworld, e.hub.chest, i, {
                        limit = limit,
                    })
                end
            end
        else
            if slot.item ~= 0 and slot.amount > 0 then
                iBackpack.place(world, slot.item, slot.amount)
            end
            cChest.set(world._cworld, e.hub.chest, i, {
                item = item,
                limit = item ~= 0 and prototype.queryById(item).hub_limit or 0,
                amount = 0,
            })
        end
    end
    chest_dirty(world, e)
end

function m.get(world, c, i)
    return cChest.get(world._cworld, c.chest, i)
end
function m.set(world, c, i, t)
    return cChest.set(world._cworld, c.chest, i, t)
end

return m
