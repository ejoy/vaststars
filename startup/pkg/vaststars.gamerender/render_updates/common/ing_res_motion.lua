local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"

local shelf_matrices = require "render_updates.common.shelf_matrices"
local get_shelf_matrices = shelf_matrices.get_shelf_matrices
local get_heap_matrices = shelf_matrices.get_heap_matrices
local iprototype = require "gameplay.interface.prototype"
local iing_res_motion = ecs.import.interface "vaststars.gamerender|iing_res_motion"

local mt = {}
mt.__index = mt

function mt:update(idx, item, count)
    self._counts[idx] = self._counts[idx] or 0
    if self._counts[idx] == count then
        return
    end

    local m = assert(self._motions[idx])
    if m.type == "in" then
        if self._counts[idx] > count then
            iing_res_motion.create(m.model, m.from, m.to, 1.0, self._counts[idx] - count)
        end
    else
        if self._counts[idx] < count then
            iing_res_motion.create(m.model, m.from, m.to, 1.0, count - self._counts[idx])
        end
    end
    self._counts[idx] = count
end

function mt:remove()
    self._motions = {}
end

function mt:on_position_change(building_srt)
    local typeobject_recipe = iprototype.queryById(self._recipe)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
    local results_n <const> = #typeobject_recipe.results//4 - 1

    local shelf_matrices = get_shelf_matrices(self._building, self._recipe, math3d.matrix(building_srt))
    local heap_matrices = get_heap_matrices(self._recipe, shelf_matrices)

    self._counts = {}
    self._motions = {}
    for i = 1, ingredients_n do
        local idx = i
        local id = string.unpack("<I2I2", typeobject_recipe.ingredients, 4*i+1)
        local typeobject_item = iprototype.queryById(id)
        if iprototype.has_type(typeobject_item.type, "item") then
            assert(heap_matrices[idx])
            local _, _, t = math3d.srt(heap_matrices[idx])
            local to = math3d.ref(math3d.set_index(building_srt.t, 2, 10))
            self._motions[idx] = {
                model = "/pkg/vaststars.resources/" .. typeobject_item.pile_model,
                from = math3d.ref(t),
                to = to,
                type = "in",
            }
        end
    end
    for i = 1, results_n do
        local idx = i + ingredients_n
        local id = string.unpack("<I2I2", typeobject_recipe.results, 4*i+1)
        local typeobject_item = iprototype.queryById(id)
        if iprototype.has_type(typeobject_item.type, "item") then
            assert(heap_matrices[idx])
            local _, _, t = math3d.srt(heap_matrices[idx])
            local from = math3d.ref(math3d.set_index(building_srt.t, 2, 10))
            self._motions[idx] = {
                model = "/pkg/vaststars.resources/" .. typeobject_item.pile_model,
                from = from,
                to = math3d.ref(t),
                type = "out",
            }
        end
    end

end

local m = {}
function m.create(building, recipe, building_srt)
    local self = setmetatable({}, mt)
    self._recipe = recipe
    self._building = building
    self:on_position_change(building_srt)

    return self
end
return m