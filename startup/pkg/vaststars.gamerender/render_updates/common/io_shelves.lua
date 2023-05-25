local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local iprototype = require "gameplay.interface.prototype"
local prefab_meshbin = require("engine.prefab_parser").meshbin
local iheapmesh = ecs.import.interface "ant.render|iheapmesh"
local shelf_matrices = require "render_updates.common.shelf_matrices"
local get_shelf_matrices = shelf_matrices.get_shelf_matrices
local get_heap_matrices = shelf_matrices.get_heap_matrices

local PREFABS <const> = {
    ["in"]  = "/pkg/vaststars.resources/prefabs/shelf-input.prefab",
    ["out"] = "/pkg/vaststars.resources/prefabs/shelf-output.prefab",
}
local HEAP_DIM3 <const> = {2, 4, 2}

local mt = {}
mt.__index = mt

local function __create_instance(group_id, prefab, mat)
    local g = ecs.group(group_id)
    ecs.group(group_id):enable "scene_update"
    local prefab_instance = g:create_instance(prefab)
    function prefab_instance:on_ready()
        local e <close> = w:entity(self.tag["*"][1])
        iom.set_srt(e, math3d.srt(mat))
    end
    function prefab_instance:on_message(msg, mat, group_id) -- TODO: group_id
        assert(msg == "on_position_change", "invalid message")
        local e <close> = w:entity(self.tag["*"][1])
        iom.set_srt(e, math3d.srt(mat))
    end
    return world:create_object(prefab_instance)
end

local function __create_shelves(group_id, recipe, shelf_matrices)
    local typeobject_recipe = iprototype.queryById(recipe)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1

    local objects = {}
    for idx, mat in pairs(shelf_matrices) do
        local prefab
        if idx <= ingredients_n then
            prefab = PREFABS["in"]
        else
            prefab = PREFABS["out"]
        end
        objects[idx] = __create_instance(group_id, prefab, mat)
    end
    return objects
end

local heap_events = {}
heap_events["on_position_change"] = function(_, e, mat, group_id) -- TODO: group_id
    iom.set_srt(e, math3d.srt(mat))
end

heap_events["update_count"] = function (ud, e, item, count)
    iheapmesh.update_heap_mesh_number(ud.id, count)
end

local function __create_heap(heap_mat, item, amount)
    local typeobject_item = iprototype.queryById(item)
    assert(typeobject_item.pile_model, ("no pile model: %s"):format(typeobject_item.name))
    local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
    assert(prefab_meshbin(prefab)[1])
    local meshbin = prefab_meshbin(prefab)[1].mesh
    local gap3 = typeobject_item.gap3 and {typeobject_item.gap3:match("([%d%.]+)x([%d%.]*)x([%d%.]*)")} or {0, 0, 0}
    local s, r, t = math3d.srt(heap_mat)

    return ientity_object.create(ecs.create_entity {
        policy = {
            "ant.render|render",
            "ant.general|name",
            "ant.render|heap_mesh",
         },
        data = {
            name = "heap_items",
            scene   = {s = s, r = r, t = t},
            material = "/pkg/ant.resources/materials/pbr_heap.material",
            visible_state = "main_view",
            mesh = meshbin,
            heapmesh = {
                curSideSize = HEAP_DIM3,
                curHeapNum = amount,
                interval = gap3,
            }
        },
    }, heap_events)
end

local function __create_heaps(heap_matrices, items)
    local heaps = {}
    for idx, item in pairs(items) do
        assert(heap_matrices[idx])
        heaps[idx] = __create_heap(heap_matrices[idx], item, 0)
    end
    return heaps
end

local function __get_heap_positions(heap_matrices)
    local positions = {}
    for idx, mat in pairs(heap_matrices) do
        positions[idx] = math3d.ref(math3d.index(mat, 4))
    end
    return positions
end

--
function mt:update_heap_count(idx, item, count)
    assert(self._heaps[idx])
    self._heap_counts[idx] = self._heap_counts[idx] or 0
    if self._heap_counts[idx] ~= count then
        self._heaps[idx]:send("update_count", item, count)
        self._heap_counts[idx] = count
    end
end

function mt:get_recipe()
    return self._recipe
end

function mt:get_heap_position(idx)
    return self._heap_positions[idx]
end

--
function mt:remove()
    self._shelf_matrices = {}
    self._heap_matrices = {}
    self._heap_positions = {}
    self._heap_counts = {}

    for _, o in pairs(self._shelves) do
        o:remove()
    end
    self._shelves = {}
    for _, o in pairs(self._heaps) do
        o:remove()
    end
    self._heaps = {}
end

function mt:on_position_change(building_srt, group_id)
    self._shelf_matrices = get_shelf_matrices(self._building, self._recipe, math3d.matrix(building_srt))
    self._heap_matrices = get_heap_matrices(self._recipe, self._shelf_matrices)
    self._heap_positions = __get_heap_positions(self._heap_matrices)

    for idx, o in pairs(self._shelves) do
        o:send("on_position_change", self._shelf_matrices[idx], group_id)
    end
    for idx, o in pairs(self._heaps) do
        o:send("on_position_change", self._heap_matrices[idx], group_id)
    end
end

local m = {}
function m.create(group_id, building, recipe, building_srt, items)
    local self = setmetatable({}, mt)
    self._building = building
    self._recipe = recipe

    self._shelf_matrices = get_shelf_matrices(self._building, self._recipe, math3d.matrix(building_srt))
    self._heap_matrices = get_heap_matrices(self._recipe, self._shelf_matrices)
    self._heap_positions = __get_heap_positions(self._heap_matrices)

    self._shelves = __create_shelves(group_id, self._recipe, self._shelf_matrices)
    self._heaps = __create_heaps(self._heap_matrices, items)

    self._heap_counts = {}
    return self
end
return m