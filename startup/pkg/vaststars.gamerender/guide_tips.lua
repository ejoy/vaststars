local ecs = ...
local world = ecs.world
local w = world.w

local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local EDITOR_CACHE_NAMES <const> = {"CONFIRM", "CONSTRUCTED"}

local icoord = require "coord"
local irl = ecs.require "ant.render|render_layer.render_layer"
local iom = ecs.require "ant.objcontroller|obj_motion"
local objects = require "objects"
local create_selected_box = ecs.require "selected_boxes"
local icamera_controller = ecs.require "engine.system.camera_controller"
local math3d = require "math3d"
local iui = ecs.require "engine.system.ui_system"
local itl = ecs.require "ant.timeline|timeline"

local selected_tips = {}
local excluded_pickup_id

local function show(tech_node)
    local focus = tech_node.detail.guide_focus
    if not focus then
        return
    end
    for _, nd in ipairs(focus) do
        if nd.prefab then
            if not selected_tips then
                selected_tips = {}
            end

            local prefab
            local center = icoord.position(nd.x, nd.y, 1, 1)
            if nd.show_arrow then
                prefab = assert(world:create_instance({
                    prefab = "/pkg/vaststars.resources/glbs/arrow-guide.glb|mesh.prefab",
                    on_ready = function(self)
                        for _, eid in ipairs(self.tag['*']) do
                            local e <close> = world:entity(eid, "render_object?in timeline?in loop_timeline?out")
                            if e.render_object then
                                irl.set_layer(e, RENDER_LAYER.SELECTED_BOXES)
                            end
                            if e.timeline then
                                e.timeline.eid_map = self.tag
                                itl:start(e)

                                if e.timeline.loop == true then
                                    e.loop_timeline = true
                                end
                            end
                        end

                        local root <close> = world:entity(assert(self.tag['*'][1]))
                        iom.set_position(root, center)
                    end,
                }))
            end
            if nd.force then
                local object = objects:coord(nd.x, nd.y, EDITOR_CACHE_NAMES)
                if object then
                    excluded_pickup_id = object.id
                end
            end
            selected_tips[#selected_tips + 1] = {create_selected_box({"/pkg/vaststars.resources/" .. nd.prefab}, center, math3d.vector(nd.color), nd.w, nd.h), prefab}
        elseif nd.camera_x and nd.camera_y then
            iui.leave()
            iui.redirect("/pkg/vaststars.resources/ui/construct.html", "unselected")
            icamera_controller.focus_on_position("CENTER", math3d.vector(icoord.position(nd.camera_x, nd.camera_y, nd.w, nd.h)))
        end
    end
end

local function clear()
    if not selected_tips then
        return
    end
    for _, tip in ipairs(selected_tips) do
        tip[1]:remove()
        if tip[2] then
            world:remove_instance(tip[2])
        end
    end
    selected_tips = {}
    excluded_pickup_id = nil
end

local function get_excluded_pickup_id()
    return excluded_pickup_id
end

return {
    show = show,
    clear = clear,
    get_excluded_pickup_id = get_excluded_pickup_id,
}
