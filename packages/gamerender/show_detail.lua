local ecs = ...
local world = ecs.world
local w = world.w

local gameplay_core = ecs.require "gameplay.core"
local object_manager = require "objects"
local objects = object_manager.objects
local cache_names = object_manager.cache_names
local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local iui = ecs.import.interface "vaststars.gamerender|iui"

local function show_detail(vsobject_id)
    local object = assert(objects:get(cache_names, vsobject_id))

    local e
    for v in gameplay_core.select "entity:in fluidbox?in" do
        if v.entity.x == object.x and v.entity.y == object.y then
            e = v
            break
        end
    end
    if not e then
        return
    end

    local t = {}
    t.name = object.prototype_name

    if e.fluidbox and e.fluidbox.fluid ~= 0 then
        local pt = gameplay.query(e.fluidbox.fluid)
        t.fluid_name = pt.name

        local r = gameplay_core.fluidflow_query(e.fluidbox.fluid, e.fluidbox.id)
        if r then
            t.fluid_volume = r.volume / r.multiple
        end
    end

    iui.close("detail_panel.rml")
    iui.open("detail_panel.rml", t)
    return true
end
return show_detail