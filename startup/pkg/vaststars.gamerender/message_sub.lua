local ecs = ...
local world = ecs.world
local w = world.w

local imessage = ecs.require "message"
local ivs = ecs.require "ant.render|visible_state"
local imaterial = ecs.require "ant.asset|material"
local iom = ecs.require "ant.objcontroller|obj_motion"

imessage:sub("show", function(instance, visible)
    for _, eid in ipairs(instance.tag['*']) do
        local e <close> = world:entity(eid, "visible_state?in")
        if e.visible_state then
            ivs.set_state(e, "main_view", visible)
        end
    end
end)

imessage:sub("material", function(self, method, ...)
    for _, eid in ipairs(self.tag['*']) do
        local e <close> = world:entity(eid, "material?in")
        if e.material then
            imaterial[method](e, ...)
        end
    end
end)

imessage:sub("obj_motion", function(self, method, ...)
    for _, eid in ipairs(self.noparent) do
        local e <close> = world:entity(eid)
        iom[method](e, ...)
    end
end)

return imessage
