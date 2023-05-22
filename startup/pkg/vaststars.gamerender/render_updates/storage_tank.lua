local ecs = ...
local world = ecs.world
local w = world.w

local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local draw_fluid_icon = ecs.require "fluid_icon"
local icanvas = ecs.require "engine.canvas"
local global = require "global"
local gameplay_core = require "gameplay.core"
local math3d = require "math3d"
local storage_tank_sys = ecs.system "storage_tank_system"

local function __create_fluid_icon_component(object_id, x, y, fluid)
    local m = {id = object_id, fluid = fluid, x = x, y = y}
    draw_fluid_icon(object_id, x, y, fluid)

    function m:on_position_change(building_srt)
        self:remove()
        self.x, self.y = building_srt.t[1], building_srt.t[3]
        draw_fluid_icon(self.object_id, building_srt.t[1], building_srt.t[3], self.fluid)
    end
    function m:remove()
        icanvas.remove_item(icanvas.types().ICON, self.object_id)
    end
    function m:update(fluid)
        if self.fluid == fluid then
            return
        end
        self.fluid = fluid
        draw_fluid_icon(self.object_id, self.x, self.y, fluid)
    end
    return m
end

function storage_tank_sys:gameworld_build()
    local world = gameplay_core.get_world()
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

        if e.fluidbox.fluid == 0 then
            goto continue
        end

        local building = global.buildings[object.id]
        local x, y = math3d.index(object.srt.t, 1, 3)
        if not building.storage_tank_icon then
            building.storage_tank_icon = __create_fluid_icon_component(object.id, x, y, e.fluidbox.fluid)
        end
        building.storage_tank_icon:update(e.fluidbox.fluid)

        ::continue::
    end
end