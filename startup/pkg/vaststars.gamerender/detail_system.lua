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

    --
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
        iui.open({"building_arc_menu.rml"}, object_id, object.srt.t, ui_x, ui_y)
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
    local sprites = {}
    local create_sprite = ecs.require "sprite"
    local SPRITE_COLOR = import_package "vaststars.prototype"("sprite_color")

    function idetail.unselected()
        for _, sprite in ipairs(sprites) do
            sprite:remove()
        end
        sprites = {}
    end

    function idetail.selected(object)
        idetail.unselected()

        local typeobject = iprototype.queryByName(object.prototype_name)
        if typeobject.power_supply_area and typeobject.power_supply_distance then
            for _, object in objects:all() do
                local otypeobject = iprototype.queryByName(object.prototype_name)
                if otypeobject.power_supply_area then
                    local w, h = iprototype.unpackarea(otypeobject.area)
                    local ow, oh = otypeobject.power_supply_area:match("(%d+)x(%d+)")
                    ow, oh = tonumber(ow), tonumber(oh)
                    sprites[#sprites+1] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, SPRITE_COLOR.POWER_SUPPLY_AREA)
                end
            end
        end
    end
end