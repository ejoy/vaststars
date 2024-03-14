local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT = require "gameplay.interface.constant"
local IN_FLUIDBOXES <const> = CONSTANT.IN_FLUIDBOXES
local OUT_FLUIDBOXES <const> = CONSTANT.OUT_FLUIDBOXES
local ROTATORS <const> = CONSTANT.ROTATORS
local FLUID_PORT_PREFAB <const> = "/pkg/vaststars.resources/glbs/pipe/pipejoint/pipejoint.gltf|mesh.prefab"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local iprototype = require "gameplay.interface.prototype"
local igame_object = ecs.require "engine.game_object"
local igroup = ecs.require "group"
local icoord = require "coord"

local cache = {}

local function _uniquekey(x, y, d)
    return ("%d,%d,%s"):format(x, y, d)
end

local function remove(eid)
    for _, v in pairs(cache[eid] or {}) do
        v:remove()
    end
    cache[eid] = nil
end

local function renew(gameplay_world, e)
    local ecs = gameplay_world.ecs
    ecs:extend(e, "eid:in fluidboxes?in")
    if not e.fluidboxes then
        return
    end

    local input, output = 0, 0
    for _, v in ipairs(IN_FLUIDBOXES) do
        if e.fluidboxes[v.fluid] ~= 0 then
            input = input + 1
        end
    end
    for _, v in ipairs(OUT_FLUIDBOXES) do
        if e.fluidboxes[v.fluid] ~= 0 then
            output = output + 1
        end
    end

    ecs:extend(e, "building:in")
    local typeobject = iprototype.queryById(e.building.prototype)
    local fluidbox_inputs = typeobject.fluidboxes.input
    local fluidbox_outputs = typeobject.fluidboxes.output
    assert(input <= #fluidbox_inputs)
    assert(output <= #fluidbox_outputs)

    local t = {}
    for i = 1, input do
        for _, c in ipairs(fluidbox_inputs[i].connections) do
            local dx, dy, dir = iprototype.rotate_connection(c.position, e.building.direction, typeobject.area)
            local x, y = e.building.x + dx, e.building.y + dy
            t[_uniquekey(x, y, dir)] = {x, y, dir}
        end
    end
    for i = 1, output do
        for _, c in ipairs(fluidbox_outputs[i].connections) do
            local dx, dy, dir = iprototype.rotate_connection(c.position, e.building.direction, typeobject.area)
            local x, y = e.building.x + dx, e.building.y + dy
            t[_uniquekey(x, y, dir)] = {x, y, dir}
        end
    end

    local old = cache[e.eid] or {}
    local add, del = {}, {}
    for k in pairs(t) do
        if not old[k] then
            add[k] = true
        end
    end
    for k in pairs(old) do
        if not t[k] then
            del[k] = true
        end
    end

    for k in pairs(add) do
        local x, y, dir = table.unpack(t[k])
        old[k] = igame_object.create {
            prefab = FLUID_PORT_PREFAB,
            group_id = igroup.id(x, y),
            render_layer = RENDER_LAYER.BUILDING,
            srt = {
                t = icoord.position(x, y, 1, 1),
                r = ROTATORS[iprototype.reverse_dir(dir)],
            }
        }
    end
    for k in pairs(del) do
        old[k]:remove()
        old[k] = nil
    end

    cache[e.eid] = old
end

return {
    renew = renew,
    remove = remove,
}