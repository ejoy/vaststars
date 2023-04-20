local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local assembling_common = require "ui_datamodel.common.assembling"
local iprinter = ecs.import.interface "mod.printer|iprinter"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local prefab_meshbin = require("engine.prefab_parser").meshbin
local ivs = ecs.import.interface "ant.scene|ivisible_state"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local global = require "global"
local vsobject_manager = ecs.require "vsobject_manager"
local math3d = require "math3d"

local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
-- the assembling machine is currently capable of distinguishing only between two states: working and idle. for more details, see the implementation in assembling.cpp
local STATUS_WORKING <const> = 1

local function create_wing_status()
    local status = "wing_none"
    local function on_position_change()
    end
    local function remove()
        -- do nothing
    end
    local function update(self, gameplay_world, e)
        local object = assert(objects:coord(e.building.x, e.building.y))
        local vsobject = vsobject_manager:get(object.id)
        local _, results = assembling_common.get(gameplay_world, e)
        local current
        if e.assembling.status ~= STATUS_WORKING then
            if results[1] and results[1].count > 0 then
                current = "wing_open"
            else
                current = "wing_close"
            end
        else
            current = "wing_open"
        end
        if current ~= status then
            vsobject:animation_name_update(current, true)
            status = current
        end
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        update = update,
    }
end

local function create_printer()
    local progress = 0
    local printer_entities = {}
    local entity = nil
    local recipe = nil

    local function on_position_change(self, building_srt)
        local t = math3d.vector(building_srt.t[1], 13, building_srt.t[3]) --TODO: change the height to be configured in the slot of prefab
        for _, obj in ipairs(printer_entities) do
            iom.set_position(obj.id, t)
        end
        if entity then
            iom.set_position(entity.id, t)
        end
    end
    local function remove()
        for _, obj in ipairs(printer_entities) do
            obj:remove()
        end
        printer_entities = {}
        if entity then
            entity:remove()
            entity = nil
        end
    end
    local function update(self, gameplay_world, e, building_srt)
        local _, results, current, total_progress = assembling_common.get(gameplay_world, e)
        if #results == 0 then -- Not yet set recipe
            remove()
            return
        end

        if e.assembling.recipe ~= recipe then
            recipe = e.assembling.recipe
            remove()
        end

        if results[1].id == 0 then
            return
        end

        local res_typeobject = iprototype.queryById(results[1].id)
        local scale = res_typeobject.printer_scale and res_typeobject.printer_scale or {1, 1, 1}
        local position = {building_srt.t[1], 13, building_srt.t[3]} --TODO: change the height to be configured in the slot of prefab

        if #printer_entities == 0 then
            local meshbins = prefab_meshbin(RESOURCES_BASE_PATH:format(res_typeobject.model))
            for _, meshbin in ipairs(meshbins) do
                printer_entities[#printer_entities+1] = ientity_object.create(ecs.create_entity {
                    policy = {
                        "ant.render|render",
                        "ant.general|name",
                        "mod.printer|printer",
                    },
                    data = {
                        name = "printer",
                        scene = {s = scale, t = position},
                        material = "/pkg/mod.printer/assets/printer.material",
                        visible_state = "main_view",
                        mesh = meshbin,
                        render_layer= "postprocess_obj",
                        printer = {
                            percent = 0,
                        },
                        on_ready = function(e)
                            ivs.set_state(e, "main_view", false)
                        end,
                    },
                })
            end
        end

        if not entity then
            local p = ecs.create_instance(RESOURCES_BASE_PATH:format(res_typeobject.model))
            function p:on_ready()
                local root <close> = w:entity(self.tag['*'][1])
                iom.set_position(root, position)
                iom.set_scale(root, scale)

                for _, eid in ipairs(self.tag['*']) do
                    local e <close> = w:entity(eid, "visible_state?in")
                    if e.visible_state then
                        ivs.set_state(e, "main_view", false)
                        ivs.set_state(e, "cast_shadow", false)
                    end
                end
            end
            function p:on_message(msg)
                assert(msg == "show" or msg == "hide")
                for _, eid in ipairs(self.tag['*']) do
                    local e <close> = w:entity(eid, "visible_state?in")
                    if e.visible_state then
                        ivs.set_state(e, "main_view", msg == "show")
                        ivs.set_state(e, "cast_shadow", msg == "show")
                    end
                end
            end
            entity = world:create_object(p)
        end

        if e.assembling.status ~= STATUS_WORKING then
            if results[1].count > 0 then
                current = 0
            else
                current = total_progress
            end
        end
        if progress ~= current then
            if current == 0 then
                for _, obj in ipairs(printer_entities) do
                    local e <close> = w:entity(obj.id, "visible_state?in")
                    if e.visible_state then
                        ivs.set_state(e, "main_view", false)
                    end
                end
                entity:send("show")
            else
                for _, obj in ipairs(printer_entities) do
                    local e <close> = w:entity(obj.id, "visible_state?in")
                    if e.visible_state then
                        ivs.set_state(e, "main_view", true)
                    end
                    local percent = (total_progress - current)/total_progress
                    iprinter.update_printer_percent(obj.id, percent)
                end
                entity:send("hide")
            end
            progress = current
        end
    end
    return {
        on_position_change = on_position_change,
        remove = remove,
        update = update,
    }
end

return function(gameplay_world)
    local buildings = global.buildings
    for e in gameplay_world.ecs:select "assembling:in building:in chest:in eid:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        if not iprototype.has_type(typeobject.type, "construction_center") then
            goto continue
        end
        local object = assert(objects:coord(e.building.x, e.building.y))

        buildings[object.id].construction_center_wing_status = buildings[object.id].construction_center_wing_status or create_wing_status()
        buildings[object.id].construction_center_wing_status:update(gameplay_world, e)

        buildings[object.id].construction_center_printer = buildings[object.id].construction_center_printer or create_printer()
        buildings[object.id].construction_center_printer:update(gameplay_world, e, object.srt)
        ::continue::
    end
    return t
end