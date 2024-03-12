local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local MAX_BUILDING_WIDTH_SIZE <const> = CONSTANT.MAX_BUILDING_WIDTH_SIZE
local MAX_BUILDING_HEIGHT_SIZE <const> = CONSTANT.MAX_BUILDING_HEIGHT_SIZE
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local COLOR <const> = ecs.require "vaststars.prototype|color"

local icoord = require "coord"
local COORD_BOUNDARY <const> = icoord.boundary()

local irq = ecs.require "ant.render|renderqueue"
local math3d = require "math3d"
local icamera_controller = ecs.require "engine.system.camera_controller"
local objects = require "objects"
local update_buildings_state = ecs.require "ui_datamodel.common.bulk_opt".update_buildings_state
local global = require "global"

local other_buldings = {} -- = {eid = true, ...}
local obstructed_buildings = {} -- = {eid = true, ...}

local function _mark_other_buldings(t)
    local add, del = {}, {}
    for gameplay_eid in pairs(t) do
        if not other_buldings[gameplay_eid] and not global.selected_buildings[gameplay_eid] and not obstructed_buildings[gameplay_eid] then
            add[gameplay_eid] = true
            other_buldings[gameplay_eid] = true
        end
    end
    for gameplay_eid in pairs(other_buldings) do
        if not t[gameplay_eid] and not global.selected_buildings[gameplay_eid] and not obstructed_buildings[gameplay_eid] then
            del[gameplay_eid] = true
            other_buldings[gameplay_eid] = nil
        end
    end

    update_buildings_state({
        {add, "translucent", COLOR.BULK_OTHER_BUILDINGS, RENDER_LAYER.TRANSLUCENT_BUILDING},
        {del, "opaque", "null", RENDER_LAYER.BUILDING},
    })
end

local function update()
    local points = icamera_controller.get_interset_points(world:entity(irq.main_camera()))
    -- because the group id of the buildings is calculated based on the coordinates of the top-left corner, so we need to expand the range
    local lt, rb = points[2], math3d.set_index(points[3], 1, math3d.index(points[4], 1))
    lt = math3d.add(lt, {-(MAX_BUILDING_WIDTH_SIZE), 0, MAX_BUILDING_HEIGHT_SIZE})
    rb = math3d.add(rb, {MAX_BUILDING_WIDTH_SIZE, 0, -(MAX_BUILDING_HEIGHT_SIZE)})

    local t = {}
    local lt_coord = icoord.position2coord(lt) or {0, 0}
    local rb_coord = icoord.position2coord(rb) or {COORD_BOUNDARY[2][1], COORD_BOUNDARY[2][2]}
    for x = lt_coord[1], rb_coord[1] do
        for y = lt_coord[2], rb_coord[2] do
            local object = objects:coord(x, y)
            if object then
                t[object.gameplay_eid] = true
            end
        end
    end
    _mark_other_buldings(t)
end

local function clear()
    update_buildings_state({
        {other_buldings, "opaque", "null", RENDER_LAYER.BUILDING},
        {obstructed_buildings, "opaque", "null", RENDER_LAYER.BUILDING}
    })
    other_buldings = {}
    obstructed_buildings = {}
end

local function mark_obstructed(t)
    local add = {}
    for gameplay_eid in pairs(t) do
        if not obstructed_buildings[gameplay_eid] then
            add[gameplay_eid] = true
            obstructed_buildings[gameplay_eid] = true
            other_buldings[gameplay_eid] = nil
        end
    end
    for gameplay_eid in pairs(obstructed_buildings) do
        if not t[gameplay_eid] then
            obstructed_buildings[gameplay_eid] = nil
        end
    end

    if not next(add) then
        return
    end

    update_buildings_state({
        {add, "translucent", COLOR.BULK_OBSTRUCTED_BUILDINGS, RENDER_LAYER.TRANSLUCENT_BUILDING},
    })
end

return {
    update = update,
    clear = clear,
    mark_obstructed = mark_obstructed,
}