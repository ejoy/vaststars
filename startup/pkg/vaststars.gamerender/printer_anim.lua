local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local ientity_object = ecs.require "engine.system.entity_object_system"
local iprinter = ecs.import.interface "mod.printer|iprinter"
local prefab_meshbin = require("engine.prefab_parser").meshbin
local iprototype = require "gameplay.interface.prototype"
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
local DELTA_TIME <const> = require("gameplay.interface.constant").DELTA_TIME

return function(building, building_srt, duration_ms)
    local progress = 0
    local printer_entities = {}
    local typeobject = iprototype.queryByName(building)

    local model = typeobject.model

    local meshbins = prefab_meshbin(RESOURCES_BASE_PATH:format(model))
    for _, m in ipairs(meshbins) do
        local position
        if m.scene.t then
            position = math3d.add(building_srt.t, m.scene.t)
        else
            position = building_srt.t
        end
        printer_entities[#printer_entities+1] = ientity_object.create(ecs.create_entity {
            policy = {
                "ant.render|render",
                "ant.general|name",
                "mod.printer|printer",
            },
            data = {
                name = "printer",
                scene = {t = position, s = m.scene.s},
                material = "/pkg/mod.printer/assets/printer.material",
                visible_state = "main_view",
                mesh = m.mesh,
                render_layer= "postprocess_obj",
                printer = {
                    percent = 0,
                },
                on_ready = function(e)
                end,
            },
        })
    end

    local function remove()
        for _, obj in ipairs(printer_entities) do
            obj:remove()
        end
        printer_entities = {}
    end

    return function()
        progress = progress + DELTA_TIME
        if progress > duration_ms then
            progress = duration_ms
        end

        for _, obj in ipairs(printer_entities) do
            iprinter.update_printer_percent(obj.id, progress/duration_ms)
        end

        if progress >= duration_ms then
            remove()
            return false
        else
            return true
        end
    end
end