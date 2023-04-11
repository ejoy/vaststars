local ecs = ...
local world = ecs.world
local w = world.w

local iprototype = require "gameplay.interface.prototype"
local objects = require "objects"
local assembling_common = require "ui_datamodel.common.assembling"
local iprinter = ecs.import.interface "mod.printer|iprinter"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local prefab_meshbin = require("engine.prefab_parser").meshbin

local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"

local progresses = {} --TODO: when an object is destroyed, clear it.

return function(world)
    local t = {}
    for e in world.ecs:select "assembling:in building:in chest:in eid:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        if typeobject.construction_center ~= true then
            goto continue
        end

        local _, results, progress, total_progress = assembling_common.get(world, e)
        if #results == 0 then -- Not yet set recipe
            goto continue
        end

        local object = assert(objects:coord(e.building.x, e.building.y))
        local srt = object.srt
        local t = {srt.t[1], 13, srt.t[3]} --TODO: change the height to be configured in the slot of prefab

        progresses[e.eid] = progresses[e.eid] or {progress = 0, printer_entities = {}, recipe = e.assembling.recipe}
        if progresses[e.eid].recipe ~= e.assembling.recipe then
            progresses[e.eid].recipe = e.assembling.recipe
            for _, obj in ipairs(progresses[e.eid].printer_entities) do
                obj:remove()
            end
            progresses[e.eid].printer_entities = {}
        end

        local entities = progresses[e.eid].printer_entities
        if #entities == 0 then
            local res_typeobject = iprototype.queryById(results[1].id)
            local s = res_typeobject.printer_scale and res_typeobject.printer_scale or {1, 1, 1}
            local meshbins = prefab_meshbin(RESOURCES_BASE_PATH:format(res_typeobject.model))

            for _, meshbin in ipairs(meshbins) do
                entities[#entities+1] = ientity_object.create(ecs.create_entity {
                    policy = {
                        "ant.render|render",
                        "ant.general|name",
                        "mod.printer|printer",
                    },
                    data = {
                        name = "printer",
                        scene = {s = s, t = t},
                        material = "/pkg/mod.printer/assets/printer.material",
                        visible_state = "main_view",
                        mesh = meshbin,
                        render_layer= "postprocess_obj",
                        printer = {
                            percent = (total_progress - progress)/total_progress
                        }
                    },
                })
            end
        end

        if progress > progresses[e.eid].progress then
            progresses[e.eid].progress = progress
        end

        for _, obj in ipairs(progresses[e.eid].printer_entities) do
            local percent = (total_progress - progress)/total_progress
            iprinter.update_printer_percent(obj.id, percent)
        end

        ::continue::
    end
    return t
end