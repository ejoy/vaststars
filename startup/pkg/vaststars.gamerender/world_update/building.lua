local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local global = require "global"
local icanvas = ecs.require "engine.canvas"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local iterrain = ecs.require "terrain"
local datalist = require "datalist"
local fs = require "filesystem"
local building_base_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/building_base.cfg")):read "a")

local function __draw_building_base(object_id, building_srt, w, h)
    local cfg = building_base_cfg[("%dx%d"):format(w, h)]
    local item_x, item_y = building_srt.t[1] - (w/2 * iterrain.tile_size), building_srt.t[3] - (h/2 * iterrain.tile_size)
    local draw_x, draw_y, draw_w, draw_h = item_x, item_y, w * iterrain.tile_size, h * iterrain.tile_size

    icanvas.add_item(icanvas.types().BUILDING_BASE,
        object_id,
        "/pkg/vaststars.resources/textures/canvas_texture.material",
        RENDER_LAYER.BUILDING_BASE,
        {
            texture = {
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = draw_x, y = draw_y, w = draw_w, h = draw_h,
        }
    )
end

local function __create_building_base(object_id, typeobject, building_srt, dir)
    local w, h = iprototype.rotate_area(typeobject.area, dir)
    __draw_building_base(object_id, building_srt, w, h)
    local function remove()
        icanvas.remove_item(icanvas.types().BUILDING_BASE, object_id)
    end
    local function on_position_change(self, building_srt, dir)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        icanvas.remove_item(icanvas.types().BUILDING_BASE, object_id)
        __draw_building_base(object_id, building_srt, w, h)
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
    }
end

return function(gameplay_world)
    for e in gameplay_world.ecs:select "building_changed:in building:in eid:in" do
        -- object may not have been fully created yet
        local object = objects:coord(e.building.x, e.building.y)
        if not object then
            goto continue
        end

        local typeobject = iprototype.queryById(e.building.prototype)
        if typeobject.building_base == false then
            goto continue
        end

        local building = global.buildings[object.id]
        if not building.building_base then
            building.building_base = __create_building_base(object.id, typeobject, object.srt, object.dir)
        end

        ::continue::
    end
    gameplay_world.ecs:clear "building_changed"
end