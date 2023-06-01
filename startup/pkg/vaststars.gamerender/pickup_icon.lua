local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local assetmgr = import_package "ant.asset"
local iterrain = ecs.require "terrain"
local irecipe = require "gameplay.interface.recipe"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local icas = ecs.import.interface "ant.terrain|icanvas"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local constant = require "gameplay.interface.constant"

local ROTATORS = constant.ROTATORS
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local fs = require "filesystem"
local datalist = require "datalist"
local fluid_icon_canvas_cfg <const> = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/fluid_icon_canvas.cfg")):read "a")

local entity_events = {}
entity_events.add_item = function(self, e, ...)
    icas.add_items(e, ...)
end

entity_events.iom = function(self, e, method, ...)
    iom[method](e, ...)
end

local function __get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return ti.width, ti.height
end

local function __get_draw_rect(x, y, icon_w, icon_h, multiple)
    local tile_size = iterrain.tile_size * multiple
    multiple = multiple or 1
    y = y - tile_size
    local max = math.max(icon_h, icon_w)
    local draw_w = tile_size * (icon_w / max)
    local draw_h = tile_size * (icon_h / max)
    local draw_x = x - (tile_size / 2)
    local draw_y = y + (tile_size / 2)
    return draw_x, draw_y, draw_w, draw_h
end

local function __calc_begin_xy(x, y, w, h)
    local tile_size = iterrain.tile_size
    local begin_x = x - (w * tile_size) / 2
    local begin_y = y + (h * tile_size) / 2
    return begin_x, begin_y
end

local function __create_icon(canvas, fluid, begin_x, begin_y, connection_x, connection_y, render_layer)
    local material_path = "/pkg/vaststars.resources/materials/fluid_icon_bg.material"
    local texture_x, texture_y, texture_w, texture_h = 0, 0, __get_texture_size(material_path)
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
        begin_x + connection_x * iterrain.tile_size + iterrain.tile_size / 2,
        begin_y - connection_y * iterrain.tile_size - iterrain.tile_size / 2,
        texture_w,
        texture_h,
        1
    )

    local item1 = {
        texture = {
            rect = {
                x = texture_x,
                y = texture_y,
                w = texture_w,
                h = texture_h,
            },
        },
        x = draw_x, y = draw_y, w = draw_w, h = draw_h,
    }
    canvas:send("add_item", material_path, render_layer, item1)

    local fluid_typeobject = iprototype.queryById(fluid)
    local cfg = fluid_icon_canvas_cfg[fluid_typeobject.icon]
    if not cfg then
        assert(cfg, ("can not found `%s`"):format(fluid_typeobject.icon))
        return
    end

    local material_path = "/pkg/vaststars.resources/materials/fluid_icon_canvas.material"
    texture_x, texture_y, texture_w, texture_h = cfg.x, cfg.y, cfg.width, cfg.height
    draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
        begin_x + connection_x * iterrain.tile_size + iterrain.tile_size / 2,
        begin_y - connection_y * iterrain.tile_size - iterrain.tile_size / 2,
        texture_w,
        texture_h,
        1
    )
    local item2 = {
        texture = {
            rect = {
                x = texture_x,
                y = texture_y,
                w = texture_w,
                h = texture_h,
            },
        },
        x = draw_x, y = draw_y, w = draw_w, h = draw_h,
    }
    canvas:send("add_item", material_path, render_layer, item2)
end

local function __create_icons(self, typeobject, recipe, building_srt, dir, parent)
    self.__canvas = ientity_object.create(ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.terrain|canvas",
            "ant.general|name",
        },
        data = {
            name = "canvas",
            scene = {
                parent = parent,
                t = {0.0, iterrain.surface_height + 10, 0.0},
            },
            canvas = {
                show = true,
            },
        }
    }, entity_events)

    local recipe_typeobject = assert(iprototype.queryById(recipe))
    local t = {
        {"ingredients", "input"},
        {"results", "output"},
    }

    local begin_x, begin_y = __calc_begin_xy(building_srt.t[1], building_srt.t[3], iprototype.rotate_area(typeobject.area, dir))

    for _, r in ipairs(t) do
        for idx, v in ipairs(irecipe.get_elements(recipe_typeobject[r[1]])) do
            if iprototype.is_fluid_id(v.id) then
                local c = assert(typeobject.fluidboxes[r[2]][idx])
                local connection = assert(c.connections[1])
                local connection_x, connection_y = iprototype.rotate_connection(connection.position, dir, typeobject.area)
                __create_icon(self.__canvas, v.id, begin_x, begin_y, connection_x, connection_y, RENDER_LAYER.ICON)
            end
        end
    end
end

local mt = {}
mt.__index = mt

function mt:remove()
    if not self.__canvas then
        return
    end
    self.__canvas:remove()
end

function mt:on_position_change(building_srt, dir)
    -- if not self.typeobject.fluidboxes then
    --     return
    -- end
    -- self:remove()
    -- __create_icons(self, self.typeobject, self.recipe, building_srt, dir)

    self.__canvas:send("iom", "set_position", building_srt.t)
    self.__canvas:send("iom", "set_rotation", ROTATORS[dir])
end

local m = {}
function m.create(typeobject, dir, recipe, building_srt, parent)
    local self = setmetatable({}, mt)
    self.typeobject = typeobject
    if not typeobject.fluidboxes then
        return self
    end

    self.dir = dir
    self.recipe = recipe
    __create_icons(self, typeobject, recipe, building_srt, dir, parent)
    return self
end
return m