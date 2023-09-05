local ecs = ...
local world = ecs.world
local w = world.w

local iui = ecs.require "engine.system.ui_system"
local objects = require "objects"
local iprototype = require "gameplay.interface.prototype"
local idetail = {}
local gameplay_core = require "gameplay.core"
local create_selected_boxes = ecs.require "selected_boxes"
local terrain = ecs.require "terrain"
local vsobject_manager = ecs.require "vsobject_manager"
local audio = import_package "ant.audio"

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

local function __get_detail_str(eid)
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

    if e.chimney then
        res[#res+1] = "chimney recipe: " .. (e.chimney.recipe == 0 and 0 or iprototype.queryById(e.chimney.recipe).name)
    end

    return table.concat(res, "\n\t")
end

function idetail.show(object_id)
    local object = assert(objects:get(object_id))
    local gameplay_eid = object.gameplay_eid
    local typeobject = iprototype.queryByName(object.prototype_name)

    idetail.selected(object.gameplay_eid)
    if typeobject.building_menu ~= false then
        iui.open({"/pkg/vaststars.resources/ui/building_menu.rml"}, gameplay_eid)
    end

    do
        local vsobject = assert(vsobject_manager:get(object.id), ("(%s) vsobject not found"):format(object.prototype_name))
        local game_object = vsobject.game_object
        log.info(([[
        {
            hitch_eid = %s,
            group_id = %s,
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
            game_object.hitch_entity_object.id,
            game_object.group_id,
            object.id,
            object.prototype_name,
            object.dir,
            object.x,
            object.y,
            __get_capacitance(gameplay_eid).network,
            __get_capacitance(gameplay_eid).delta,
            __get_detail_str(gameplay_eid)
        ))
    end
    return true
end

do
    local temp_objects = {}
    local create_sprite = ecs.require "sprite"
    local SPRITE_COLOR <const> = import_package "vaststars.prototype".load("sprite_color")
    local DOTTED_LINE_MATERIAL <const> = "/pkg/vaststars.resources/materials/dotted_line.material"
    local iquad_lines_entity = ecs.require "engine.quad_lines_entity"

    local function __check_pipe_to_ground(object, dir)
        local typeobject = iprototype.queryByName(object.prototype_name)
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            if connection.ground then
                local _, _, connection_dir = iprototype.rotate_connection(connection.position, object.dir, typeobject.area)
                if connection_dir == dir then
                    return true
                end
            end
        end
    end

    local function __find_ground_neighbor(prototype_name, x, y, dir)
        local typeobject = iprototype.queryByName(prototype_name)
        for _, connection in ipairs(typeobject.fluidbox.connections) do
            if connection.ground then
                local connection_x, connection_y, connection_dir = iprototype.rotate_connection(connection.position, dir, typeobject.area)
                local succ, dx, dy = false, x + connection_x, y + connection_y
                for _ = 1, connection.ground do
                    succ, dx, dy = terrain:move_coord(dx, dy, connection_dir, 1)
                    if not succ then
                        return
                    end

                    local neighbor = objects:coord(dx, dy)
                    if not neighbor then
                        goto continue
                    end

                    if not iprototype.is_pipe_to_ground(neighbor.prototype_name) then
                        goto continue
                    end

                    if __check_pipe_to_ground(neighbor, iprototype.reverse_dir(connection_dir)) then
                        return neighbor, connection_dir
                    end

                    ::continue::
                end
                return
            end
        end
        assert(false)
    end

    function idetail.unselected()
        for _, o in ipairs(temp_objects) do
            o:remove()
        end
        temp_objects = {}
    end

    function idetail.focus_non_building(x, y, w, h)
        idetail.unselected()

        local pos = terrain:get_position_by_coord(x, y, w, h)
        temp_objects[#temp_objects+1] = create_selected_boxes(
            {
                "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
            },
            pos, SPRITE_COLOR.SELECTED_OUTLINE, w, h
        )
    end

    function idetail.focus(gameplay_eid)
        idetail.unselected()

        local e = assert(gameplay_core.get_entity(gameplay_eid))

        do
            local object = assert(objects:coord(e.building.x, e.building.y))
            local vsobject = assert(vsobject_manager:get(object.id))
            vsobject:modifier("start", {name = "talk", forwards = true})
            temp_objects[#temp_objects+1] = {
                remove = function (self)
                    local vsobject = vsobject_manager:get(object.id)
                    if vsobject then
                        vsobject:modifier("start", {name = "over", forwards = true})
                    end
                end
            }
        end

        do
            local typeobject = iprototype.queryById(e.building.prototype)
            local w, h = iprototype.rotate_area(typeobject.area, e.building.direction)
            local pos = terrain:get_position_by_coord(e.building.x, e.building.y, w, h)
            temp_objects[#temp_objects+1] = create_selected_boxes(
                {
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                    "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
                },
                pos, SPRITE_COLOR.SELECTED_OUTLINE, w, h
            )
        end
    end

    function idetail.selected(gameplay_eid)
        local e = assert(gameplay_core.get_entity(gameplay_eid))
        local typeobject = e.lorry and iprototype.queryById(e.lorry.item_prototype) or iprototype.queryById(e.building.prototype)
        local object
        if e.building then
            object = assert(objects:coord(e.building.x, e.building.y))
        end

        if typeobject.sound then
            audio.play_background("event:/" .. typeobject.sound)
        end
        temp_objects[#temp_objects+1] = {
            remove = function (self)
                audio.stop_background(true)
            end
        }

        --
        if typeobject.supply_area then
            for _, o in objects:all() do
                local otypeobject = iprototype.queryByName(o.prototype_name)
                if otypeobject.supply_area and o.id ~= object.id then
                    local w, h = iprototype.rotate_area(otypeobject.area, o.dir)
                    local ow, oh = iprototype.rotate_area(otypeobject.supply_area, o.dir)
                    ow, oh = tonumber(ow), tonumber(oh)
                    temp_objects[#temp_objects+1] = create_sprite(o.x - (ow - w)//2, o.y - (oh - h)//2, ow, oh, o.dir, SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_OTHER)
                end
            end
            local w, h = iprototype.rotate_area(typeobject.area, object.dir)
            local ow, oh = iprototype.rotate_area(typeobject.supply_area, object.dir)
            ow, oh = tonumber(ow), tonumber(oh)
            temp_objects[#temp_objects+1] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID)

        elseif typeobject.power_supply_area and typeobject.power_supply_distance then
            for _, o in objects:all() do
                if o.id ~= object.id then
                    local otypeobject = iprototype.queryByName(o.prototype_name)
                    if otypeobject.power_supply_area then
                        local w, h = iprototype.rotate_area(otypeobject.area, o.dir)
                        local ow, oh = iprototype.rotate_area(otypeobject.power_supply_area, o.dir)
                        temp_objects[#temp_objects+1] = create_sprite(o.x - (ow - w)//2, o.y - (oh - h)//2, ow, oh, o.dir, SPRITE_COLOR.POWER_SUPPLY_AREA)
                    end
                end
            end
            local w, h = iprototype.rotate_area(typeobject.area, object.dir)
            local ow, oh = iprototype.rotate_area(typeobject.power_supply_area, object.dir)
            temp_objects[#temp_objects+1] = create_sprite(object.x - (ow - w)//2, object.y - (oh - h)//2, ow, oh, object.dir, SPRITE_COLOR.POWER_SUPPLY_AREA_SELF)
        end

        --
        if iprototype.is_pipe_to_ground(typeobject.name) then
            local neighbor, connection_dir = __find_ground_neighbor(object.prototype_name, object.x, object.y, object.dir)
            if neighbor then
                temp_objects[#temp_objects+1] = create_selected_boxes(
                    {
                        "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                        "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
                    },
                    neighbor.srt.t, SPRITE_COLOR.SELECTED_OUTLINE, iprototype.rotate_area(typeobject.area, neighbor.dir)
                )

                local quad_num
                if object.x == neighbor.x then
                    quad_num = math.abs(object.y - neighbor.y) - 1
                elseif object.y == neighbor.y then
                    quad_num = math.abs(object.x - neighbor.x) - 1
                else
                    log.error("invalid quad line")
                end

                if quad_num > 0 then
                    local dotted_line = iquad_lines_entity.create(DOTTED_LINE_MATERIAL)
                    local succ, dx, dy = terrain:move_coord(object.x, object.y, connection_dir, 1)
                    if succ then
                        local position = terrain:get_position_by_coord(dx, dy, 1, 1)
                        dotted_line:update(position, quad_num, connection_dir)
                        dotted_line:show(true)

                        temp_objects[#temp_objects+1] = dotted_line
                    end
                end
            end
        end
    end
end

return idetail
