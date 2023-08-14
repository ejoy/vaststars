local ecs = ...
local world = ecs.world
local w = world.w

local imaterial = ecs.require "ant.asset|material"
local iani = ecs.import.interface "ant.animation|ianimation"

local events = {}
events["material"] = function(prefab, inner, method, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e <close> = w:entity(eid, "material?in")
        if e.material then
            imaterial[method](e, ...)
        end
    end
end

events["material_tag"] = function(prefab, inner, method, tag, ...)
    for _, eid in ipairs(inner.tags[tag] or {}) do
        local e <close> = w:entity(eid, "material?in")
        if e.material then
            imaterial[method](e, ...)
        end
    end
end

events["attach_hitch"] = function(prefab, inner, ...)
    local has_anim = false
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = w:entity(eid, "anim_ctrl?in")
        if e.anim_ctrl then
            has_anim = true
        end
    end

    if not has_anim then
        return
    end
    iani.attach_hitch(prefab, ...)
end

events["detach_hitch"] = function(prefab, inner, ...)
    local has_anim = false
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = w:entity(eid, "anim_ctrl?in")
        if e.anim_ctrl then
            has_anim = true
        end
    end

    if not has_anim then
        return
    end
    iani.detach_hitch(prefab, ...)
end

return events