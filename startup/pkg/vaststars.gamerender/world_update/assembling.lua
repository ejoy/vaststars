local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local objects = require "objects"
local buildings = require "global".buildings
local iprototype = require "gameplay.interface.prototype"
local prefab_slots = require("engine.prefab_parser").slots
local prefab_meshbin = require("engine.prefab_parser").meshbin
local iheapmesh = ecs.import.interface "ant.render|iheapmesh"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local building_io_slots = import_package "vaststars.prototype"("building_io_slots")

local HEAP_DIM3 = {2, 4, 2}
local PREFABS = {
    ["in"]  = "/pkg/vaststars.resources/prefabs/shelf-input.prefab",
    ["out"] = "/pkg/vaststars.resources/prefabs/shelf-output.prefab",
}

local function create_heap(meshbin, srt, dim3, gap3, count)
    return ientity_object.create(ecs.create_entity {
        policy = {
            "ant.render|render",
            "ant.general|name",
            "ant.render|heap_mesh",
         },
        data = {
            name = "heap_items",
            scene   = srt,
            material = "/pkg/ant.resources/materials/pbr_heap.material",
            visible_state = "main_view",
            mesh = meshbin,
            heapmesh = {
                curSideSize = dim3,
                curHeapNum = count,
                interval = gap3,
            }
        },
    })
end

local function create_io_shelves(gameplay_world, e, building_srt)
    local typeobject_recipe = iprototype.queryById(e.assembling.recipe)
    local typeobject_building = iprototype.queryById(e.building.prototype)
    local ingredients_n <const> = #typeobject_recipe.ingredients//4 - 1
    local results_n <const> = #typeobject_recipe.results//4 - 1
    local key = ("%s%s"):format(ingredients_n, results_n)
    local cfg = assert(building_io_slots[key])

    if typeobject_building.io_shelf == false then
        return {
            recipe = typeobject_recipe.id,
            update_heap_count = function() end,
            remove = function() end,
        }
    end

    local shelves = {}
    local shelf_offsets = {}
    local heap_offsets = {}
    local heaps = {}
    local io_counts = {}

    local building_slots = prefab_slots("/pkg/vaststars.resources/" .. typeobject_building.model)
    for _, io in ipairs({"in", "out"}) do
        local prefab = PREFABS[io]
        for _, idx in ipairs(cfg[io .. "_slots"]) do
            local prefab_instance = ecs.create_instance(prefab)
            local slots = prefab_slots(prefab)
            assert(building_slots["shelf" .. idx], "prefab(" .. prefab .. ") has no 'shelf" .. idx .. "' slot")
            local scene = building_slots["shelf" .. idx].scene
            local offset = math3d.ref(math3d.matrix {s = scene.s, r = scene.r, t = scene.t})
            function prefab_instance:on_ready()
                local e <close> = w:entity(self.tag["*"][1])
                iom.set_srt_matrix(e, math3d.mul(building_srt, offset))
            end
            function prefab_instance:on_message()
            end
            shelves[#shelves+1] = world:create_object(prefab_instance)

            shelf_offsets[#shelf_offsets+1] = offset
            heap_offsets[#heap_offsets+1] = math3d.ref(math3d.matrix {s = slots["pile_slot"].scene.s, r = slots["pile_slot"].scene.r, t = slots["pile_slot"].scene.t})
        end
    end

    for idx = 1, ingredients_n do
        local id = string.unpack("<I2I2", typeobject_recipe.ingredients, 4*idx+1)
        local typeobject_item = iprototype.queryById(id)
        local gap3 = typeobject_item.gap and {typeobject_item.gap:match("(%d+)x(%d+)x(%d+)")} or {0, 0, 0}
        local srt = math3d.mul(building_srt, shelf_offsets[#heaps+1])
        srt = math3d.mul(srt, heap_offsets[#heaps+1])
        local s, r, t = math3d.srt(srt)
        srt = {s = s, r = r, t = t}
        local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
        local slot = assert(gameplay_world:container_get(e.chest, idx))
        heaps[#heaps+1] = create_heap(prefab_meshbin(prefab)[1], srt, HEAP_DIM3, gap3, slot.amount)
        io_counts[#io_counts+1] = slot.amount
    end
    for idx = 1, results_n do
        local id = string.unpack("<I2I2", typeobject_recipe.results, 4*idx+1)
        local typeobject_item = iprototype.queryById(id)
        local gap3 = typeobject_item.gap and {typeobject_item.gap:match("(%d+)x(%d+)x(%d+)")} or {0, 0, 0}
        local srt = math3d.mul(building_srt, shelf_offsets[#heaps+1])
        srt = math3d.mul(srt, heap_offsets[#heaps+1])
        local s, r, t = math3d.srt(srt)
        srt = {s = s, r = r, t = t}
        local prefab = "/pkg/vaststars.resources/" .. typeobject_item.pile_model
        local slot = assert(gameplay_world:container_get(e.chest, idx + ingredients_n))
        heaps[#heaps+1] = create_heap(prefab_meshbin(prefab)[1], srt, HEAP_DIM3, gap3, slot.amount)
        io_counts[#io_counts+1] = slot.amount
    end

    local function update_heap_count(_, e)
        if typeobject_building.io_shelf == false then
            return
        end

        for idx = 1, ingredients_n do
            local slot = assert(gameplay_world:container_get(e.chest, idx))
            if io_counts[idx] ~= slot.amount then
                iheapmesh.update_heap_mesh_number(heaps[idx].id, slot.amount)
                io_counts[idx] = slot.amount
            end
        end
        for idx = 1, results_n do
            local io_idx = idx + ingredients_n
            local slot = assert(gameplay_world:container_get(e.chest, io_idx))
            if io_counts[io_idx] ~= slot.amount then
                iheapmesh.update_heap_mesh_number(heaps[idx].id, slot.amount)
                io_counts[io_idx] = slot.amount
            end
        end
    end
    local function remove()
        for _, o in ipairs(shelves) do
            o:remove()
        end
        for _, o in ipairs(heaps) do
            o:remove()
        end
    end
    return {
        recipe = typeobject_recipe.id,
        update_heap_count = update_heap_count,
        remove = remove,
    }
end

return function(world)
    for e in world.ecs:select "assembling:in chest:in building:in eid:in" do
        local object = assert(objects:coord(e.building.x, e.building.y))
        local srt = math3d.matrix {s = object.srt.s, r = object.srt.r, t = object.srt.t}
        local building = buildings[object.id]

        if not building.io_shelves then
            if e.assembling.recipe ~= 0 then
                building.io_shelves = create_io_shelves(world, e, srt)
            end
        else
            if e.assembling.recipe == 0 then
                if building.io_shelves.recipe ~= 0 then
                    building.io_shelves:remove()
                    building.io_shelves = nil
                end
            else
                if building.io_shelves.recipe ~= e.assembling.recipe then
                    building.io_shelves:remove()
                    building.io_shelves = create_io_shelves(world, e, srt)
                else
                    building.io_shelves:update_heap_count(e)
                end
            end
        end
    end
end