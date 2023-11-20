local ecs = ...
local world = ecs.world
local w = world.w

local PREFABS <const> = {
    ["in"]  = "/pkg/vaststars.resources/glbs/belt.glb|input.prefab",
    ["out"] = "/pkg/vaststars.resources/glbs/belt.glb|output.prefab",
}
local BUILDING_IO_SLOTS <const> = ecs.require "vaststars.prototype|building_io_slots"

local math3d = require "math3d"
local ivs = ecs.require "ant.render|visible_state"
local iprototype = require "gameplay.interface.prototype"
local ichest = require "gameplay.interface.chest"
local iom = ecs.require "ant.objcontroller|obj_motion"
local igroup = ecs.require "group"

local mt = {}
mt.__index = mt

local item_events = {}
item_events["show"] = function (self, show)
    for _, eid in ipairs(self.tag["*"]) do
        local e <close> = world:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", show)
        end
    end
end

local function create_item(group_id, item, amount)
    local typeobject_item = iprototype.queryById(item)
    local _ = typeobject_item.item_model or error(("no pile model: %s"):format(typeobject_item.name))
    local prefab = "/pkg/vaststars.resources/" .. typeobject_item.item_model

    return world:create_instance {
        group = group_id,
        prefab = prefab,
        on_message = function (self, event, ...)
            assert(item_events[event], "invalid message")
            item_events[event](self, ...)
        end,
        on_ready = function (self)
            if amount <= 0 then
                item_events["show"](self, false)
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
        local shelf = world:create_instance {
            prefab = shelf_prefab,
            group = group_id,
            on_message = function(self, msg, slot_name, instance)
                assert(msg == "attach")
                local eid = assert(self.tag[slot_name][1])
                world:instance_set_parent(instance, eid)
            end
        }
        game_object:send("attach", shelf_slot_name, shelf)
        self._shelves[idx] = shelf

        local item = create_item(group_id, slot.item, slot.amount)
        world:instance_message(shelf, "attach", "item_slot", item)
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
    local _, _, t = math3d.srt(iom.worldmat(world:entity(item.tag["*"][1])))
    return t
end

--
function mt:remove()
    for _, o in pairs(self._items) do
        world:remove_instance(o)
    end
    self._items = {}
    for _, o in pairs(self._shelves) do
        world:remove_instance(o)
    end
    self._shelves = {}
    self._item_shows = {}
end

local function rebuild(self, gameplay_world, e, game_object)
    local typeobject_recipe = iprototype.queryById(e.assembling.recipe)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
    local results_n <const> = #typeobject_recipe.results//4 - 1
    local key = ("%s%s"):format(ingredients_n, results_n)
    local cfg = BUILDING_IO_SLOTS[key] or error("BUILDING_IO_SLOTS[" .. key .. "] not found")

    for i = 1, #cfg.in_slots do
        local idx = i
        create_shelf(self, gameplay_world, e, game_object, PREFABS["in"], "shelf".. cfg.in_slots[i], idx)
    end

    for i = 1, #cfg.out_slots do
        local idx = i + ingredients_n
        create_shelf(self, gameplay_world, e, game_object, PREFABS["out"], "shelf".. cfg.out_slots[i], idx)
    end
end

function mt:on_position_change(building_srt, group_id)
    -- TODO: implement this
end

function mt:update_item(idx, amount)
    assert(self._items[idx])
    assert(self._item_shows[idx] ~= nil)

    local show = amount > 0
    if self._item_shows[idx] ~= show then
        world:instance_message(self._items[idx], "show", show)
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