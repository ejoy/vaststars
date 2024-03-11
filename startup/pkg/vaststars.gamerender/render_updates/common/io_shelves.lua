local ecs = ...
local world = ecs.world
local w = world.w

local PREFABS <const> = {
    ["in"]  = "/pkg/vaststars.resources/glbs/belt/belt.gltf|input.prefab",
    ["out"] = "/pkg/vaststars.resources/glbs/belt/belt.gltf|output.prefab",
}
local BUILDING_IO_SLOTS <const> = ecs.require "vaststars.prototype|building_io_slots"

local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local iom = ecs.require "ant.objcontroller|obj_motion"
local igroup = ecs.require "group"
local igame_object = ecs.require "engine.game_object"
local imessage = ecs.require "message_sub"

local mt = {}
mt.__index = mt

local function create_item(group_id, item, amount)
    local typeobject_item = iprototype.queryById(item)
    local _ = typeobject_item.item_model or error(("no pile model: %s"):format(typeobject_item.name))
    local prefab = typeobject_item.item_model
    return igame_object.create {
        prefab = prefab,
        group_id = group_id,
        on_ready = function (self)
            if amount <= 0 then
                imessage:pub("show", self, false)
            end
        end
    }
end

local function create_shelf(self, gameplay_world, e, game_object, shelf_prefab, shelf_slot_name, idx)
    local group_id = igroup.id(e.building.x, e.building.y)
    local slot = assert(ichest.get(gameplay_world, e.chest, idx))
    assert(slot.item ~= 0)
    local typeobject_item = iprototype.queryById(slot.item)
    if iprototype.has_type(typeobject_item.type, "item") then
        local shelf = igame_object.create {
            prefab = shelf_prefab,
            group_id = group_id,
        }

        game_object:send("hitch_instance|attach", shelf_slot_name, shelf.hitch_instance)
        self._shelves[idx] = shelf

        local item = create_item(group_id, slot.item, slot.amount)
        shelf:send("hitch_instance|attach", "item_slot", item.hitch_instance)

        self._items[idx] = item
        self._item_shows[idx] = slot.amount > 0
    end
end

function mt:get_recipe()
    return self._recipe
end

function mt:get_item_position(idx)
    local item = self._items[idx]
    if not item then
        return
    end
    local _, _, t = math3d.srt(iom.worldmat(world:entity(item.hitch_instance.tag["*"][1])))
    return t
end

--
function mt:remove()
    for _, o in pairs(self._items) do
        o:remove()
    end
    self._items = {}
    for _, o in pairs(self._shelves) do
        o:remove()
    end
    self._shelves = {}
    self._item_shows = {}
end

local function _get_item_idxs(begin, s)
    local t = {}
    local idx = 0

    for i = 2, #s // 4 do
        local id = string.unpack("<I2I2", s, 4 * i - 3)
        idx = idx + 1
        if not iprototype.is_fluid_id(id) then
            t[#t+1] = begin + idx
        end
    end
    return t
end

local function rebuild(self, gameplay_world, e, game_object)
    local typeobject_recipe = iprototype.queryById(e.assembling.recipe)
    local ingredients_idxs <const> = _get_item_idxs(0, typeobject_recipe.ingredients)
    local results_idxs <const> = _get_item_idxs(#typeobject_recipe.ingredients//4 - 1, typeobject_recipe.results)
    local key = ("%s%s"):format(#ingredients_idxs, #results_idxs)
    local cfg = BUILDING_IO_SLOTS[key] or error("BUILDING_IO_SLOTS[" .. key .. "] not found")

    for i, idx in ipairs(ingredients_idxs) do
        create_shelf(self, gameplay_world, e, game_object, PREFABS["in"], "shelf".. cfg.in_slots[i], idx)
    end

    for i, idx in ipairs(results_idxs) do
        create_shelf(self, gameplay_world, e, game_object, PREFABS["out"], "shelf".. cfg.out_slots[i], idx)
    end
end

function mt:on_position_change(building_srt, dir, gameplay_world, e, game_object)
    self:remove()
    rebuild(self, gameplay_world, e, game_object)
end

function mt:update_item(idx, amount)
    assert(self._items[idx])
    assert(self._item_shows[idx] ~= nil)

    local show = amount > 0
    if self._item_shows[idx] ~= show then
        imessage:pub("show", self._items[idx].hitch_instance, show)
        self._item_shows[idx] = show
    end
end

function mt:update(gameplay_world, e, game_object)
    if self._recipe ~= e.assembling.recipe then
        self:remove()
        self._recipe = e.assembling.recipe
        rebuild(self, gameplay_world, e, game_object)
    end
end

local m = {}
function m.create(gameplay_world, e, game_object)
    local self = setmetatable({}, mt)
    self._recipe = e.assembling.recipe
    self._shelves = {}
    self._items = {}
    self._item_shows = {}

    rebuild(self, gameplay_world, e, game_object)
    return self
end
return m