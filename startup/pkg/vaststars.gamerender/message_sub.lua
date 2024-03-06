local ecs = ...
local world = ecs.world
local w = world.w

local ivs = ecs.require "ant.render|visible_state"
local imaterial = ecs.require "ant.asset|material"
local iefk = ecs.require "ant.efk|efk"
local iplayback = ecs.require "ant.animation|playback"
local iom = ecs.require "ant.objcontroller|obj_motion"
local imodifier = ecs.require "ant.modifier|modifier"

local message = ecs.require "message"

message:sub("show", function(instance, visible)
    for _, eid in ipairs(instance.tag['*']) do
        local e <close> = world:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", visible)
        end
    end
end)

message:sub("material", function(instance, method, ...)
    local exclude = {}
    for _, eid in ipairs(instance.tag["no_color_factors"] or {}) do
        exclude[eid] = true
    end
    for _, eid in ipairs(instance.tag["*"]) do
        if not exclude[eid] then
            local e <close> = world:entity(eid, "material?in")
            if e.material then
                imaterial[method](e, ...)
            end
        end
    end
end)

message:sub("stop_world", function(instance)
    for _, eid in ipairs(instance.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, false)
        end
        if e.efk then
            iefk.pause(e, true)
        end
    end
end)

message:sub("restart_world", function(instance)
    for _, eid in ipairs(instance.tag["*"]) do
        local e <close> = world:entity(eid, "animation?in efk?in")
        if e.animation then
            iplayback.set_play_all(e, true)
        end
        if e.efk then
            iefk.pause(e, false)
        end
    end
end)

message:sub("create_group", function(instance, group)
    local e <close> = world:entity(instance.tag["*"][1])
    w:extend(e, "hitch:update hitch_create?out")
    e.hitch.group = group
    e.hitch_create = true
end)
message:sub("update_group", function(instance, group)
    local e <close> = world:entity(instance.tag["*"][1])
    w:extend(e, "hitch:update hitch_update?out")
    e.hitch.group = group
    e.hitch_update = true
end)
message:sub("obj_motion", function(instance, method, ...)
    local e <close> = world:entity(instance.tag["*"][1])
    iom[method](e, ...)
end)
message:sub("modifier", function(instance, ...)
    imodifier.start(imodifier.create_bone_modifier(instance.tag["*"][1], 0, "/pkg/vaststars.resources/glbs/animation/Interact_build.glb|mesh.prefab", "Bone"), ...)
end)
message:sub("attach", function(instance, slot_name, child)
    local eid = assert(instance.tag[slot_name][1])
    world:instance_set_parent(child, eid)
end)

return message
