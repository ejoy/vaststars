local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local gameplay_core = require "gameplay.core"
local math3d = require "math3d"
local DEFAULT_COLOR <const> = math3d.constant("v4", {2.5, 0.0, 0.0, 0.55})
local objects = require "objects"
local vsobject_manager = ecs.require "vsobject_manager"

local function get_object(x, y)
    local object = objects:coord(x, y)
    if object then
        return vsobject_manager:get(object.id)
    end
end

local function _round(max_tick)
    local v <const> = 100 / max_tick / 100
    return function(progress) -- progress: 0.0 ~ 1.0
        return math.ceil(progress / v) * v
    end
end
local _get_progress = _round(10)

local color_cache = {}
local function _get_fluid_color(fluid)
    if color_cache[fluid] then
        return color_cache[fluid]
    end

    local typeobject = iprototype.queryById(fluid)
    if typeobject.color then
        color_cache[fluid] = math3d.constant("v4", typeobject.color)
        return color_cache[fluid]
    end
end

return function(world)
    local t = {}
    for e in world.ecs:select "fluidbox:in building:in" do
        local typeobject = assert(iprototype.queryById(e.building.prototype))
        if not typeobject.storage_tank then
            goto continue
        end

        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local vsobject = assert(vsobject_manager:get(object.id), ("(%s) vsobject not found"):format(object.prototype_name))

        local volume = 0
        local capacity = 0
        local color
        if e.fluidbox.fluid ~= 0 then
            color = _get_fluid_color(e.fluidbox.fluid)
            local r = gameplay_core.fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
            if r then
                volume = r.volume / r.multiple
                capacity = r.capacity / r.multiple
            end
        end

        if volume > 0 then
            vsobject:attach("water_slot", "prefabs/storage-tank-water.prefab", "opacity", color or DEFAULT_COLOR)
        else
            vsobject:detach()
        end

        if volume > 0 then
            -- local animation_name = "ArmatureAction"
            -- animation_name, _get_progress(volume / capacity)
        end
        ::continue::
    end
    return t
end