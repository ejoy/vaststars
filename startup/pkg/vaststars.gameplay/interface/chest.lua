local iBuilding = require "interface.building"
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

local function chest_destroy(world, chest, recycle)
    return cChest.destroy(world._cworld, chest.chest, recycle)
end

function m.create(world, items)
    local t = {}
    for _, item in ipairs(items) do
        t[#t+1] = chest_slot(item)
    end
    return cChest.create(world._cworld, table.concat(t))
end

function m.pickup(world, e, i, n)
    return cChest.pickup(world._cworld, e.chest.chest, i, n)
end

function m.place(world, e, i, n)
    return cChest.place(world._cworld, e.chest.chest, i, n)
end

function m.get(world, c, i)
    return cChest.get(world._cworld, c.chest, i)
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
                limit = prototype.queryById(item).chest_limit,
                amount = chest_items[item] or 0,
            }
            chest_items[item] = nil
        end
        e.chest.chest = m.create(world, chest_args)
        iBuilding.dirty(world, "chest")
    end
end

return m
