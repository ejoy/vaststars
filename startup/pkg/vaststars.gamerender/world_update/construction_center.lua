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

local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
-- the assembling machine is currently capable of distinguishing only between two states: working and idle. for more details, see the implementation in assembling.cpp
local STATUS_WORKING <const> = 1

local progresses = {} --TODO: when an object is destroyed, clear it.

return function(gameplay_world)
    local t = {}
    for e in gameplay_world.ecs:select "assembling:in building:in chest:in eid:in" do
        local typeobject = iprototype.queryById(e.building.prototype)
        if typeobject.construction_center ~= true then
            goto continue
        end

        local _, results, progress, total_progress = assembling_common.get(gameplay_world, e)
        if #results == 0 then -- Not yet set recipe
            goto continue
        end
        local res_typeobject = iprototype.queryById(results[1].id)
        local s = res_typeobject.printer_scale and res_typeobject.printer_scale or {1, 1, 1}

        local object = assert(objects:coord(e.building.x, e.building.y))
        local srt = object.srt
        local t = {srt.t[1], 13, srt.t[3]} --TODO: change the height to be configured in the slot of prefab

        progresses[e.eid] = progresses[e.eid] or {progress = 0, printer_entities = {}, entity = nil, recipe = e.assembling.recipe}
        if progresses[e.eid].recipe ~= e.assembling.recipe then
            progresses[e.eid].recipe = e.assembling.recipe
            for _, obj in ipairs(progresses[e.eid].printer_entities) do
                obj:remove()
            end
            progresses[e.eid].printer_entities = {}

            if progresses[e.eid].entity then
                progresses[e.eid].entity:remove()
                progresses[e.eid].entity = nil
            end
        end

        local entities = progresses[e.eid].printer_entities
        if #entities == 0 then
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
                        },
                        on_ready = function(e)
                            ivs.set_state(e, "main_view", false)
                        end,
                    },
                })
            end
        end

        if not progresses[e.eid].entity then
            local p = ecs.create_instance(RESOURCES_BASE_PATH:format(res_typeobject.model))
            function p:on_ready()
                local root <close> = w:entity(self.tag['*'][1])
                iom.set_position(root, t)
                iom.set_scale(root, s)

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
            progresses[e.eid].entity = world:create_object(p)
        end

        if e.assembling.status ~= STATUS_WORKING then
            if results[1].count > 0 then
                progress = 0
            else
                progress = total_progress
            end
        end

        if progresses[e.eid].progress ~= progress then
            if progress == 0 then
                for _, obj in ipairs(progresses[e.eid].printer_entities) do
                    local e <close> = w:entity(obj.id, "visible_state?in")
                    if e.visible_state then
                        ivs.set_state(e, "main_view", false)
                    end
                end
                progresses[e.eid].entity:send("show")
            else
                for _, obj in ipairs(progresses[e.eid].printer_entities) do
                    local e <close> = w:entity(obj.id, "visible_state?in")
                    if e.visible_state then
                        ivs.set_state(e, "main_view", true)
                    end
                    local percent = (total_progress - progress)/total_progress
                    iprinter.update_printer_percent(obj.id, percent)
                end
                progresses[e.eid].entity:send("hide")
            end
            progresses[e.eid].progress = progress
        end

        ::continue::
    end
    return t
end