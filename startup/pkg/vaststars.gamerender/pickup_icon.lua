local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local FLUIDBOXES <const> = CONSTANT.FLUIDBOXES
local ROTATORS <const> = {
    N = math.rad(0),
    E = math.rad(-90),
    S = math.rad(-180),
    W = math.rad(-270),
}

local function read_datalist(path)
    local fs = require "filesystem"
    local datalist = require "datalist"
    local fastio = require "fastio"
    return datalist.parse(fastio.readall(fs.path(path):localpath():string(), path))
end
local FLUIDS_CFG <const> = read_datalist "/pkg/vaststars.resources/config/canvas/fluids.cfg"

local iprototype = require "gameplay.interface.prototype"
local assetmgr = import_package "ant.asset"
local icanvas = ecs.require "engine.canvas"
local math3d = require "math3d"
local gameplay_core = require "gameplay.core"

local function __get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return tonumber(ti.width), tonumber(ti.height)
end

local function __get_draw_rect(x, y, icon_w, icon_h, multiple)
    multiple = multiple or 1
    local tile_size = TILE_SIZE * multiple
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
    local tile_size = TILE_SIZE
    local begin_x = x - (w * tile_size) / 2
    local begin_y = y + (h * tile_size) / 2
    return begin_x, begin_y
end

local function __create_icon(fluid, begin_x, begin_y, connection_x, connection_y)
    local material_path = "/pkg/vaststars.resources/materials/canvas/fluid-bg.material"
    local texture_x, texture_y, texture_w, texture_h = 0, 0, __get_texture_size(material_path)
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
        begin_x + connection_x * TILE_SIZE + TILE_SIZE / 2,
        begin_y - connection_y * TILE_SIZE - TILE_SIZE / 2,
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
    icanvas.add_item("pickup_icon", 0, icanvas.get_key(material_path, RENDER_LAYER.ICON), item1)

    local fluid_typeobject = iprototype.queryById(fluid)
    local cfg = FLUIDS_CFG[fluid_typeobject.item_icon]
    if not cfg then
        error(("can not found `%s`"):format(fluid_typeobject.item_icon))
        return
    end

    local material_path = "/pkg/vaststars.resources/materials/canvas/fluids.material"
    texture_x, texture_y, texture_w, texture_h = cfg.x, cfg.y, cfg.width, cfg.height
    draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
        begin_x + connection_x * TILE_SIZE + TILE_SIZE / 2,
        begin_y - connection_y * TILE_SIZE - TILE_SIZE / 2,
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
    icanvas.add_item("pickup_icon", 0, icanvas.get_key(material_path, RENDER_LAYER.ICON_CONTENT), item2)
end

local function __create_fluid_indication_arrow(connection_x, connection_y, connection_dir, iotype, begin_x, begin_y)
    local dx, dy = iprototype.move_coord(connection_x, connection_y, connection_dir, 1, 1)
    local material_path

    if iotype == "input" then
        material_path = "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-input.material"
    else
        material_path = "/pkg/vaststars.resources/materials/canvas/fluid-indication-arrow-output.material"
    end

    local icon_w, icon_h = __get_texture_size(material_path)
    local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
    local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
        begin_x + dx * TILE_SIZE + TILE_SIZE / 2,
        begin_y - dy * TILE_SIZE - TILE_SIZE / 2,
        icon_w,
        icon_h
    )
    icanvas.add_item("pickup_icon",
        0,
        icanvas.get_key(material_path, RENDER_LAYER.FLUID_INDICATION_ARROW),
        {
            texture = {
                rect = {
                    x = texture_x,
                    y = texture_y,
                    w = texture_w,
                    h = texture_h,
                },
                srt = {
                    r = ROTATORS[connection_dir],
                },
            },
            x = draw_x, y = draw_y, w = draw_w, h = draw_h,
        }
    )
end

local function __create_icons(self, typeobject, gameplay_eid, building_srt, dir)
    local e = assert(gameplay_core.get_entity(gameplay_eid))
    local begin_x, begin_y = __calc_begin_xy(math3d.index(building_srt.t, 1), math3d.index(building_srt.t, 3), iprototype.rotate_area(typeobject.area, dir))

    if e.fluidboxes then
        for _, v in ipairs(FLUIDBOXES) do
            local fluid = e.fluidboxes[v.fluid]
            if fluid ~= 0 then
                local c = assert(typeobject.fluidboxes[v.classify][v.index])
                local connection = assert(c.connections[1])
                local connection_x, connection_y, connection_dir = iprototype.rotate_connection(connection.position, dir, typeobject.area)
                __create_icon(fluid, begin_x, begin_y, connection_x, connection_y)
                __create_fluid_indication_arrow(connection_x, connection_y, connection_dir, v.classify, begin_x, begin_y)
            end
        end
    end
end

local mt = {}
mt.__index = mt

function mt:remove()
    icanvas.remove_item("pickup_icon", 0)
    icanvas.show("pickup_icon", false)
    icanvas.iom("pickup_icon", "set_position", {0, 0, 0})
end

function mt:on_position_change(building_srt, dir)
    if not self.typeobject.fluidboxes then
        return
    end

    local delta = math3d.sub(building_srt.t, self.position)
    icanvas.iom("pickup_icon", "move_delta", math3d.live(delta))
    self.position = building_srt.t

    if dir ~= self.dir then
        icanvas.remove_item("pickup_icon", 0)
        icanvas.iom("pickup_icon", "set_position", {0, 0, 0})
        __create_icons(self, self.typeobject, self.gameplay_eid, building_srt, dir)
        self.dir = dir
    end
end

function mt:on_status_change(status)
end

local m = {}
function m.create(typeobject, dir, gameplay_eid, building_srt)
    local self = setmetatable({}, mt)
    self.typeobject = typeobject
    if not typeobject.fluidboxes then
        return self
    end

    self.dir = dir
    self.gameplay_eid = gameplay_eid
    self.position = building_srt.t
    __create_icons(self, typeobject, gameplay_eid, building_srt, dir)
    icanvas.show("pickup_icon", true)
    return self
end
return m