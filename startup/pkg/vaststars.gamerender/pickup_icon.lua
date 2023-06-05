local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local assetmgr = import_package "ant.asset"
local iterrain = ecs.require "terrain"
local irecipe = require "gameplay.interface.recipe"
local icanvas = ecs.require "engine.canvas"
local math3d = require "math3d"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local fs = require "filesystem"
local datalist = require "datalist"
local FLUIDS_CFG <const> = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/config/canvas/fluids.cfg")):read "a")

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

local function __create_icon(fluid, begin_x, begin_y, connection_x, connection_y)
    local material_path = "/pkg/vaststars.resources/materials/canvas/fluid-bg.material"
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
    icanvas.add_item(icanvas.types().PICKUP_ICON, 0, icanvas.get_key(material_path, RENDER_LAYER.ICON), item1)

    local fluid_typeobject = iprototype.queryById(fluid)
    local cfg = FLUIDS_CFG[fluid_typeobject.icon]
    if not cfg then
        assert(cfg, ("can not found `%s`"):format(fluid_typeobject.icon))
        return
    end

    local material_path = "/pkg/vaststars.resources/materials/canvas/fluids.material"
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
    icanvas.add_item(icanvas.types().PICKUP_ICON, 0, icanvas.get_key(material_path, RENDER_LAYER.ICON_CONTENT), item2)
end

local function __create_icons(self, typeobject, recipe, building_srt, dir)
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
                __create_icon(v.id, begin_x, begin_y, connection_x, connection_y)
            end
        end
    end
end

local mt = {}
mt.__index = mt

function mt:remove()
    icanvas.remove_item(icanvas.types().PICKUP_ICON, 0)
    icanvas.show(icanvas.types().PICKUP_ICON, false)
    local obj = icanvas.get(icanvas.types().PICKUP_ICON)
    obj:send("iom", "set_position", {0, 0, 0})
end

function mt:on_position_change(building_srt, dir)
    if not self.typeobject.fluidboxes then
        return
    end

    local delta = math3d.ref(math3d.sub(building_srt.t, self.position))
    local obj = icanvas.get(icanvas.types().PICKUP_ICON)
    obj:send("iom", "move_delta", delta)
    self.position = building_srt.t

    if dir ~= self.dir then
        icanvas.remove_item(icanvas.types().PICKUP_ICON, 0)
        obj:send("iom", "set_position", {0, 0, 0})
        __create_icons(self, self.typeobject, self.recipe, building_srt, dir)
        self.dir = dir
    end
end

local m = {}
function m.create(typeobject, dir, recipe, building_srt)
    local self = setmetatable({}, mt)
    self.typeobject = typeobject
    if not typeobject.fluidboxes then
        return self
    end

    self.dir = dir
    self.recipe = recipe
    self.position = building_srt.t
    __create_icons(self, typeobject, recipe, building_srt, dir)
    icanvas.show(icanvas.types().PICKUP_ICON, true)
    return self
end
return m