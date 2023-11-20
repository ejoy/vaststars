local ecs = ...
local world = ecs.world
local w = world.w

local EMPTY_FUNCTION <const> = function() end
local SOURCE_TYPES <const> = {
    ["supply"] = true,
    ["transit"] = true,
    ["demand"] = true,
}
local DEST_TYPES <const> = {
    ["supply"] = true,
    ["transit"] = true,
    ["demand"] = true,
}

local ichest = require "gameplay.interface.chest"
local iprototype = require "gameplay.interface.prototype"
local iinventory = require "gameplay.interface.inventory"

local source_eid, dest_eid

local function set_source_eid(eid)
    source_eid = eid
end

local function get_source_eid()
    return source_eid
end

local function set_dest_eid(eid)
    dest_eid = eid
end

local function get_slots(gameplay_world, e, slot_types)
    if not e then
        return EMPTY_FUNCTION
    end

    local max_slots = ichest.get_max_slot(iprototype.queryById(e.building.prototype))
    local idx = 0

    return function()
        idx = idx + 1

        if idx > max_slots then
            return nil
        end

        local slot = ichest.get(gameplay_world, e.chest, idx)
        while slot do
            if slot.item ~= 0 and not iprototype.is_fluid_id(slot.item) and slot_types[slot.type] then
                return idx, slot
            else
                idx = idx + 1
                slot = ichest.get(gameplay_world, e.chest, idx)
            end
        end

        return nil
    end
end

local function get_source_slots(gameplay_world)
    if not source_eid then
        return EMPTY_FUNCTION
    end
    local e = gameplay_world.entity[source_eid]
    if not e then
        return EMPTY_FUNCTION
    end
    return get_slots(gameplay_world, e, SOURCE_TYPES)
end

local function get_transfer_info(gameplay_world)
    if not source_eid or not dest_eid or source_eid == dest_eid then
        return {}
    end

    local se = gameplay_world.entity[source_eid]
    local de = gameplay_world.entity[dest_eid]
    if not (se and de and se.chest and de.chest) then
        return {}
    end
    assert(se.chest and de.chest)

    local t = {}
    for idx, slot in get_slots(gameplay_world, se, SOURCE_TYPES) do
        t[slot.item] = t[slot.item] or {}
        t[slot.item][idx] = {limit = slot.limit, amount = slot.amount}
    end

    local r = {}
    if de.base then
        for item, tt in pairs(t) do
            if iinventory.is_valid_item(item) then
                for _, s in pairs(tt) do
                    local c = math.min(iinventory.get_capacity(gameplay_world, item), s.amount)
                    r[item] = math.max(r[item] or 0, c)
                end
            end
        end
    else
        local is_assembling = (de.assembling ~= nil)
        for _, slot in get_slots(gameplay_world, de, DEST_TYPES) do
            local tt = t[slot.item]
            if not tt then
                goto continue
            end

            for _, s in pairs(tt) do
                -- this assumes that the assembler's slot of limit is twice the quantity required by the recipe
                local limit = is_assembling and (s.limit // 2) or slot.limit
                local c = math.min(math.max(limit - slot.amount, 0), s.amount)
                r[slot.item] = math.max(r[slot.item] or 0, c)
                s.amount = s.amount - c
                break
            end
            ::continue::
        end
    end

    return r
end

local function transfer(gameplay_world, func)
    if not source_eid or not dest_eid or source_eid == dest_eid then
        return {}
    end

    local se = gameplay_world.entity[source_eid]
    local de = gameplay_world.entity[dest_eid]
    if not (se and de and se.chest and de.chest) then
        return {}
    end
    assert(se.chest and de.chest)

    local t = {}
    for idx, slot in get_slots(gameplay_world, se, SOURCE_TYPES) do
        t[slot.item] = t[slot.item] or {}
        t[slot.item][idx] = {limit = slot.limit, amount = slot.amount}
    end

    local r = {}
    if de.base then
        for item, tt in pairs(t) do
            for sidx, s in pairs(tt) do
                local c = math.min(iinventory.get_capacity(gameplay_world, item), s.amount)
                if c > 0 then
                    r[#r+1] = {sidx = sidx, amount = c, item = item}
                    ichest.pickup_at(gameplay_world, se, sidx, c)
                    iinventory.place(gameplay_world, item, c)
                    func(item, c)
                end
            end
        end
    else
        local is_assembling = (de.assembling ~= nil)
        for idx, slot in get_slots(gameplay_world, de, DEST_TYPES) do
            local tt = t[slot.item]
            if not tt then
                goto continue
            end

            for sidx, s in pairs(tt) do
                -- this assumes that the assembler's slot of limit is twice the quantity required by the recipe
                local limit = is_assembling and (s.limit // 2) or slot.limit
                local c = math.min(math.max(limit - slot.amount, 0), s.amount)
                if c > 0 then
                    ichest.pickup_at(gameplay_world, se, sidx, c)
                    ichest.place_at(gameplay_world, de, idx, c)
                    func(slot.item, c)
                    s.amount = s.amount - c
                    break
                end
            end
            ::continue::
        end
    end
end

return {
    set_source_eid = set_source_eid,
    get_source_eid = get_source_eid,
    set_dest_eid = set_dest_eid,
    get_source_slots = get_source_slots,
    get_transfer_info = get_transfer_info,
    transfer = transfer,
}