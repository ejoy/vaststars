local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local iom = ecs.require "ant.objcontroller|obj_motion"
local iprototype = require "gameplay.interface.prototype"
local shelf_matrices = require "render_updates.common.shelf_matrices"
local ivs = ecs.require "ant.render|visible_state"
local get_shelf_matrices = shelf_matrices.get_shelf_matrices
local get_item_matrices = shelf_matrices.get_item_matrices

local PREFABS <const> = {
    ["in"]  = "/pkg/vaststars.resources/glbs/belt.glb|input.prefab",
    ["out"] = "/pkg/vaststars.resources/glbs/belt.glb|output.prefab",
}

local mt = {}
mt.__index = mt

local function __create_shelves(group_id, recipe, shelf_matrices)
    local typeobject_recipe = iprototype.queryById(recipe)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1

    local objects = {}
    for idx, mat in pairs(shelf_matrices) do
        objects[idx] = world:create_instance {
            prefab = (idx <= ingredients_n) and PREFABS["in"] or PREFABS["out"],
            group = group_id,
            on_ready = function (self)
                local root <close> = world:entity(self.tag["*"][1], "scene:in")
                iom.set_srt(root, math3d.srt(math3d.mul(mat, math3d.matrix(root.scene))))
            end,
            on_message = function (self, event, mat, group_id) -- TODO: group_id
                assert(event == "on_position_change", "invalid message")
                local root <close> = world:entity(self.tag["*"][1], "scene:in")
                iom.set_srt(root, math3d.srt(math3d.mul(mat, math3d.matrix(root.scene))))
            end
        }
    end
    return objects
end

local prefabEvents = {}
prefabEvents["on_position_change"] = function (self, mat, group_id)
    local root <close> = world:entity(self.tag["*"][1])
    iom.set_srt(root, math3d.srt(mat))
end
prefabEvents["show"] = function (self, show)
    for _, eid in ipairs(self.tag["*"]) do
        local e <close> = world:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", show)
        end
    end
end

local function __create_item(group_id, item_mat, item, amount)
    local typeobject_item = iprototype.queryById(item)
    assert(typeobject_item.item_model, ("no pile model: %s"):format(typeobject_item.name))
    local prefab = "/pkg/vaststars.resources/" .. typeobject_item.item_model

    local s, r, t = math3d.srt(item_mat)
    return world:create_instance {
        group = group_id,
        prefab = prefab,
        on_message = function (self, event, ...)
            assert(prefabEvents[event], "invalid message")
            prefabEvents[event](self, ...)
        end,
        on_ready = function (self)
            local root <close> = world:entity(self.tag['*'][1])
            iom.set_srt(root, s, r, t)

            if amount <= 0 then
                for _, eid in ipairs(self.tag["*"]) do
                    local e <close> = world:entity(eid, "visible_state?in")
                    if e.visible_state then
                        ivs.set_state(e, "main_view", false)
                    end
                end
            end
        end
    }
end

local function __create_items(group_id, item_matrices, items)
    local t = {}
    local item_shows = {}

    for idx, v in pairs(items) do
        assert(item_matrices[idx])
        t[idx] = __create_item(group_id, item_matrices[idx], v.item, v.amount)
        item_shows[idx] = v.amount > 0
    end
    return t, item_shows
end

local function __get_item_positions(item_matrices)
    local positions = {}
    for idx, mat in pairs(item_matrices) do
        positions[idx] = math3d.ref(math3d.index(mat, 4))
    end
    return positions
end

function mt:get_recipe()
    return self._recipe
end

function mt:get_item_position(idx)
    return self._item_positions[idx]
end

--
function mt:remove()
    self._shelf_matrices = {}
    self._item_matrices = {}
    self._item_positions = {}

    for _, o in pairs(self._shelves) do
        world:remove_instance(o)
    end
    self._shelves = {}
    for _, o in pairs(self._items) do
        world:remove_instance(o)
    end
    self._items = {}
end

function mt:on_position_change(building_srt, group_id)
    self._shelf_matrices = get_shelf_matrices(self._building, self._recipe, math3d.matrix(building_srt))
    self._item_matrices = get_item_matrices(self._recipe, self._shelf_matrices)
    self._item_positions = __get_item_positions(self._item_matrices)

    for idx, o in pairs(self._shelves) do
        world:instance_message(o, "on_position_change", self._shelf_matrices[idx], group_id)
    end
    for idx, o in pairs(self._items) do
        world:instance_message(o, "on_position_change", self._item_matrices[idx], group_id)
    end
end

function mt:update(idx, amount)
    assert(self._items[idx])
    assert(self._item_shows[idx] ~= nil)

    local show = amount > 0
    if self._item_shows[idx] ~= show then
        world:instance_message(self._items[idx], "show", show)
        self._item_shows[idx] = show
    end
end

local m = {}
function m.create(group_id, building, recipe, building_srt, items)
    local self = setmetatable({}, mt)
    self._building = building
    self._recipe = recipe
    self._item_shows = {}

    self._shelf_matrices = get_shelf_matrices(self._building, self._recipe, math3d.matrix(building_srt))
    self._item_matrices = get_item_matrices(self._recipe, self._shelf_matrices)
    self._item_positions = __get_item_positions(self._item_matrices)

    self._shelves = __create_shelves(group_id, self._recipe, self._shelf_matrices)
    self._items, self._item_shows = __create_items(group_id, self._item_matrices, items)

    return self
end
return m