local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.import.interface "vaststars.gamerender|iui"
local math3d = require "math3d"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local idetail = ecs.interface "idetail"
local icamera_controller = ecs.import.interface "vaststars.gamerender|icamera_controller"
local gameplay_core = require "gameplay.core"
local create_selected_boxes = ecs.require "selected_boxes"

local function __get_capacitance(eid)
    local e = gameplay_core.get_entity(eid)
    if not e then
        return {network = "none", delta = 0, shortage = 0}
    end

    if not e.capacitance then
        return {network = "none", delta = 0, shortage = 0}
    end

    return e.capacitance
end

local function __fluid_str(prefix, fluid, fluidbox_id, box_base_level, box_capacity, box_height)
    local volume = "(none)"
    local capacity = "(none)"
    local flow = "(none)"
    local elevation = "(none)"

    local fluid_name = ""
    if fluid ~= 0 then
        fluid_name = iprototype.queryById(fluid).name
        local r = gameplay_core.fluidflow_query(fluid, fluidbox_id)
        if r then
            volume = r.volume / r.multiple
            capacity = r.capacity / r.multiple
            flow = r.flow / r.multiple
            elevation = volume / (box_capacity / box_height) + box_base_level
        end
    end

    return (([[%s fluidbox: fluid: %s, fluidbox_id: %d fluid_name: [%s], volume: %s, capacity: %s, flow: %s box_base_level: %s, box_capacity: %s, box_height: %s, elevation: %s ]]):format(
        prefix, fluid, fluidbox_id, fluid_name, volume, capacity, flow, box_base_level, box_capacity, box_height, elevation)
    )
end

local function __fluidbox_str(eid)
    local e = gameplay_core.get_entity(eid)
    if not e then
        return
    end

    local typeobject = iprototype.queryById(e.building.prototype)
    local res = {}

    if e.fluidbox then
        res[#res+1] = __fluid_str("fluidbox 0 ", e.fluidbox.fluid, e.fluidbox.id, typeobject.fluidbox.base_level, typeobject.fluidbox.capacity, typeobject.fluidbox.height)
    end

    if e.fluidboxes then
        local fluidboxes_io_type = {
            ["in"] = "input",
            ["out"] = "output",
        }
        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local iotype, idx = classify:match("^(%a+)(%d+)$")
            local box = typeobject.fluidboxes[fluidboxes_io_type[iotype]][tonumber(idx)] or {base_level = 0, capacity = 0, height = 0}

            local fluid = e.fluidboxes[classify.."_fluid"]
            local id = e.fluidboxes[classify.."_id"]
            res[#res+1] = __fluid_str(("fluidbox %s "):format(classify), fluid, id, box.base_level, box.capacity, box.height)
        end
    end

    return table.concat(res, "\n\t")
end

function idetail.show(object_id)
    iui.close("help_panel.rml")
    iui.open({"detail_panel.rml"}, object_id)

    --
    local object = assert(objects:get(object_id))
    local typeobject = iprototype.queryByName(object.prototype_name)

    idetail.selected(object)

    local p = icamera_controller.world_to_screen(object.srt.t)
    local ui_x, ui_y = iui.convert_coord(math3d.index(p, 1), math3d.index(p, 2))

    if typeobject.show_arc_menu ~= false then
        iui.open({"building_arc_menu.rml"}, object_id, {math3d.index(object.srt.t, 1, 2, 3)}, ui_x, ui_y)
    end

    do
        log.info(([[
        {
            id = %d,
            prototype_name = "%s",
            dir = "%s",
            x = %s,
            y = %s,
            network = %s,
            delta = %s,
        },
        %s
        ]]):format(
            object.id,
            object.prototype_name,
            object.dir,
            object.x,
            object.y,
            __get_capacitance(object.gameplay_eid).network,
            __get_capacitance(object.gameplay_eid).delta,
            __fluidbox_str(object.gameplay_eid)
        ))
    end
    return true
end

do
    local sprites = {}
    local create_sprite = ecs.require "sprite"
    local SPRITE_COLOR = import_package "vaststars.prototype".load("sprite_color")
    local selected_boxes

    function idetail.unselected()
        for _, sprite in ipairs(sprites) do
            sprite:remove()
        end
        sprites = {}

        if selected_boxes then
            selected_boxes:remove()
            selected_boxes = nil
        end
    end

    function idetail.selected(object)
        idetail.unselected()
        local typeobject = iprototype.queryByName(object.prototype_name)
        local color = SPRITE_COLOR.SELECTED_OUTLINE

        selected_boxes = create_selected_boxes(
            {
                "/pkg/vaststars.resources/prefabs/selected-box-no-animation.prefab",
                "/pkg/vaststars.resources/prefabs/selected-box-no-animation-line.prefab",
            },
            object.srt.t, color, iprototype.rotate_area(typeobject.area, object.dir)
        )

        if typeobject.supply_area then
            for _, object in objects:all() do
                local otypeobject = iprototype.queryByName(object.prototype_name)
                if otypeobject.supply_area then
                    local w, h = iprototype.rotate_area(otypeobject.area, object.dir)
                    local ow, oh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
                    ow, oh = tonumber(ow), tonumber(oh)
                    sprites[#sprites+1] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_OTHER)
                end
            end
        elseif typeobject.power_supply_area and typeobject.power_supply_distance then
            for _, object in objects:all() do
                local otypeobject = iprototype.queryByName(object.prototype_name)
                if otypeobject.power_supply_area then
                    local w, h = iprototype.rotate_area(otypeobject.area, object.dir)
                    local ow, oh = otypeobject.power_supply_area:match("(%d+)x(%d+)")
                    ow, oh = tonumber(ow), tonumber(oh)
                    sprites[#sprites+1] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, SPRITE_COLOR.POWER_SUPPLY_AREA)
                end
            end
        end
    end
end