local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local mu = import_package "ant.math".util
local math3d = require "math3d"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local idetail = ecs.interface "idetail"

function idetail.show(object_id)
    iui.open({"detail_panel.rml"}, object_id)

    -- 显示环型菜单
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)

    idetail.selected(object)

    local mq = w:first("main_queue camera_ref:in render_target:in")
    local ce <close> = w:entity(mq.camera_ref, "camera:in")
    local vp = ce.camera.viewprojmat
    local vr = mq.render_target.view_rect
    local p = mu.world_to_screen(vp, vr, object.srt.t) -- the position always in the center of the screen after move camera
    local ui_x, ui_y = iui.convert_coord(vr, math3d.index(p, 1), math3d.index(p, 2))

    if typeobject.show_arc_menu ~= false then
        iui.open({"build_function_pop.rml"}, object_id, object.srt.t, ui_x, ui_y)
    end

    do
        log.info(object.id, object.prototype_name, object.x, object.y, object.dir, object.fluid_name, object.fluidflow_id)
        -- log.info(([[
        -- {
        --     prototype_name = "%s",
        --     dir = "%s",
        --     x = %s,
        --     y = %s,
        -- },
        -- ]]):format(object.prototype_name, object.dir, object.x, object.y))
    end
    return true
end

do
    local BLOCK_COLOR <const> = math3d.constant("v4", {0.0, 1, 0.0, 1.0})
    local BLOCK_POWER_SUPPLY_AREA_COLOR <const> = math3d.constant("v4", {0.13, 1.75, 2.4, 0.5})
    local BLOCK_EDGE_SIZE <const> = 6

    local BLOCK_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})
    local ROTATORS <const> = require("gameplay.interface.constant").ROTATORS
    local terrain = ecs.require "terrain"
    local iplant = ecs.require "engine.plane"

    local blocks = {}

    function idetail.unselected()
        for _, block in ipairs(blocks) do
            block:remove()
        end
        blocks = {}
    end

    local function __show_block(position, dir, color, w, h)
        blocks[#blocks+1] = iplant.create("/pkg/vaststars.resources/materials/singlecolor.material", "u_color", color,
            {
                s = {terrain.tile_size * w + BLOCK_EDGE_SIZE, 1, terrain.tile_size * h + BLOCK_EDGE_SIZE},
                r = ROTATORS[dir],
                t = math3d.ref(math3d.add(position, BLOCK_POSITION_OFFSET))
            }
        )
    end

    function idetail.selected(object)
        idetail.unselected()

        local block_color
        local typeobject = iprototype.queryByName(object.prototype_name)
        local w, h
        if typeobject.power_supply_area and typeobject.power_supply_distance then
            block_color = BLOCK_POWER_SUPPLY_AREA_COLOR
            for _, object in objects:all() do
                local otypeobject = iprototype.queryByName(object.prototype_name)
                if otypeobject.power_supply_area then
                    local ow, oh = otypeobject.power_supply_area:match("(%d+)x(%d+)")
                    ow, oh = tonumber(ow), tonumber(oh)
                    __show_block(object.srt.t, object.dir, block_color, ow, oh)
                end
            end
        else
            block_color = BLOCK_COLOR
            w, h = iprototype.unpackarea(typeobject.area)
            __show_block(object.srt.t, object.dir, block_color, w, h)
        end
    end
end