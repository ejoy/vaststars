local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local math3d = require "math3d"
local iprototype = require "gameplay.interface.prototype"
local assetmgr = import_package "ant.asset"
local icanvas = ecs.require "engine.canvas"
local objects = require "objects"

local ROTATORS <const> = {
    N = math.rad(0),
    E = math.rad(-90),
    S = math.rad(-180),
    W = math.rad(-270),
}

local function __calc_begin_xy(x, y, w, h)
    local begin_x = x - (w * TILE_SIZE) / 2
    local begin_y = y + (h * TILE_SIZE) / 2
    return begin_x, begin_y
end

local function __get_texture_size(materialpath)
    local res = assetmgr.resource(materialpath)
    local texobj = assetmgr.resource(res.properties.s_basecolor.texture)
    local ti = texobj.texinfo
    return tonumber(ti.width), tonumber(ti.height)
end

local function __get_draw_rect(x, y, icon_w, icon_h, multiple)
    multiple = multiple or 1
    local tile_size = TILE_SIZE * multiple
    y = y - tile_size
    local max = math.max(icon_h, icon_w)
    local draw_w = tile_size * (icon_w / max)
    local draw_h = tile_size * (icon_h / max)
    local draw_x = x - (tile_size / 2)
    local draw_y = y + (tile_size / 2)
    return draw_x, draw_y, draw_w, draw_h
end

local function __draw_fluid_indication_arrow(object_id, building_srt, dir, prototype)
    local typeobject = iprototype.queryById(prototype)
    local begin_x, begin_y = __calc_begin_xy(math3d.index(building_srt.t, 1), math3d.index(building_srt.t, 3), iprototype.rotate_area(typeobject.area, dir))

    local connections
    if typeobject.fluidbox then
        connections = typeobject.fluidbox.connections
    elseif typeobject.fluidboxes then
        connections = {}
        for _, io in pairs(typeobject.fluidboxes) do
            for _, v in ipairs(io) do
                table.move(v.connections, 1, #v.connections, #connections + 1, connections)
            end
        end
    end

    for _, conn in ipairs(connections) do
        local connection_x, connection_y, connection_dir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
        local material_path
        if conn.type == "input" then
            material_path = "/pkg/vaststars.resources/materials/canvas/pickup-fluid-indication-arrow-input.material"
        else
            material_path = "/pkg/vaststars.resources/materials/canvas/pickup-fluid-indication-arrow-output.material"
        end
        local dx, dy = iprototype.move_coord(connection_x, connection_y, connection_dir, 1, 1)
        local icon_w, icon_h = __get_texture_size(material_path)
        local texture_x, texture_y, texture_w, texture_h = 0, 0, icon_w, icon_h
        local draw_x, draw_y, draw_w, draw_h = __get_draw_rect(
            begin_x + dx * TILE_SIZE + TILE_SIZE / 2,
            begin_y - dy * TILE_SIZE - TILE_SIZE / 2,
            icon_w,
            icon_h
        )
        icanvas.add_item("pickup_icon",
            object_id,
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
end

local function __create_icon(object_id, building_srt, dir, prototype)
    local function on_position_change(self, building_srt)
        local object = assert(objects:get(object_id))
        icanvas.remove_item("pickup_icon", object_id)
        __draw_fluid_indication_arrow(object_id, building_srt, object.dir, prototype)
    end
    local function remove(self)
        icanvas.remove_item("pickup_icon", object_id)
    end
    __draw_fluid_indication_arrow(object_id, building_srt, dir, prototype)

    return {
        on_position_change = on_position_change,
        remove = remove,
        object_id = object_id,
    }
end

local mt = {}
mt.__index = mt

function mt:remove()
    icanvas.remove_item("pickup_icon", 0)
    icanvas.show("pickup_icon", false)
    icanvas.iom("pickup_icon", "set_position", {0, 0, 0})
end

function mt:on_position_change(building_srt, dir)
    local delta = math3d.sub(building_srt.t, self.position)
    icanvas.iom("pickup_icon", "move_delta", math3d.live(delta))
    self.position = building_srt.t

    if dir ~= self.dir then
        icanvas.remove_item("pickup_icon", 0)
        icanvas.iom("pickup_icon", "set_position", {0, 0, 0})
        __create_icon(0, building_srt, dir, self.typeobject.id)
        self.dir = dir
    end
end

function mt:on_status_change(status)
end

local m = {}
function m.create(dir, building_srt, typeobject)
    local self = setmetatable({}, mt)
    self.typeobject = typeobject

    self.dir = dir
    self.position = building_srt.t
    __create_icon(0, building_srt, dir, typeobject.id)
    icanvas.show("pickup_icon", true)
    return self
end
return m